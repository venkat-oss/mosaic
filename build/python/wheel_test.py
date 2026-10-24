from __future__ import annotations

import configparser
import copy
import importlib
import json
import os
import pickle
import socket
import subprocess
import sys
import tarfile
import tempfile
import time
from email.parser import BytesParser
from pathlib import Path
from urllib.error import URLError
from urllib.request import Request, urlopen
from zipfile import ZipFile

import tomllib
from installer import install
from installer.destinations import SchemeDictionaryDestination
from installer.sources import WheelFile
from packaging.version import Version
from python.runfiles import runfiles

files = runfiles.Create()
wheel_path, project_path, manifest_path, readme_path, package = sys.argv[1:]
wheel_path = files.Rlocation(wheel_path)
project = tomllib.loads(Path(files.Rlocation(project_path)).read_text())["project"]
manifest = json.loads(Path(files.Rlocation(manifest_path)).read_text())
readme = Path(files.Rlocation(readme_path)).read_text()
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    if wheel_path.endswith(".tar.gz"):
        from hatchling.build import build_wheel

        with tarfile.open(wheel_path) as source:
            source.extractall(root / "source", filter="data")
        source_root = next((root / "source").iterdir())
        os.chdir(source_root)
        wheel_directory = root / "rebuilt"
        wheel_directory.mkdir()
        wheel_path = str(wheel_directory / build_wheel(str(wheel_directory)))
    with ZipFile(wheel_path) as wheel:
        names = wheel.namelist()
        metadata_path = next(
            name for name in names if name.endswith(".dist-info/METADATA")
        )
        metadata = BytesParser().parsebytes(wheel.read(metadata_path))
        assert metadata["Name"] == project["name"]
        assert Version(metadata["Version"]) == Version(manifest["version"])
        assert metadata["Summary"] == project["description"]
        assert metadata["Requires-Python"] == project["requires-python"]
        assert sorted(metadata.get_all("Requires-Dist", [])) == sorted(
            project.get("dependencies", [])
        )
        assert metadata.get_payload(decode=True).decode().strip() == readme.strip()
        if project.get("scripts"):
            entry_points = configparser.ConfigParser()
            entry_points.read_string(
                wheel.read(
                    metadata_path.replace("METADATA", "entry_points.txt")
                ).decode()
            )
            assert dict(entry_points["console_scripts"]) == project["scripts"]
    library = root / "lib"
    scripts = root / "bin"
    destination = SchemeDictionaryDestination(
        scheme_dict={
            "purelib": str(library),
            "platlib": str(library),
            "scripts": str(scripts),
            "headers": str(root / "include"),
            "data": str(root),
        },
        interpreter=sys.executable,
        script_kind="posix",
        bytecode_optimization_levels=[],
    )
    with WheelFile.open(wheel_path) as wheel:
        install(wheel, destination, additional_metadata={"INSTALLER": b"bazel\n"})
    os.chdir(root)
    sys.path.insert(0, str(library))
    module = importlib.import_module(package)
    assert Path(module.__file__).is_relative_to(library)
    if package == "vgplot":
        rows = module.table("SELECT 1 AS x")
        brush = module.selection.crossfilter()
        view = module.spec(view=module.plot(module.dot(rows, x="x", filter_by=brush)))
        payload = view.to_dict()
        assert payload["plot"][0]["data"] == {"from": "rows", "filterBy": "$brush"}
        assert payload["params"] == {"brush": {"select": "crossfilter"}}
        unset = importlib.import_module("vgplot._types").UNSET
        assert pickle.loads(pickle.dumps(unset)) is unset
        assert copy.deepcopy(unset) is unset
        assert pickle.loads(pickle.dumps(module.dot)) is module.dot
    elif package == "mosaic_widget":
        root = Path(module.__file__).parent
        assert (root / "static/index.js").stat().st_size > 0
        assert (root / "static/index.css").stat().st_size > 0
        widget = module.MosaicWidget({"plot": []})
        assert widget.spec == {"plot": []}
        widget.close()
    elif package == "pkg":
        import pyarrow as pa

        environment = {**os.environ, "PYTHONPATH": os.pathsep.join(sys.path)}
        executable = scripts / "duckdb-server"
        result = subprocess.run(
            [str(executable), "--help"],
            env=environment,
            capture_output=True,
            check=True,
            text=True,
        )
        assert "--database" in result.stdout
        with socket.socket() as reservation:
            reservation.bind(("127.0.0.1", 0))
            port = reservation.getsockname()[1]
        with tempfile.TemporaryFile() as log:
            server = subprocess.Popen(
                [str(executable), "--no-http2", "--port", str(port)],
                env=environment,
                stdout=log,
                stderr=log,
            )
            try:
                request = Request(
                    f"http://127.0.0.1:{port}/",
                    data=json.dumps(
                        {"type": "arrow", "sql": "SELECT 42 AS answer"}
                    ).encode(),
                    method="POST",
                    headers={"Content-Type": "application/json"},
                )
                deadline = time.monotonic() + 20
                while True:
                    try:
                        with urlopen(request, timeout=2) as response:
                            result = pa.ipc.open_stream(response.read()).read_all()
                        break
                    except URLError:
                        if server.poll() is not None or time.monotonic() >= deadline:
                            log.seek(0)
                            raise AssertionError(log.read().decode()) from None
                        time.sleep(0.05)
                assert result.to_pylist() == [{"answer": 42}]
            finally:
                server.terminate()
                server.wait(timeout=10)
