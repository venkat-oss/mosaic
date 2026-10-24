from __future__ import annotations

import os
import sys

os.execve(  # ruff: ignore[start-process-with-no-shell]
    sys.executable,
    [sys.executable, *sys.argv[1:]],
    {
        **os.environ,
        "PYTHONPATH": os.pathsep.join(sys.path),
        "PYTHONDONTWRITEBYTECODE": "1",
    },
)
