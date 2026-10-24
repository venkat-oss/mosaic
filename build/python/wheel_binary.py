from __future__ import annotations

import os
import sys
from pathlib import Path
from zipfile import ZipFile

wheel, executable, output = sys.argv[1:]
with ZipFile(wheel) as archive:
    candidates = [
        name
        for name in archive.namelist()
        if name.endswith(
            (f".data/scripts/{executable}", f".data/scripts/{executable}.exe")
        )
    ]
    if len(candidates) != 1:
        msg = f"Expected one {executable} executable in {wheel}: {candidates}"
        raise ValueError(msg)
    Path(output).write_bytes(archive.read(candidates[0]))
os.chmod(output, 0o755)
