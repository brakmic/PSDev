# PSDev

A PureScript development image with the compiler, build tooling, editor
support, and a C++ toolchain for native interop.

## Included tools

| Tool | Version |
| --- | --- |
| PureScript compiler | 0.15.16 |
| Spago | 1.0.5 |
| purescript-language-server | 0.18.5 |
| purs-tidy | 0.11.1 |
| purs-backend-es | 1.4.3 |
| esbuild | 0.28.2 |
| Node.js | 24 |
| npm | bundled with Node.js |
| node-gyp | 13.1.0 |
| GCC | 13.3 |
| Base image | Ubuntu 24.04 |

The compiler is installed from the official release archive and verified with a
pinned SHA-256 digest for `amd64` and `arm64`. Spago and the editor tools are
installed from npm with pinned versions.

## Quick start

```sh
docker run --rm -it -v "${PWD}:/workspace" brakmic/psdev:latest
```

Start a new project inside the container:

```sh
spago init --name my-app
spago run
```

The image runs as the non-root user `psdev` (UID 1000) and has passwordless
`sudo`.

## Demos

| Demo | What it shows |
| --- | --- |
| `demos/01-json-aff` | Typed JSON decoding, validation, and an `Aff` HTTP request |
| `demos/02-halogen-spa` | Halogen component with state, events, and an asynchronous effect |
| `demos/03-ffi-cpp` | PureScript FFI over a C++ N-API addon, with timings |
| `demos/04-typed-calculator` | Prisms, variants, row types, type classes, `spec`, and QuickCheck |

Open a demo folder as the workspace and run the commands in its README. All
demos build and run inside the image.

### PureScript and C++

PureScript compiles to JavaScript, so C++ code is reached through the foreign
function interface and a JavaScript boundary. The FFI demo uses a Node.js N-API
addon built with `node-gyp`, the same mechanism used by native Node packages.
WebAssembly is a later option for code that must also run in browsers.

## Dev container

The repository includes `.devcontainer/devcontainer.json`. In VS Code, run
**Dev Containers: Reopen in Container** and the image is built from the local
Dockerfile. The PureScript IDE extension and the C++ toolchain are available
inside the container.

## Build the image

```sh
docker build -t psdev .
```

For both architectures:

```sh
docker buildx build --platform linux/amd64,linux/arm64 -t psdev .
```

## Publishing

The release workflow publishes to GHCR and Docker Hub when a `v*` tag is pushed
that matches the PureScript version in the Dockerfile. Docker Hub automated
builds are not used; GitHub Actions is the only publisher.

Repository secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

When the compiler version changes, update `PURESCRIPT_VERSION` and both
`PURS_SHA256_*` values in the Dockerfile before tagging.

## License

MIT
