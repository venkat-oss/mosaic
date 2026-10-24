"""CUE projections with complete admission and declared module inputs."""

load("@rules_cue//cue:cue.bzl", "CUEInstanceInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

_CUE_TOOLCHAIN = "@rules_cue//tools/cue:toolchain_type"

def _cue_sources_impl(ctx):
    files = depset(transitive = [target[CUEInstanceInfo].transitive_files for target in ctx.attr.instances])
    return [DefaultInfo(files = files, runfiles = ctx.runfiles(transitive_files = files))]

cue_sources = rule(
    implementation = _cue_sources_impl,
    attrs = {"instances": attr.label_list(providers = [CUEInstanceInfo])},
)

def _cue_binary_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".bin")
    ctx.actions.symlink(
        output = output,
        target_file = ctx.toolchains[_CUE_TOOLCHAIN].cueinfo.tool,
        is_executable = True,
    )
    return [DefaultInfo(executable = output)]

cue_binary = rule(
    implementation = _cue_binary_impl,
    executable = True,
    toolchains = [_CUE_TOOLCHAIN],
)

def _cue_resources(os_name, input_count):
    return {"cpu": 2, "memory": 8192}

def _cue_projection_impl(ctx):
    instance = ctx.attr.instance[CUEInstanceInfo]
    tool = ctx.toolchains[_CUE_TOOLCHAIN].cueinfo.tool
    output = ctx.actions.declare_file(ctx.label.name + ".json")
    module_file = instance.module.module_file
    module_runfile = module_file.short_path[3:] if module_file.short_path.startswith("../") else ctx.workspace_name + "/" + module_file.short_path
    module_root = paths.dirname(paths.dirname(module_runfile))
    package_relative = "." if instance.directory_path == module_root else paths.relativize(instance.directory_path, module_root)
    package_path = paths.join(paths.dirname(paths.dirname(module_file.path)), package_relative)
    arguments = [
        tool.path,
        "./" + package_path + ":" + instance.package_name,
        ctx.attr.expression,
        output.path,
    ]
    arguments.extend([file.path for file in ctx.files.srcs])
    for path in ctx.attr.path:
        arguments.extend(["--path", path])
    ctx.actions.run_shell(
        command = """cue_tool="$1"
cue_package="$2"
cue_expression="$3"
cue_output="$4"
shift 4
"$cue_tool" vet -c "$cue_package" "$@" &&
"$cue_tool" export "$cue_package" "$@" --expression "$cue_expression" --out json --outfile "$cue_output"
""",
        arguments = arguments,
        inputs = depset(ctx.files.srcs, transitive = [instance.transitive_files]),
        tools = [tool],
        outputs = [output],
        env = {"CUE_CACHE_DIR": ".cue-cache", "CUE_REGISTRY": "none"},
        mnemonic = "CUEProjection",
        progress_message = "Validating and projecting CUE %{label}",
        resource_set = _cue_resources,
    )
    return [DefaultInfo(files = depset([output]))]

cue_projection = rule(
    implementation = _cue_projection_impl,
    attrs = {
        "instance": attr.label(providers = [CUEInstanceInfo], mandatory = True),
        "srcs": attr.label_list(allow_files = True),
        "expression": attr.string(mandatory = True),
        "path": attr.string_list(),
    },
    toolchains = [_CUE_TOOLCHAIN],
)
