from __future__ import annotations

import contextlib
import io
import os
import subprocess
import sys
import threading
import time
import unittest
from http.server import BaseHTTPRequestHandler, HTTPServer
from typing import TYPE_CHECKING
from unittest.mock import patch

import bench

if TYPE_CHECKING:
    from pathlib import Path


class BenchmarkTest(unittest.TestCase):
    def test_declared_servers_ignore_host_runtimes(self) -> None:
        with patch.dict(os.environ, {"MOSAIC_BENCH_NODE": "declared-node"}, clear=True):
            self.assertEqual(bench.detect_servers(), ["node"])

    def test_missing_server_is_rejected_before_startup(self) -> None:
        with (
            patch.dict(os.environ, {"MOSAIC_BENCH_NODE": "declared-node"}, clear=True),
            patch.object(sys, "argv", ["bench", "--servers", "rust"]),
            contextlib.redirect_stderr(io.StringIO()) as errors,
            self.assertRaises(SystemExit) as failure,
        ):
            bench.main()
        self.assertEqual(failure.exception.code, 2)
        self.assertIn("Servers not included", errors.getvalue())

    def test_failed_startup_does_not_wait_for_timeout(self) -> None:
        with subprocess.Popen([sys.executable, "-c", "raise SystemExit(3)"]) as proc:
            proc.wait(timeout=5)
            start = time.monotonic()
            self.assertFalse(
                bench.wait_for_server("node", "127.0.0.1", 1, proc, timeout=30)
            )
            self.assertLess(time.monotonic() - start, 1)
            with (
                patch.dict(
                    os.environ, {"MOSAIC_BENCH_NODE": "declared-node"}, clear=True
                ),
                patch.object(sys, "argv", ["bench", "--servers", "node"]),
                patch.object(bench, "start_server", return_value=proc),
                contextlib.redirect_stdout(io.StringIO()),
                self.assertRaises(SystemExit) as failure,
            ):
                bench.main()
            self.assertIn("failed to start", str(failure.exception))

    def test_occupied_port_receives_no_requests(self) -> None:
        requests = []

        class RecordingServer(BaseHTTPRequestHandler):
            def do_POST(self) -> None:
                requests.append(self.path)
                self.send_response(200)
                self.end_headers()

            def log_message(self, format: str, *args: object) -> None:
                pass

        with HTTPServer(("127.0.0.1", 0), RecordingServer) as listener:
            thread = threading.Thread(target=listener.serve_forever, daemon=True)
            thread.start()
            port = listener.server_port

            def start_server(
                server: str, port: int, directory: Path
            ) -> subprocess.Popen[bytes]:
                return subprocess.Popen(
                    [
                        sys.executable,
                        "-c",
                        (
                            "import socket,time;time.sleep(.1);"
                            f"socket.socket().bind(('127.0.0.1',{port}))"
                        ),
                    ],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                )

            try:
                with (
                    patch.dict(
                        os.environ, {"MOSAIC_BENCH_NODE": "declared-node"}, clear=True
                    ),
                    patch.object(
                        sys, "argv", ["bench", "--servers", "node", "-p", str(port)]
                    ),
                    patch.object(bench, "start_server", start_server),
                    contextlib.redirect_stdout(io.StringIO()),
                    contextlib.redirect_stderr(io.StringIO()),
                    self.assertRaises(SystemExit) as failure,
                ):
                    bench.main()
                self.assertIn("failed to start", str(failure.exception))
                self.assertEqual(requests, [])
            finally:
                listener.shutdown()
                thread.join()


if __name__ == "__main__":
    unittest.main()
