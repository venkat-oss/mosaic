_SDKS = {
    "linux_amd64": ("linux-amd64", "993ad89e7dfca66cd6da994c2cad090c2fc160ddf9f550498a098ab4bb13cfb1"),
    "linux_arm64": ("linux-arm64", "c60eecf91143ca6bbac55c4f4d40dc22520488b0ac257c86e0fe9a2b451cf2b7"),
    "osx_amd64": ("osx-amd64", "98fef9fcad856555ca0403fe4d9d6680acfd26c67e8c6f004d61a248d6bc0eff"),
    "osx_arm64": ("osx-arm64", "c35d60080b31ba5d11a3ce505a6831be784f003b4c575d32a4c2badb3b41cdf0"),
    "windows_amd64": ("windows-amd64", "2b83169128239de5f45fe21de80f99bf436e53aa4bb24020dd951a1ba8d4b95f"),
    "windows_arm64": ("windows-arm64", "159ce60eb587112b8c5f290b8beea56af5f13be4d13679de127ad9bfaafb7447"),
}

def _shared_impl(ctx):
    archive, checksum = _SDKS[ctx.attr.platform]
    ctx.download_and_extract(
        url = "https://github.com/duckdb/duckdb/releases/download/v2.0.0/duckdb-shared-libs-" + archive + ".tar.gz",
        sha256 = checksum,
    )
    libraries = [name for name in ["libduckdb.so", "libduckdb.dylib", "duckdb.dll", "libduckdb.dll"] if ctx.path(name).exists]
    if len(libraries) != 1:
        fail("Expected one DuckDB shared library, found " + repr(libraries))
    interface = ""
    if ctx.attr.platform.startswith("windows"):
        candidates = [name for name in ["duckdb.lib", "libduckdb.lib", "duckdb.dll.a", "libduckdb.dll.a"] if ctx.path(name).exists]
        if len(candidates) != 1:
            fail("Expected one DuckDB import library, found " + repr(candidates))
        interface = ", interface_library = " + repr(candidates[0])
    ctx.file("BUILD.bazel", """
load("@rules_cc//cc:cc_import.bzl", "cc_import")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
package(default_visibility = ["//visibility:public"])
exports_files(["duckdb.h"])
filegroup(name = "files", srcs = glob(["*.h", "*.so", "*.dylib", "*.dll", "*.lib", "*.a"], allow_empty = True))
cc_import(name = "native", shared_library = %r%s)
cc_library(name = "duckdb", deps = [":native"], hdrs = glob(["*.h"]), includes = ["."], data = [%r])
""" % (libraries[0], interface, libraries[0]))

_shared = repository_rule(implementation = _shared_impl, attrs = {"platform": attr.string(mandatory = True)})

def _duckdb_impl(ctx):
    system = {"linux": "linux", "mac os x": "osx", "windows": "windows"}.get(ctx.os.name.lower())
    machine = {"amd64": "amd64", "x86_64": "amd64", "aarch64": "arm64", "arm64": "arm64"}.get(ctx.os.arch)
    if not system or not machine:
        fail("DuckDB has no shared SDK for " + ctx.os.name + "/" + ctx.os.arch)
    _shared(name = "mosaic_duckdb_sdk", platform = system + "_" + machine)
    return ctx.extension_metadata(reproducible = True)

duckdb = module_extension(implementation = _duckdb_impl, os_dependent = True, arch_dependent = True)
