![Factorio Mod Portal mod version](https://img.shields.io/factorio-mod-portal/v/the418_kb?label=mod%20portal)
![Factorio Mod Portal mod downloads](https://img.shields.io/factorio-mod-portal/dt/the418_kb)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/the418-gg/factorio-knowledge-base/test_markup.yml?label=tests)

# Factorio knowledge base

A wiki-like system for documenting massive Factorio bases. Very raw right now, just an initial release so I can use it myself.

## Installation

[Download on the Mod Portal.](https://mods.factorio.com/mod/the418_kb)

<img src="pics/kb_512.png" width="256" />

## Running tests

```sh
cd markup
luarocks install --only-deps factoriomark-0.1.0-1.rockspec
busted tests/test.lua
```
