from __future__ import annotations

import json
import os
import shutil
import sys
import tempfile
from pathlib import Path

from hatchling.build import build_sdist

output = Path(sys.argv[1]).absolute()
sources = {
    Path(source).absolute(): relative
    for source, relative in json.loads(sys.argv[2]).items()
}
with tempfile.TemporaryDirectory() as directory:
    for source, relative in sources.items():
        destination = Path(directory) / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, destination)
    os.chdir(directory)
    filename = build_sdist(str(output.parent))
    if output.name != filename:
        msg = f"Expected {output.name}, got {filename}"
        raise ValueError(msg)
