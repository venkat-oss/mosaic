load("@python_projects//:projects.bzl", "PROJECTS")
load("@rules_python//python:py_library.bzl", "py_library")
load("@rules_python//python/entry_points:py_console_script_binary.bzl", "py_console_script_binary")
load(":defs.bzl", "pytest_suite", "python_wheel", "python_checks", "python_sdist")

def mosaic_widget_python(bundle):
    native.exports_files(["pyproject.toml", "package.json"])
    py_library(
        name = "mosaic_widget_sources",
        srcs = native.glob(["mosaic_widget/**/*.py"], exclude = ["mosaic_widget/tests/**"]),
        imports = ["."],
        deps = [
            "@pypi//anywidget",
            "@pypi//duckdb",
            "@pypi//narwhals",
            "@pypi//pyarrow",
            "@pypi//traitlets",
            "@pypi//typing_extensions",
        ],
        visibility = ["//visibility:public"],
    )
    py_library(
        name = "mosaic_widget",
        deps = [":mosaic_widget_sources"],
        data = [bundle],
        visibility = ["//visibility:public"],
    )
    pytest_suite(
        name = "python_tests",
        srcs = native.glob(["mosaic_widget/tests/test_*.py"]),
        support = native.glob(["mosaic_widget/tests/conftest.py", "mosaic_widget/tests/__init__.py"]),
        data = ["//:pyproject.toml", "pyproject.toml"],
        data_by_test = {"mosaic_widget/tests/test_frame_interop.py": ["//:data/seattle-weather.csv"]},
        deps = [
            ":mosaic_widget",
            "@pypi//dask",
            "@pypi//ibis_framework",
            "@pypi//pandas",
            "@pypi//polars",
            "@pypi//pyarrow_hotfix",
        ],
        args = ["-q"],
    )
    python_wheel(
        name = "wheel",
        package = "mosaic_widget",
        deps = [":mosaic_widget"],
        metadata = PROJECTS["widget"],
        runtime_deps = ["@pypi//anywidget", "@pypi//duckdb", "@pypi//narwhals", "@pypi//pyarrow", "@pypi//traitlets", "@pypi//typing_extensions"],
    )

    python_checks(
        srcs = native.glob(["mosaic_widget/**/*.py"]),
        deps = [":mosaic_widget_sources", "@pypi//pandas", "@pypi//polars", "@pypi//ibis_framework", "@pypi//dask", "@pypi//pyarrow_hotfix"],
    )

    python_sdist(
        srcs = native.glob(["mosaic_widget/**"], exclude = ["**/__pycache__/**", "mosaic_widget/static/**"]) + [bundle, "pyproject.toml", "package.json", "README.md"],
        metadata = PROJECTS["widget"],
    )
    native.test_suite(
        name = "python_check",
        tests = [":python_tests", ":lint", ":typecheck", ":wheel_test", ":sdist_test"],
        visibility = ["//visibility:public"],
    )
    py_console_script_binary(
        name = "notebook",
        pkg = "@pypi//jupyterlab",
        script = "jupyter-lab",
        deps = [":mosaic_widget", "//packages/vgplot/vgplot-python:vgplot", "@pypi//pyyaml"],
        legacy_create_init = False,
        visibility = ["//visibility:public"],
    )
