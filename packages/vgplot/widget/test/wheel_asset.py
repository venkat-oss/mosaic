import pathlib
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as wheel:
    pathlib.Path(sys.argv[2]).write_bytes(wheel.read("mosaic_widget/static/index.js"))
