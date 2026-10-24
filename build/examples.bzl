load("@aspect_rules_js//js:defs.bzl", "js_binary", "js_library", "js_run_binary")
load("@npm//:defs.bzl", "npm_link_all_packages")

def mosaic_example():
    npm_link_all_packages(name = "node_modules")
    js_library(
        name = "manifest",
        srcs = ["package.json"],
        visibility = ["//visibility:public"],
    )
    js_library(
        name = "sources",
        srcs = native.glob(["src/**", "public/**", "*.json", "*.js", "*.html"]),
        deps = [":node_modules"],
    )
    js_run_binary(
        name = "build",
        tool = "//build:example_builder",
        srcs = [":sources"],
        args = [native.package_name(), "$(RULEDIR)/dist"],
        copy_srcs_to_bin = False,
        out_dirs = ["dist"],
        patch_node_fs = False,
        visibility = ["//visibility:public"],
    )
    for mode in ["dev", "preview"]:
        js_binary(
            name = mode,
            entry_point = "//build:example_builder_source",
            args = [native.package_name(), ".", mode],
            data = [":sources", "//:node_modules/vite"] + ([":build"] if mode == "preview" else []),
            patch_node_fs = False,
            visibility = ["//visibility:public"],
        )
