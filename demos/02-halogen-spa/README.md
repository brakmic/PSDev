# Halogen single-page app

A small Halogen application with state, events, and an asynchronous effect:

- `H.mkComponent` with a typed state record
- `handleAction` for increments, decrements, reset, and snapshots
- `H.liftAff` with a delay before saving a snapshot
- a browser bundle produced by `spago bundle`

## Build

```sh
spago build
mkdir -p dist
spago bundle --platform browser --outfile dist/bundle.js
```

## Serve

```sh
python3 -m http.server 8080
```

Open <http://localhost:8080>. Buttons update the counter; **Save snapshot**
waits 250 ms and then records the current value in the snapshot list.

`dist/` and the compiled `output/` directory are generated and not committed.
