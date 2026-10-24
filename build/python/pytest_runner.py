from __future__ import annotations

import os
import sys
from pathlib import Path

import pytest
from python.runfiles import runfiles

files = runfiles.Create()
arguments = []
for argument in sys.argv[1:]:
    path = files.Rlocation(argument)
    arguments.append(path if path and Path(path).exists() else argument)
os.environ["PYTEST_DISABLE_PLUGIN_AUTOLOAD"] = "1"
if "MOSAIC_NODE" in os.environ:
    os.environ["MOSAIC_NODE"] = files.Rlocation(os.environ["MOSAIC_NODE"])
raise SystemExit(pytest.main(["-p", "no:cacheprovider", *arguments]))
