# Python development

Bazel owns builds and checks. Run `bazelisk test //packages/vgplot/vgplot-python:check`
and build its `:wheel` or `:sdist` targets to exercise installed consumers.

Public helper contracts are moving into their owning CUE families under `api/`.
Validate each family through its `:contribution` target; ordinary builds consume
the committed bindings. The schema-derived Python generator is retired as its
implementations move to family modules. Whole-API synchronization is introduced
with root composition after all families have an owner.
