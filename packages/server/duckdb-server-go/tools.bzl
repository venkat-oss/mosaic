_PLATFORMS = {
    "darwin-amd64": "767b899a28285e88ded2823d5dcc4bc5ef681173eb2d80f029a7b17ee4ece3b8",
    "darwin-arm64": "d1e409481a8ca846c4bc97e781eb5cb1bd5c23353a0b3977a1cbda1b1b6447d5",
    "linux-amd64": "9b7fe6a6bf6334b98decf8d86b11415ea7889afdabdd1959fdce23af2a9ebcea",
    "windows-amd64": "cd7ea6063c95de245e17e5246e42bdc14bb221792c429dbd239ab3a6ade6ca6a",
    "windows-arm64": "4fb8988abf186158e30af1b8a0fb3671cf2cb02bc91d7e6ce6996f4c1e922e9a",
    "linux-arm64": "b4d8f17068b35ee6060cc2f69a16fb48740d706fbba81661c318649c114a6998",
}

def _golangci_impl(ctx):
    system = "darwin" if ctx.os.name == "mac os x" else ("windows" if ctx.os.name.startswith("windows") else ctx.os.name)
    arch = {"x86_64": "amd64", "aarch64": "arm64"}.get(ctx.os.arch, ctx.os.arch)
    platform = system + "-" + arch
    if platform not in _PLATFORMS:
        fail("unsupported golangci-lint execution platform: " + platform)
    archive = "golangci-lint-2.15.0-" + platform
    ctx.download_and_extract(
        url = "https://github.com/golangci/golangci-lint/releases/download/v2.15.0/" + archive + (".zip" if system == "windows" else ".tar.gz"),
        sha256 = _PLATFORMS[platform],
        stripPrefix = archive,
    )
    binary = "golangci-lint.exe" if system == "windows" else "golangci-lint"
    ctx.file("BUILD.bazel", 'alias(name = "golangci-lint", actual = "' + binary + '", visibility = ["//visibility:public"])\n' if system == "windows" else 'exports_files(["golangci-lint"])\n')

_golangci = repository_rule(implementation = _golangci_impl)

def _go_tools_impl(ctx):
    _golangci(name = "golangci_lint")

go_tools = module_extension(implementation = _go_tools_impl)
