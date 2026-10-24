load("@toml.bzl", "toml")

def _metadata_impl(ctx):
    ctx.file("BUILD.bazel", "exports_files([\"projects.bzl\"])\n")
    ctx.file("projects.bzl", "PROJECTS = " + ctx.attr.projects + "\n")

_metadata = repository_rule(
    implementation = _metadata_impl,
    attrs = {"projects": attr.string(mandatory = True)},
)

def _projects_impl(ctx):
    projects = {}
    for module in ctx.modules:
        for project in module.tags.project:
            if project.name in projects:
                fail("Duplicate Python project: " + project.name)
            manifest = json.decode(ctx.read(project.package_json))
            metadata = toml.decode(ctx.read(project.pyproject))["project"]
            projects[project.name] = {
                "distribution": metadata["name"],
                "version": manifest["version"],
                "summary": metadata["description"],
                "description_file": metadata["readme"],
                "python_requires": metadata["requires-python"],
                "requires": metadata.get("dependencies", []),
                "homepage": metadata.get("urls", {}).get("homepage", ""),
                "entry_points": {"console_scripts": [name + " = " + value for name, value in sorted(metadata.get("scripts", {}).items())]},
            }
    _metadata(name = "python_projects", projects = repr(projects))

projects = module_extension(
    implementation = _projects_impl,
    tag_classes = {
        "project": tag_class(attrs = {
            "name": attr.string(mandatory = True),
            "pyproject": attr.label(mandatory = True),
            "package_json": attr.label(mandatory = True),
        }),
    },
)
