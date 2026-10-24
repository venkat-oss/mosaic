from __future__ import annotations

import contextlib
import io
import os
import socket
import tempfile
import unittest
from pathlib import Path

import bench
import pyarrow as pa


class BenchmarkSmokeTest(unittest.TestCase):
    def test_native_server_benchmark(self) -> None:
        with socket.socket() as listener:
            listener.bind(("127.0.0.1", 0))
            port = listener.getsockname()[1]
        server = os.environ["MOSAIC_BENCH_SMOKE"]
        with tempfile.TemporaryDirectory(prefix="mosaic-bench-test-") as directory:
            proc = bench.start_server(server, port, Path(directory))
            try:
                self.assertTrue(bench.wait_for_server(server, "127.0.0.1", port, proc))
                with contextlib.redirect_stdout(io.StringIO()):
                    results = bench.run_benchmarks("127.0.0.1", port, 1, 0)
                self.assertIn("scalar [arrow]", results)
                response = bench.http_query(
                    "127.0.0.1", port, "arrow", "SELECT count(*) AS n FROM penguins"
                )
                reader = (
                    pa.ipc.open_file(response)
                    if response.startswith(b"ARROW1")
                    else pa.ipc.open_stream(response)
                )
                self.assertEqual(reader.read_all().to_pylist(), [{"n": 342}])
            finally:
                bench.stop_server(proc)
            self.assertIsNotNone(proc.poll())


if __name__ == "__main__":
    unittest.main()
