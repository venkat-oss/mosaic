from pathlib import Path
import sys

source, output, platform = sys.argv[1:]
fields = ["4", platform, "v2.0.0", "0.4.3", "CPP", "", "", ""]
# https://github.com/duckdb/duckdb/blob/v2.0.0/scripts/append_metadata.cmake
footer = (
    bytes([0, 147, 4, 16])
    + b"duckdb_signature"
    + bytes([128, 4])
    + b"".join(field.encode().ljust(32, b"\0") for field in reversed(fields))
    + bytes(256)
)
Path(output).write_bytes(Path(source).read_bytes() + footer)
