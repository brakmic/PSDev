# JSON decoding with Aff

This demo shows a small typed data pipeline:

- parse a JSON document with `argonaut`
- decode it into a record with `argonaut-codecs`
- validate the decoded values and report errors as `Either String`
- fetch the same shape from a live HTTP API with `affjax` and `Aff`

## Run

```sh
npm install
spago run
```

Expected output:

```text
Munich: 18.5 C, 61% humidity, partly cloudy
```

Fetch live data from Open-Meteo instead of the embedded sample:

```sh
spago run -- --live
```

The live mode needs network access and a current Node.js runtime, both provided
by the PSDev image.

## Files

- `src/Main.purs` contains the codecs, validation, HTTP request, and report rendering.
- `package.json` supplies `xhr2`, which `affjax-node` uses for HTTP requests.
