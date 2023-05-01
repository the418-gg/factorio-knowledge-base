# Factorio knowledge base

A wiki-like system for documenting massive Factorio bases. Very raw right now, just an initial release so I can use it myself.

## Installation

[Download on the Mod Portal.](https://mods.factorio.com/mod/the418_kb)

## Running tests

```sh
cd markup
luarocks install --only-deps factoriomark-0.1.0-1.rockspec
busted tests/test.lua
```
