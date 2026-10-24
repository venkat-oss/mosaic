from __future__ import annotations

import shlex
import sys
from pathlib import Path

from python.runfiles import runfiles
from watchfiles import PythonFilter, run_process

if __name__ == "__main__":
    files = runfiles.Create()
    binary, source = (files.Rlocation(argument) for argument in sys.argv[1:])
    run_process(
        str(Path(source).resolve().parent),
        target=shlex.quote(binary),
        target_type="command",
        grace_period=5,
        watch_filter=PythonFilter(),
    )
