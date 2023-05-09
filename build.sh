#!/usr/bin/env bash
set -e

cargo build --target wasm32-wasi --release --manifest-path hello-cardano/Cargo.toml

wasm-tools component new ./hello-cardano/target/wasm32-wasi/release/hello_cardano.wasm -o hello-cardano.wasm --adapt ./wasi_snapshot_preview1.wasm

echo "wasm binary written to ./hello-cardano.wasm"
