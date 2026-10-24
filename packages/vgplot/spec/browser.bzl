def _environment_impl(ctx):
    image = "mcr.microsoft.com/playwright:v%s-noble" % ctx.attr.version
    ctx.file("defs.bzl", "PLAYWRIGHT_IMAGE = %s\n" % repr(image))
    ctx.file("image.mjs", "console.log(%s);\n" % repr(image))
    ctx.file("BUILD.bazel", """
load("@aspect_rules_js//js:defs.bzl", "js_binary")
exports_files(["defs.bzl"])
js_binary(
    name = "image",
    entry_point = "image.mjs",
    visibility = ["//visibility:public"],
)
""")

_environment = repository_rule(
    implementation = _environment_impl,
    attrs = {"version": attr.string(mandatory = True)},
)

def _extensions_impl(ctx):
    if ctx.os.arch in ["aarch64", "arm64"]:
        platform = "linux_arm64"
    elif ctx.os.arch in ["amd64", "x86_64"]:
        platform = "linux_amd64"
    else:
        fail("Unsupported Playwright Linux architecture: " + ctx.os.arch)
    for name in ["httpfs", "spatial"]:
        ctx.download(
            url = "https://extensions.duckdb.org/v%s/%s/%s.duckdb_extension.gz" % (ctx.attr.version, platform, name),
            output = name + ".gz",
        )
    ctx.file("BUILD.bazel", 'exports_files(["httpfs.gz", "spatial.gz"])\n')

_extensions = repository_rule(
    implementation = _extensions_impl,
    attrs = {"version": attr.string(mandatory = True)},
)

def _browser_impl(ctx):
    for module in ctx.modules:
        for tool in module.tags.playwright:
            package = json.decode(ctx.read(tool.package_json))
            _environment(name = "mosaic_browser", version = package["version"])
            duckdb = json.decode(ctx.read(tool.duckdb_package_json))
            _extensions(name = "mosaic_browser_extensions", version = duckdb["version"].split("-")[0])

browser = module_extension(
    implementation = _browser_impl,
    tag_classes = {"playwright": tag_class(attrs = {
        "package_json": attr.label(mandatory = True),
        "duckdb_package_json": attr.label(mandatory = True),
    })},
)
