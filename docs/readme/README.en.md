# DF HUD

## Summary

`df_hud` is a fork of the public repository [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud), maintained by DF Network and expanded to support more frameworks, inventories, persistence, locales, and a far more modular internal structure.

## Fork and attribution

- Base repository: `EstebanSole/hx-hud`
- Author credited in the upstream `LICENSE`: `Moohja — Elixir Dev`
- Upstream license used for attribution reference: [`CC BY-NC 4.0`](https://raw.githubusercontent.com/EstebanSole/hx-hud/main/LICENSE)

Important note:

- The upstream README displays an MIT badge.
- The upstream `LICENSE` file states `CC BY-NC 4.0`.
- This fork documents attribution according to the upstream `LICENSE` file.

## Code origin estimate

Technical comparison performed on **2026-06-14** against the public `main` branch of `hx-hud`.

- Code still recognizably derived from `hx-hud`: **11.9%**
- Code added by DF or substantially rewritten in `df_hud`: **88.1%**

Methodology:

- Source code only was compared: `.lua`, `.js`, `.css`, `.html`
- Current `df_hud`: **70 source files**, **7,453 non-empty lines**
- Upstream `hx-hud`: **7 source files**, **3,209 non-empty lines**
- Each current file was matched to its best textual similarity candidate in upstream and weighted by non-empty line count

This number is a **technical approximation** for documentation clarity. It is **not** a legal ruling on authorship, copyright, or license scope.

## What DF HUD adds

- Resource identity locked to `df_hud`
- Reorganized structure with `client/`, `server/`, `shared/`, `locales/`, `web/js/`
- `init.lua` framework and inventory resolver
- Support for `qbx`, `qbcore`, `esx`, `mythic`, `nd`, `ox`, `vrp`, `vrpex`, `custom`
- Support for `ox_inventory`, `qs-inventory`, `qb-inventory`, `ps-inventory`, `codem-inventory`, `core_inventory`, `ak47_inventory`, `esx_inventory`, `esx_inventoryhud`, `origen_inventory`, `mythic-inventory`, `ND_Core`, `vrp`, `custom`
- Per-player persistence for HUD configuration, styles, and manual gears
- Startup banner, version check, and custom support warnings
- Locale files separated from NUI JS with broader language coverage
- New `voice-simple` and `voice-original` identifiers
- Considerably more compatibility and runtime logic than the original monolithic implementation

## Available languages

- `es`
- `en`
- `fr`
- `de`
- `ru`
- `jp`
- `cn`

## Installation notes

- The resource folder must be named exactly `df_hud`
- Use `ensure df_hud` in `server.cfg`
- If you rename the resource, startup validation will stop it
- If you use `custom` framework or inventory mode, configure its hooks in `shared/config/core.lua`

## Links

- Root README: [README.md](../../README.md)
- Spanish: [README.es.md](README.es.md)
- French: [README.fr.md](README.fr.md)
- German: [README.de.md](README.de.md)
- Russian: [README.ru.md](README.ru.md)
- Japanese: [README.jp.md](README.jp.md)
- Chinese: [README.cn.md](README.cn.md)
