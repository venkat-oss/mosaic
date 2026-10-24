#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"
BAZEL_FLAGS=()
[[ -z "${CI:-}" ]] || BAZEL_FLAGS+=(--config=ci)
BASE_IMAGE="$(bazelisk run "${BAZEL_FLAGS[@]}" @mosaic_browser//:image)"
IMAGE="mosaic-browser:${BASE_IMAGE##*:}-gcc"
if ! "${CONTAINER_RUNTIME:-docker}" image inspect "$IMAGE" >/dev/null 2>&1; then
  "${CONTAINER_RUNTIME:-docker}" build --build-arg BASE_IMAGE="$BASE_IMAGE" -t "$IMAGE" - <<'DOCKERFILE'
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
RUN apt-get update && apt-get install -y --no-install-recommends gcc libc6-dev && rm -rf /var/lib/apt/lists/*
DOCKERFILE
fi
VERSION="$(cat .bazelversion)"
CACHE="${MOSAIC_BROWSER_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/mosaic-browser}"
mkdir -p "$CACHE"
CACHE="$(cd "$CACHE" && pwd)"
TEST_ARGS=()
if [[ "${1:-}" == "--no-cache" ]]; then
  TEST_ARGS+=(--nocache_test_results)
  shift
fi

if [[ "${1:-}" == "--update" ]]; then
  shift
  COMMAND=(run "${BAZEL_FLAGS[@]}" //packages/vgplot/spec:browser_update -- "$@")
else
  TARGET=//:browser_tests
  [[ "$#" == 0 ]] || TARGET=//packages/vgplot/spec:browser_tests
  COMMAND=(test "${BAZEL_FLAGS[@]}" --local_test_jobs=1 "${TEST_ARGS[@]}" "$TARGET")
  for arg in "$@"; do COMMAND+=("--test_arg=$arg"); done
fi

exec "${CONTAINER_RUNTIME:-docker}" run --rm \
  --user "$(id -u):$(id -g)" \
  --memory 8g \
  -e HOME=/tmp \
  -e CI \
  -e BUILD_WORKSPACE="$REPO_ROOT" \
  -e BROWSER_CACHE="$CACHE" \
  -v "$REPO_ROOT:$REPO_ROOT" \
  -v "$CACHE:$CACHE" \
  -w "$REPO_ROOT" \
  "$IMAGE" \
  bash -euc '
    version="$1"
    shift
    arch="$(uname -m)"
    [[ "$arch" != aarch64 ]] || arch=arm64
    client="bazel-$version-linux-$arch"
    mkdir -p "$BROWSER_CACHE/bin"
    cd "$BROWSER_CACHE/bin"
    if [[ ! -x "$client" ]]; then
      base="https://github.com/bazelbuild/bazel/releases/download/$version/$client"
      curl -fsSL --retry 3 "$base" -o "$client"
      curl -fsSL --retry 3 "$base.sha256" -o "$client.sha256"
      sha256sum -c "$client.sha256"
      chmod +x "$client"
    fi
    cd "$BUILD_WORKSPACE"
    exec "$BROWSER_CACHE/bin/$client" --batch --output_user_root="$BROWSER_CACHE/bazel" --output_base="$BROWSER_CACHE/output" "$@"
  ' bash "$VERSION" "${COMMAND[@]}"
