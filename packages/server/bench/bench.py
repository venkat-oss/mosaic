"""Benchmark native Bazel server executables over HTTP POST.

Run //packages/server/bench:bench for all servers, or :bench_node,
:bench_python, :bench_go and :bench_rust for an individual implementation.
Use --servers to select among the target's declared servers.
"""

from __future__ import annotations

import argparse
import http.client
import json
import math
import os
import statistics
import subprocess
import sys
import tempfile
import threading
import time
from collections import deque
from pathlib import Path

from python.runfiles import runfiles

SERVER_NAMES = ("rust", "go", "python", "node")
MAX_PORT = 65535


def runfile(name: str) -> Path:
    path = runfiles.Create().Rlocation(name)
    if not path or not Path(path).is_file():
        msg = f"Missing declared benchmark input: {name}"
        raise RuntimeError(msg)
    return Path(path)


def load_queries() -> list[str]:
    directory = runfile(os.environ["MOSAIC_BENCH_DATA"]).parent
    queries = []
    for table, filename in [
        ("flights", "flights-200k.parquet"),
        ("athletes", "athletes.parquet"),
        ("penguins", "penguins.parquet"),
    ]:
        path = str(directory / filename).replace("'", "''")
        queries.append(
            f"CREATE OR REPLACE TABLE {table} AS SELECT * FROM read_parquet('{path}')"
        )
    return queries


# (name, type, sql)
BENCHMARKS: list[tuple[str, str, str]] = [
    # -- tiny results --
    ("scalar", "arrow", "SELECT 1 AS x"),
    ("aggregate: count", "arrow", "SELECT count(*) AS cnt FROM flights"),
    (
        "aggregate: min/max",
        "arrow",
        "SELECT min(delay) AS lo, max(delay) AS hi FROM flights",
    ),
    (
        "filtered aggregate",
        "arrow",
        "SELECT count(*) AS cnt, avg(delay) AS mean_delay FROM flights WHERE distance > 1000 AND delay > 0",
    ),
    (
        "group-by small: species",
        "arrow",
        "SELECT species, count(*) AS cnt, avg(body_mass) AS mean_mass FROM penguins GROUP BY species",
    ),
    # -- histogram / binning (medium results) --
    (
        "histogram: delay bins",
        "arrow",
        "SELECT (10 * floor(delay / 10.0)) AS bin, count(*) AS cnt FROM flights WHERE delay BETWEEN -60 AND 180 GROUP BY bin ORDER BY bin",
    ),
    (
        "group-by: distance stats",
        "arrow",
        "SELECT distance, count(*) AS cnt, avg(delay) AS mean_delay, min(delay) AS lo, max(delay) AS hi FROM flights GROUP BY distance ORDER BY cnt DESC",
    ),
    (
        "2d-bin: heatmap",
        "arrow",
        "SELECT floor(time / 100.0) AS time_bin, (20 * floor(delay / 20.0)) AS delay_bin, count(*) AS cnt FROM flights WHERE delay BETWEEN -60 AND 180 GROUP BY time_bin, delay_bin",
    ),
    # -- larger results --
    ("scan: 1k rows", "arrow", "SELECT * FROM flights LIMIT 1000"),
    ("scan: 10k rows", "arrow", "SELECT * FROM flights LIMIT 10000"),
    ("full table: athletes", "arrow", "SELECT * FROM athletes"),
    # -- complex / realistic --
    (
        "M4-style: time-series",
        "arrow",
        (
            "WITH input AS MATERIALIZED (SELECT time, delay FROM flights WHERE distance > 500) "
            "SELECT min(time) AS x, arg_min(delay, time) AS y FROM input GROUP BY floor(time / 50.0) "
            "UNION ALL "
            "SELECT max(time) AS x, arg_max(delay, time) AS y FROM input GROUP BY floor(time / 50.0) "
            "ORDER BY x"
        ),
    ),
    (
        "CTE + window: running avg",
        "arrow",
        (
            "WITH by_dist AS (SELECT distance, count(*) AS cnt, avg(delay) AS mean_delay FROM flights GROUP BY distance) "
            "SELECT distance, cnt, avg(cnt) OVER (ORDER BY distance ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg "
            "FROM by_dist ORDER BY distance"
        ),
    ),
]


def http_post(host: str, port: int, payload: dict, timeout: float = 30) -> bytes:
    body = json.dumps(payload).encode()
    conn = http.client.HTTPConnection(host, port, timeout=timeout)
    try:
        conn.request(
            "POST",
            "/",
            body=body,
            headers={
                "Content-Type": "application/json",
                "Connection": "close",
            },
        )
        resp = conn.getresponse()
        data = resp.read()
        if resp.status != 200:  # ruff: ignore[magic-value-comparison]
            msg = f"HTTP {resp.status}: {data[:200]}"
            raise RuntimeError(msg)
        return data
    finally:
        conn.close()


def http_exec(host: str, port: int, sql: str) -> None:
    http_post(host, port, {"type": "exec", "sql": sql})


def http_query(host: str, port: int, qtype: str, sql: str) -> bytes:
    return http_post(host, port, {"type": qtype, "sql": sql})


def bench_http(
    host: str,
    port: int,
    qtype: str,
    sql: str,
    n: int,
    warmup: int,
) -> tuple[list[float], int]:
    """Returns (timings_ms, response_bytes)."""
    resp_size = 0
    for _ in range(warmup):
        data = http_query(host, port, qtype, sql)
        resp_size = len(data)

    timings: list[float] = []
    for _ in range(n):
        t0 = time.perf_counter()
        data = http_query(host, port, qtype, sql)
        elapsed = (time.perf_counter() - t0) * 1000
        timings.append(elapsed)
        resp_size = len(data)
    return timings, resp_size


def fmt_bytes(n: int) -> str:
    if n < 1024:  # ruff: ignore[magic-value-comparison]
        return f"{n}B"
    if n < 1024 * 1024:
        return f"{n / 1024:.1f}K"
    return f"{n / (1024 * 1024):.1f}M"


HEADER_FMT = "  {:<40s} {:>6s} {:>8s} {:>8s} {:>8s} {:>8s}"
ROW_FMT = "  {:<40s} {:>6s} {:>8.2f} {:>8.2f} {:>8.2f} {:>8.2f}"


def print_header() -> None:
    print(HEADER_FMT.format("QUERY", "SIZE", "MIN", "MEDIAN", "P95", "MEAN"))
    print(HEADER_FMT.format("", "", "(ms)", "(ms)", "(ms)", "(ms)"))
    print("  " + "-" * 82)


def print_row(name: str, timings: list[float], resp_size: int) -> None:
    s = sorted(timings)
    n = len(s)
    mn = s[0]
    med = statistics.median(s)
    p95 = s[math.ceil(n * 0.95) - 1]
    avg = statistics.mean(s)
    print(ROW_FMT.format(name, fmt_bytes(resp_size), mn, med, p95, avg))


def wait_for_server(
    server: str,
    host: str,
    port: int,
    proc: subprocess.Popen[bytes],
    timeout: float = 30,
) -> bool:
    ready = threading.Event()
    output: deque[bytes] = deque(maxlen=20)
    marker = {
        "node": f"Data server running on port {port}",
        "python": f"Uvicorn running on http://{host}:{port}",
        "go": f"DuckDB Server listening on http://{host}:{port}",
        "rust": f"DuckDB Server listening on http://{host}:{port}",
    }[server].encode()

    def read_output() -> None:
        if proc.stdout is not None:
            for line in proc.stdout:
                if not ready.is_set():
                    output.append(line)
                    if marker in line:
                        ready.set()

    threading.Thread(target=read_output, daemon=True).start()
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if proc.poll() is not None:
            break
        if ready.is_set():
            try:
                http_post(host, port, {"type": "arrow", "sql": "SELECT 1"}, timeout=1)
                return proc.poll() is None
            except (OSError, http.client.HTTPException, RuntimeError):
                pass
        time.sleep(0.1)
    print(b"".join(list(output)).decode(errors="replace"), file=sys.stderr, end="")
    return False


def stop_server(proc: subprocess.Popen[bytes]) -> None:
    if proc.poll() is None:
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()
    if proc.stdout is not None:
        proc.stdout.close()


def start_server(server: str, port: int, directory: Path) -> subprocess.Popen[bytes]:
    executable = runfile(os.environ["MOSAIC_BENCH_" + server.upper()])
    arguments = {
        "rust": ["--port", str(port)],
        "go": ["-address=127.0.0.1", f"-port={port}"],
        "python": ["--no-http2", "--port", str(port)],
        "node": [str(port)],
    }[server]
    print(f"  Starting {server} server ...")
    return subprocess.Popen(
        [str(executable), *arguments],
        cwd=directory,
        env={
            **os.environ,
            "BAZEL_BINDIR": ".",
            "XDG_CONFIG_HOME": str(directory / "config"),
            "APPDATA": str(directory / "config"),
            "RUST_LOG": "duckdb_server=info",
        },
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )


def detect_servers() -> list[str]:
    return [
        name for name in SERVER_NAMES if "MOSAIC_BENCH_" + name.upper() in os.environ
    ]


# Results: {label: median_ms}
ServerResults = dict[str, float]


def run_benchmarks(host: str, port: int, iterations: int, warmup: int) -> ServerResults:
    results: ServerResults = {}

    # Check server
    print(f"Checking server at http://{host}:{port} ...")
    http_post(host, port, {"type": "arrow", "sql": "SELECT 1"})
    print("Server is up.\n")

    # Load data
    print("Loading test data ...")
    for sql in load_queries():
        http_exec(host, port, sql)
    print("Data loaded.\n")

    # Banner
    print("Mosaic Server Benchmark")
    print(f"  Server:     http://{host}:{port}")
    print(f"  Iterations: {iterations}")
    print(f"  Warmup:     {warmup}")
    print()

    print("--- HTTP POST ---\n")
    print_header()
    for name, qtype, sql in BENCHMARKS:
        label = f"{name} [{qtype}]"
        timings, size = bench_http(host, port, qtype, sql, iterations, warmup)
        print_row(label, timings, size)
        results[label] = statistics.median(timings)
    print()

    return results


def print_comparison(all_results: dict[str, ServerResults]) -> None:
    """Print a side-by-side comparison of all servers."""
    servers = list(all_results.keys())
    if len(servers) < 2:  # ruff: ignore[magic-value-comparison]
        return

    labels = list(all_results[servers[0]].keys())

    # Each server gets two sub-columns: median ms + relative
    # e.g.  "  rust          go            python        node"
    #       "  0.69 (1.14x)  0.56 (0.93x)  0.60 (0.99x) 0.61 (1.01x)"
    sub_w = 14  # width per server column
    label_w = 34

    header = f"  {'QUERY':<{label_w}s}" + "".join(f" {s:>{sub_w}s}" for s in servers)
    units = f"  {'':<{label_w}s}" + "".join(f" {'ms (rel)':>{sub_w}s}" for _ in servers)
    sep = "  " + "-" * (label_w + (sub_w + 1) * len(servers))

    print("=== Comparison: HTTP POST (median ms) ===\n")
    print(header)
    print(units)
    print(sep)

    for label in labels:
        vals = [all_results[s].get(label) for s in servers]
        valid = [v for v in vals if v is not None]
        baseline = statistics.median(valid) if valid else 1.0

        row = f"  {label:<{label_w}s}"
        for v in vals:
            if v is not None and baseline > 0:
                rel = v / baseline
                cell = f"{v:.2f} ({rel:.2f}x)"
                row += f" {cell:>{sub_w}s}"
            else:
                row += f" {'—':>{sub_w}s}"
        print(row)

    print()


def main() -> None:
    parser = argparse.ArgumentParser(description="Mosaic Server Benchmark")
    parser.add_argument("-p", "--port", type=int, default=3000)
    parser.add_argument("-n", "--iterations", type=int, default=100)
    parser.add_argument("-w", "--warmup", type=int, default=5)
    parser.add_argument(
        "-s",
        "--servers",
        help="Comma-separated list of servers (rust,go,python,node). "
        "If omitted, uses this Bazel target's declared servers.",
    )
    args = parser.parse_args()

    if args.iterations < 1:
        parser.error("--iterations must be >= 1")

    if args.warmup < 0:
        parser.error("--warmup must be >= 0")
    if not 1 <= args.port <= MAX_PORT:
        parser.error("--port must be between 1 and 65535")

    host = "127.0.0.1"
    port = args.port

    servers = (
        [s.strip() for s in args.servers.split(",")]
        if args.servers
        else detect_servers()
    )

    available = detect_servers()
    if not servers:
        parser.error("No declared servers; run a //packages/server/bench Bazel target.")
    if missing := [server for server in servers if server not in available]:
        parser.error(f"Servers not included in this Bazel target: {', '.join(missing)}")

    print("=" * 60)
    print("  Mosaic Server Benchmark Suite")
    print("=" * 60)
    print(f"  Servers:    {', '.join(servers)}")
    print(f"  Iterations: {args.iterations}")
    print(f"  Warmup:     {args.warmup}")
    print(f"  Port:       {port}")
    print("=" * 60)
    print()

    all_results: dict[str, ServerResults] = {}

    for server in servers:
        print("-" * 60)
        print(f"  Server: {server}")
        print("-" * 60)

        with tempfile.TemporaryDirectory(prefix="mosaic-bench-") as directory:
            proc = start_server(server, port, Path(directory))
            try:
                print(f"  Waiting for server on port {port} ...")
                if not wait_for_server(server, host, port, proc):
                    msg = f"ERROR: {server} server failed to start on port {port}"
                    raise SystemExit(msg)
                print("  Server is ready.\n")

                results = run_benchmarks(host, port, args.iterations, args.warmup)
                if results:
                    all_results[server] = results
            finally:
                stop_server(proc)

        print()

    print_comparison(all_results)

    print("=" * 60)
    print("  All benchmarks complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()
