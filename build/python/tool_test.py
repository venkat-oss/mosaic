from __future__ import annotations

import subprocess
import sys
from pathlib import Path

from python.runfiles import runfiles

files = runfiles.Create()
arguments = []
for argument in sys.argv[1:]:
    path = files.Rlocation(argument)
    arguments.append(path if path and Path(path).exists() else argument)
if Path(arguments[0]).name == "ty":
    search_paths = [
        item
        for path in sys.path
        if Path(path).is_dir()
        and not ("/lib/python" in path and "site-packages" not in path)
        for item in ["--extra-search-path", path]
    ]
    arguments[2:2] = ["--python", str(Path(sys.executable).resolve()), *search_paths]
raise SystemExit(subprocess.call(arguments))
