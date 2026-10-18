# PureScript to C++ through an N-API addon

PureScript compiles to JavaScript, so C++ interop goes through the foreign
function interface and a JavaScript boundary. This demo uses a Node.js N-API
addon built with `node-gyp`:

```text
PureScript (Effect Int)
    -> src/Main.js (foreign import)
        -> build/Release/psdev_ffi.node (C++ addon)
```

The addon counts primes below a limit with a native sieve. `src/Main.purs`
contains the same algorithm in PureScript, runs both, checks that the results
agree, and prints timings.

## Build and run

```sh
npm install
spago run
```

`npm install` triggers `node-gyp rebuild` and downloads the matching Node.js
headers. The demo requires the C++ toolchain and Python 3 that the PSDev image
provides.

Expected output on a current machine:

```text
limit: 100000
C++ N-API:  9592 primes in 0.29 ms
PureScript: 9592 primes in 456.34 ms
```

Exact timings vary by machine; the prime count must match.

## Files

- `src/addon.cpp` implements the native addon.
- `binding.gyp` describes the addon build.
- `src/Main.js` is the foreign module for `Main.purs`.
- `src/Main.purs` declares the foreign imports and runs the comparison.
