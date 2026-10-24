load("@aspect_rules_js//npm:defs.bzl", "npm_package")
load("@aspect_rules_js//js:defs.bzl", "js_library", "js_run_binary", "js_test")
load("@npm//:vitest/package_json.bzl", vitest_bin = "bin")
load("@npm//:eslint/package_json.bzl", eslint_bin = "bin")
load("@aspect_rules_ts//ts:defs.bzl", "ts_config", "ts_project")
load("@npm//:defs.bzl", "npm_link_all_packages")
load("@bazel_lib//lib:copy_file.bzl", "copy_file")

def mosaic_package_test(package, packages, links):
    links = links | {
        "@polyglot-sql/sdk": "//packages/mosaic/sql:node_modules/@polyglot-sql/sdk",
        "@types/emscripten": "//packages/mosaic/core:node_modules/@types/emscripten",
    }
    js_test(
        name = "package_test",
        entry_point = "//build:npm_render_entry",
        args = [package],
        data = packages.values() + links.values() + [
            "//build:npm_render_entry",
            "//:node_modules/jsdom",
            "//:tsc",
            "@pnpm//:pnpm",
        ],
        env = {
            "MOSAIC_PACKAGES": json.encode({name: "$(rlocationpath " + label + ")" for name, label in packages.items()}),
            "MOSAIC_LINKS": json.encode({name: Label(label).package + "/" + Label(label).name for name, label in links.items()}),
            "PNPM_BIN": "$(rlocationpath @pnpm//:pnpm)",
            "TSC_BIN": "$(rlocationpath //:tsc)",
        },
        patch_node_fs = False,
    )

def mosaic_javascript(deps = [], extra_files = [], emit_declaration_only = False, tests = False, test_deps = [], test_data = [], test_env = {}, consumer_tests = []):
    npm_link_all_packages(name = "node_modules")

    js_library(
        name = "manifest",
        srcs = ["package.json"],
        visibility = ["//visibility:public"],
    )

    js_library(
        name = "sources",
        srcs = ["package.json"] + native.glob(["src/**"]),
        deps = deps,
        visibility = ["//visibility:public"],
    )

    native.filegroup(
        name = "api_sources",
        srcs = native.glob(["src/**"]),
        visibility = ["//visibility:public"],
    )

    ts_config(
        name = "tsconfig",
        src = "tsconfig.json",
        deps = ["//:tsconfig_base"],
    )
    sources = native.glob(["src/**/*.js", "src/**/*.ts"], allow_empty = True)
    ts_project(
        name = "types",
        srcs = ["package.json"] + sources,
        tsconfig = {
            "references": [],
            "compilerOptions": {"tsBuildInfoFile": "dist/tsconfig.tsbuildinfo"},
        },
        extends = ":tsconfig",
        allow_js = True,
        composite = True,
        declaration = True,
        declaration_map = True,
        emit_declaration_only = emit_declaration_only,
        source_map = True,
        root_dir = ".",
        out_dir = "dist",
        ts_build_info_file = "dist/tsconfig.tsbuildinfo",
        tsc = "//:tsc",
        transpiler = "tsc",
        supports_workers = 0,
        deps = deps,
        visibility = ["//visibility:public"],
    )

    copy_file(
        name = "license",
        src = "//:LICENSE",
        out = "LICENSE",
        allow_symlink = True,
    )

    npm_package(
        name = "pkg",
        srcs = ["package.json", ":types", ":license"] + extra_files + native.glob(["src/**", "bin/**", "README*"], allow_empty = True),
        visibility = ["//visibility:public"],
    )

    npm_package(
        name = "pack_workspace",
        srcs = [":pkg", "//:workspace_metadata"],
        root_paths = [""],
        include_srcs_packages = ["**"],
        exclude_srcs_patterns = [native.package_name() + "/package.json", "**/node_modules/**"],
        replace_prefixes = {native.package_name() + "/pkg": native.package_name()},
        include_transitive_sources = False,
    )

    js_run_binary(
        name = "tarball",
        tool = "//build:npm_pack",
        srcs = [":pack_workspace"],
        outs = ["pkg.tgz"],
        args = ["../../../$(execpath :pack_workspace)", "../../../$(RULEDIR)/pkg.tgz", native.package_name()],
        use_execroot_entry_point = False,
        patch_node_fs = False,
        visibility = ["//visibility:public"],
    )

    if tests:
        js_library(
            name = "test_sources",
            srcs = native.glob(["test/**", "vitest.config.*"]),
            deps = [":sources", ":node_modules", "//:javascript_test_support"] + test_deps,
            testonly = True,
        )
        vitest_bin.vitest_test(
            name = "runtime_test",
            args = ["run", "--maxWorkers=4", "--config", "vitest.config.ts"],
            chdir = native.package_name(),
            data = [":test_sources"] + test_data,
            tags = ["requires-network"],
            env = test_env,
            copy_data_to_bin = False,
        )
        eslint_bin.eslint_test(
            name = "lint",
            args = ["src", "test"],
            chdir = native.package_name(),
            data = [":test_sources"],
        )
        ts_config(
            name = "test_tsconfig",
            src = "test/tsconfig.json",
            deps = [":tsconfig"],
        )
        ts_project(
            name = "test_types",
            srcs = ["package.json"] + sources + native.glob(["test/**/*.ts", "test/**/*.js"], allow_empty = True),
            tsconfig = {"references": [], "compilerOptions": {"composite": False, "incremental": False, "noEmit": True, "emitDeclarationOnly": False, "rootDir": "."}},
            extends = ":test_tsconfig",
            allow_js = True,
            no_emit = True,
            out_dir = "dist",
            declaration = True,
            declaration_map = True,
            source_map = True,
            root_dir = ".",
            tsc = "//:tsc",
            supports_workers = 0,
            deps = deps + test_deps + [":node_modules", "//:node_modules/vitest", "//:node_modules/@typescript/native"],
            testonly = True,
        )
        native.test_suite(
            name = "check",
            tests = [":runtime_test", ":lint", ":test_types_typecheck_test"] + consumer_tests,
            visibility = ["//visibility:public"],
        )
