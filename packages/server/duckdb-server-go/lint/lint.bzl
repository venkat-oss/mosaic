load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain", "use_cc_toolchain")

def _runfile(ctx, file):
    path = file.short_path
    return path[3:] if path.startswith("../") else ctx.workspace_name + "/" + path

def _go_lint_test_impl(ctx):
    sdk = ctx.toolchains["@rules_go//go:toolchain"].sdk
    cc = find_cc_toolchain(ctx)
    args = [sdk.go, ctx.file.gopath, ctx.file.engine, ctx.file.config]
    args += ctx.files.srcs
    script = ctx.actions.declare_file(ctx.label.name + ".sh")
    runner = ctx.executable._runner
    arguments = ['"${TEST_SRCDIR}/' + _runfile(ctx, file) + '"' for file in args]
    arguments.insert(4, str(len(ctx.files.srcs)))
    arguments.append("'" + cc.compiler_executable + "'")
    for label, destination in ctx.attr.cgo_inputs.items():
        destination = destination.format(goos = sdk.goos, goarch = sdk.goarch)
        for file in label.files.to_list():
            arguments += ['"${TEST_SRCDIR}/' + _runfile(ctx, file) + '"', "'" + destination + "/" + file.basename + "'"]
    ctx.actions.write(
        output = script,
        content = "#!" + ctx.toolchains["@bazel_tools//tools/sh:toolchain_type"].path + "\nexec \"${TEST_SRCDIR}/" + _runfile(ctx, runner) + "\" " + " ".join(arguments) + "\n",
        is_executable = True,
    )
    files = args + [runner]
    for label in ctx.attr.cgo_inputs:
        files += label.files.to_list()
    runfiles = ctx.runfiles(files = files, transitive_files = depset(transitive = [sdk.srcs, sdk.tools, sdk.headers, sdk.libs, cc.all_files]))
    runfiles = runfiles.merge(ctx.attr._runner[DefaultInfo].default_runfiles)
    return [DefaultInfo(executable = script, runfiles = runfiles)]

go_lint_test = rule(
    implementation = _go_lint_test_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "config": attr.label(allow_single_file = True, mandatory = True),
        "gopath": attr.label(allow_single_file = True, mandatory = True),
        "engine": attr.label(default = "@golangci_lint//:golangci-lint", allow_single_file = True, cfg = "exec"),
        "cgo_inputs": attr.label_keyed_string_dict(allow_files = True),
        "_runner": attr.label(default = "//packages/server/duckdb-server-go/lint:runner", cfg = "exec", executable = True),
    },
    test = True,
    toolchains = ["@rules_go//go:toolchain", "@bazel_tools//tools/sh:toolchain_type"] + use_cc_toolchain(),
)
