load("@rules_python//python:py_test.bzl", "py_test")
load("@rules_python//python:packaging.bzl", "py_package", "py_wheel")
load("@rules_python//python/private:version.bzl", python_version = "version")

def _node_runtime_impl(ctx):
    node = ctx.attr.runtime[platform_common.ToolchainInfo].nodeinfo.node
    return [DefaultInfo(files = depset([node]), runfiles = ctx.runfiles(files = [node]))]

node_runtime = rule(
    implementation = _node_runtime_impl,
    attrs = {"runtime": attr.label(default = Label("@rules_nodejs//nodejs:current_node_runtime"))},
)

def _wheel_binary_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.run(
        executable = ctx.executable._extractor,
        inputs = [ctx.file.wheel],
        outputs = [output],
        arguments = [ctx.file.wheel.path, ctx.attr.binary, output.path],
        mnemonic = "PythonWheelBinary",
    )
    return [DefaultInfo(files = depset([output]), executable = output)]

wheel_binary = rule(
    implementation = _wheel_binary_impl,
    executable = True,
    attrs = {
        "binary": attr.string(mandatory = True),
        "wheel": attr.label(mandatory = True, allow_single_file = True, cfg = "exec"),
        "_extractor": attr.label(default = Label("//build/python:wheel_binary"), executable = True, cfg = "exec"),
    },
)

def _sdist_impl(ctx):
    output = ctx.actions.declare_file(ctx.attr.filename)
    prefix = ctx.label.package + "/"
    sources = {file.path: file.short_path.removeprefix(prefix) for file in ctx.files.srcs}
    ctx.actions.run(
        executable = ctx.executable._builder,
        inputs = ctx.files.srcs,
        outputs = [output],
        arguments = [output.path, json.encode(sources)],
        mnemonic = "PythonSdist",
    )
    return [DefaultInfo(files = depset([output]))]

_python_sdist = rule(
    implementation = _sdist_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "filename": attr.string(mandatory = True),
        "_builder": attr.label(default = Label("//build/python:sdist"), executable = True, cfg = "exec"),
    },
)

def python_sdist(srcs, metadata):
    _python_sdist(
        name = "sdist",
        srcs = srcs,
        filename = metadata["distribution"].replace("-", "_") + "-" + python_version.normalize(metadata["version"]) + ".tar.gz",
        visibility = ["//visibility:public"],
    )

def pytest_suite(name, srcs, deps, data = [], support = [], args = [], size = "medium", deps_by_test = {}, data_by_test = {}, env_by_test = {}):
    tests = []
    for source in srcs:
        target = source.split("/")[-1][:-3]
        py_test(
            name = target,
            srcs = [source, "//build/python:pytest_runner.py"] + support,
            main = "//build/python:pytest_runner.py",
            args = ["$(rlocationpath " + source + ")"] + args,
            data = data + data_by_test.get(source, []),
            deps = deps + deps_by_test.get(source, []) + ["@pypi//pytest", "@rules_python//python/runfiles"],
            env = env_by_test.get(source, {}),
            legacy_create_init = False,
            size = size,
        )
        tests.append(":" + target)
    native.test_suite(name = name, tests = tests, visibility = ["//visibility:public"])

def python_wheel(name, package, deps, metadata, data = [], runtime_deps = []):
    py_package(
        name = name + "_files",
        packages = [native.package_name() + "/" + package],
        deps = deps,
    )
    py_wheel(
        name = name,
        deps = [":" + name + "_files"] + data,
        strip_path_prefixes = [native.package_name()],
        stamp = 0,
        visibility = ["//visibility:public"],
        **metadata
    )

    for artifact in [name, "sdist"]:
        py_test(
            name = artifact + "_test",
            srcs = ["//build/python:wheel_test.py"],
            main = "//build/python:wheel_test.py",
            args = [
                "$(rlocationpath :" + artifact + ")",
                "$(rlocationpath pyproject.toml)",
                "$(rlocationpath package.json)",
                "$(rlocationpath " + metadata["description_file"] + ")",
                package,
            ],
            data = [":" + artifact, "pyproject.toml", "package.json", metadata["description_file"]],
            deps = runtime_deps + ["@pypi//installer", "@pypi//packaging", "@rules_python//python/runfiles"] + (["@pypi//hatchling"] if artifact == "sdist" else []),
            legacy_create_init = False,
            visibility = ["//visibility:public"],
        )

def python_checks(srcs, deps, project = "pyproject.toml"):
    for name, tool, options in [
        ("ruff", "ruff", ["check", "--no-fix", "--no-cache", "--config", "$(rlocationpath //:pyproject.toml)"]),
        ("format", "ruff", ["format", "--check", "--no-cache", "--config", "$(rlocationpath //:pyproject.toml)"]),
        ("typecheck", "ty", ["check"]),
    ]:
        py_test(
            name = name,
            srcs = ["//build/python:tool_test.py"],
            main = "//build/python:tool_test.py",
            args = ["$(rlocationpath //build/python:" + tool + ")"] + options + ["$(rlocationpath " + source + ")" for source in srcs],
            data = srcs + ["//build/python:" + tool, "//:pyproject.toml", project],
            deps = (deps + ["@pypi//pytest"] if tool == "ty" else []) + ["@rules_python//python/runfiles"],
            legacy_create_init = False,
            visibility = ["//visibility:public"],
        )
    native.test_suite(name = "lint", tests = [":ruff", ":format"], visibility = ["//visibility:public"])
