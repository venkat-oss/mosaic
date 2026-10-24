load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_SDKS = {
    "linux_amd64": ("linux-amd64", "112d62c980f5447cd303a70b3dacbc09acd41ccb4ef6d154e8629f543a0f8568"),
    "linux_arm64": ("linux-arm64", "8171b4842e68a85b2e82b342d3bf7b542a88fd6666e0c18438d7b459012494ee"),
    "osx_amd64": ("osx-amd64", "7e6101ddc8de73e8dcc66f790e658e07891165d026992b40ceba20e50b01f8ec"),
    "osx_arm64": ("osx-arm64", "c3a571e6d4a0da97534c631df463ab13c07f8cf78049625f5df936b7beaab9ce"),
    "windows_amd64": ("windows-amd64", "9a7e2c1200209ea70cdf4535aa3fdf581c3a141137569462ed7b555cde49b112"),
    "windows_arm64": ("windows-arm64", "1f9ec424605b798003e9cb558d95ec70e334ad4f53260679c7cc3934bcc06dd1"),
}

def _sdk_impl(ctx):
    archive, checksum = _SDKS[ctx.attr.platform]
    ctx.download_and_extract(
        url = "https://github.com/duckdb/duckdb/releases/download/v2.0.0/duckdb-static-libs-" + archive + ".tar.gz",
        sha256 = checksum,
    )
    library = "duckdb_static.lib" if ctx.path("duckdb_static.lib").exists else "libduckdb_static.a"
    ctx.file("platform.bzl", "PLATFORM = " + repr(ctx.attr.platform) + "\n")
    ctx.file("BUILD.bazel", """
load("@rules_cc//cc:cc_import.bzl", "cc_import")
exports_files(["platform.bzl"])
cc_import(name = "static", static_library = %r, visibility = ["//visibility:public"])
""" % library)

_sdk = repository_rule(implementation = _sdk_impl, attrs = {"platform": attr.string(mandatory = True)})

def _gatekeeper_impl(ctx):
    system = {"linux": "linux", "mac os x": "osx", "windows": "windows"}.get(ctx.os.name.lower())
    machine = {"amd64": "amd64", "x86_64": "amd64", "aarch64": "arm64", "arm64": "arm64"}.get(ctx.os.arch)
    if not system or not machine:
        fail("Gatekeeper's native fixture requires a DuckDB SDK for " + ctx.os.name + "/" + ctx.os.arch)
    _sdk(name = "mosaic_gatekeeper_sdk", platform = system + "_" + machine)
    http_archive(
        name = "mosaic_gatekeeper_source",
        urls = ["https://github.com/nozzle/duckdb-gatekeeper/archive/refs/tags/v0.4.3.tar.gz"],
        sha256 = "aa659cc08727c050731c95bf5d4adc44d6f8423fc640552ff9352c11dcd86ddd",
        strip_prefix = "duckdb-gatekeeper-0.4.3",
        build_file = "//packages/server/duckdb-server-go/gatekeeper:source.BUILD.bazel",
    )
    http_archive(
        name = "mosaic_gatekeeper_duckdb",
        urls = ["https://github.com/duckdb/duckdb/archive/refs/tags/v2.0.0.tar.gz"],
        sha256 = "7e89053255046bfb26afbd7f524a2fb84df7dbef496aa911ea35e4a1182fdc00",
        strip_prefix = "duckdb-2.0.0",
        build_file = "//packages/server/duckdb-server-go/gatekeeper:duckdb.BUILD.bazel",
    )

    return ctx.extension_metadata(reproducible = True)

gatekeeper = module_extension(implementation = _gatekeeper_impl, os_dependent = True, arch_dependent = True)
