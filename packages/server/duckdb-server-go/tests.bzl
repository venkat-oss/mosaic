load("@rules_go//go:def.bzl", "go_test")

def duckdb_go_test(name, network = False, gatekeeper = False, **kwargs):
    kwargs["visibility"] = kwargs.get("visibility", ["//packages/server/duckdb-server-go:__subpackages__"])
    if gatekeeper:
        extension = "//packages/server/duckdb-server-go/gatekeeper:extension"
        kwargs["data"] = kwargs.get("data", []) + [extension]
        kwargs["env"] = dict(kwargs.get("env", {}), MOSAIC_GATEKEEPER_EXTENSION = "$(rlocationpath " + extension + ")")
        kwargs["deps"] = kwargs.get("deps", []) + ["//packages/server/duckdb-server-go/internal/gatekeepertest"]
    tags = ["requires-network"] if network else []
    go_test(name = name, tags = tags, **kwargs)
    go_test(name = name + "_race", race = "on", tags = tags, **kwargs)
