<div align="center">

# DF HUD

**FiveM HUD fork maintained by DF Network**

[![Lua](https://img.shields.io/badge/Lua-5.4-blue?style=flat-square&logo=lua)](https://www.lua.org/)
[![FiveM](https://img.shields.io/badge/FiveM-ready-orange?style=flat-square)](https://fivem.net/)
[![Resource](https://img.shields.io/badge/Resource-df__hud-1f6feb?style=flat-square)](#important-notes)

**Languages**
[Español](docs/readme/README.es.md) ·
[English](docs/readme/README.en.md) ·
[Français](docs/readme/README.fr.md) ·
[Deutsch](docs/readme/README.de.md) ·
[Русский](docs/readme/README.ru.md) ·
[日本語](docs/readme/README.jp.md) ·
[中文](docs/readme/README.cn.md)

</div>

## Fork Status

`df_hud` is a fork and derivative work of the public repository [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud).

Original attribution kept in this fork:

- Upstream repository: `EstebanSole/hx-hud`
- Upstream credited author in the bundled `LICENSE`: `Moohja — Elixir Dev`
- Upstream license file: [`LICENSE`](https://raw.githubusercontent.com/EstebanSole/hx-hud/main/LICENSE)

Important clarification:

- The upstream README currently shows an MIT badge.
- The upstream `LICENSE` file currently states `CC BY-NC 4.0` and explicitly requires attribution.
- This fork follows the upstream `LICENSE` file for attribution purposes.

## Code Origin Estimate

Technical comparison made on **2026-06-14** against the current public `main` branch of [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud).

- Estimated code still recognizably derived from `hx-hud`: **11.9%**
- Estimated code added by DF or substantially rewritten in `df_hud`: **88.1%**

Method used for this estimate:

- Compared source files only: `.lua`, `.js`, `.css`, `.html`
- Current `df_hud`: **70 source files**, **7,453 non-empty source lines**
- Upstream `hx-hud`: **7 source files**, **3,209 non-empty source lines**


## What Changed In DF HUD

Compared to upstream `hx-hud`, this fork now includes:

- Resource identity hard-locked to `df_hud`
- Reorganized structure with `client/`, `server/`, `shared/`, `locales/`, `web/js/`
- Framework routing through `init.lua`
- Support for `qbx`, `qbcore`, `esx`, `mythic`, `nd`, `ox`, `vrp`, `vrpex`, `custom`
- Support for `ox_inventory`, `qs-inventory`, `qb-inventory`, `ps-inventory`, `codem-inventory`, `core_inventory`, `ak47_inventory`, `esx_inventory`, `esx_inventoryhud`, `origen_inventory`, `mythic-inventory`, `ND_Core`, `vrp`, `custom`
- Per-player persistence for HUD choices and manual gears preference
- Runtime startup banner, version check and custom support messaging
- Locales separated from NUI JS and expanded language support
- New `voice-simple` and `voice-original` naming
- Additional HUD, speedometer and configuration behavior beyond the original monolithic implementation

## Important Notes

- The resource folder and resource name must remain exactly `df_hud`
- If you rename the resource, startup validation will stop it intentionally
- `custom` framework and inventory modes are available for unsupported ecosystems through config hooks
- If you use a custom framework or inventory, the startup banner directs users to `discord.gg/dfnetwork` for official support requests

## Documentation

- [Español](docs/readme/README.es.md)
- [English](docs/readme/README.en.md)
- [Français](docs/readme/README.fr.md)
- [Deutsch](docs/readme/README.de.md)
- [Русский](docs/readme/README.ru.md)
- [日本語](docs/readme/README.jp.md)
- [中文](docs/readme/README.cn.md)
- [Changelog](CHANGELOG.md)

## Runtime Locale Support

Current in-resource locales:

- `es`
- `en`
- `fr`
- `de`
- `ru`
- `jp`
- `cn`

## Credit

This fork exists because of the original work published in [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud). Credit to the upstream authors and maintainers for the original base that made this fork possible.
