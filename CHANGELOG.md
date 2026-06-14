# Changelog

All notable changes to `df_hud` are documented in this file.

This project is a fork of `EstebanSole/hx-hud`.
The current repository does not contain a granular public release history
for every intermediate DF modification, so the first entry below is a
**consolidated fork changelog** for the current shipped state.

Format inspired by Keep a Changelog.

## [3.0.8] - 2026-06-14

### Fork Status

- Resource renamed and maintained as `df_hud`
- Current shipped state reflects a substantial DF rewrite and expansion
  of the original `hx-hud` base
- Resource name is now enforced at runtime
- The script stops itself if it is renamed to anything other than `df_hud`

### Added

- Framework resolver in `init.lua`
- Automatic framework detection with explicit override support through
  `Config.Framework`
- Framework adapters for:
- `qbx`
- `qbcore`
- `esx`
- `mythic`
- `nd`
- `ox`
- `vrp`
- `vrpex`
- `custom`
- Inventory resolver with explicit override support through
  `Config.Inventory`
- Inventory adapters for:
- `ox_inventory`
- `qs-inventory`
- `qb-inventory`
- `ps-inventory`
- `codem-inventory`
- `core_inventory`
- `ak47_inventory`
- `esx_inventory`
- `esx_inventoryhud`
- `origen_inventory`
- `mythic-inventory`
- `ND_Core`
- `vrp`
- `custom`
- Client and server hook layers for unsupported or custom ecosystems
- Startup banner with framework, inventory, voice, manual gears, author and
  version summary
- Remote version check against
  `https://raw.githubusercontent.com/dfnetwork/df-scripts/main/version.md`
- Mandatory support notice for `custom` framework or inventory setups
- Player-level persistence for manual gears preference on the server side
- Locales registry separated from NUI JS
- Locale packs for:
- `es`
- `en`
- `fr`
- `de`
- `ru`
- `jp`
- `cn`
- Multi-language README set under `docs/readme/`
- `/cine` command to toggle cinematic mode and restore previous UI state
- Voice HUD selection with `voice-simple` and `voice-original`
- Save buttons for HUD style, speedometer style and voice style with
  preview-before-save behavior
- Drag and resize support for HUD elements from the adjustment menu
- Persistent HUD positions and sizes in NUI storage
- Manual gears starter system with:
- per-player enable/disable
- clutch input
- gear up/down inputs
- configurable ratios
- cooldown between shifts
- seatbelt sound pack and audio data files included in resource structure
- Dynamic minimap visibility checks using compatible inventory adapters
- Oxygen tracking for underwater gameplay

### Changed

- Project structure reorganized from monolithic upstream layout into:
- `client/`
- `server/`
- `shared/`
- `locales/`
- `web/js/`
- Main configuration moved into organized shared config files
- Keybinds externalized into config instead of being hard-coded in UI logic
- Locales removed from hard-coded JS strings and resolved from Lua locale
  files
- Branding changed from `hx-hud` to `df_hud`
- Legacy saved style ids are normalized automatically to preserve
  compatibility with old local storage and KVP values
- `Config.Inventory` is now the primary inventory selector
- `Config.Minimap.inventory` remains only as a legacy fallback
- Runtime banner is printed regardless of the optional debug banner toggle
  requirement introduced in previous revisions
- HUD selection workflow now keeps changes in preview state until the user
  explicitly saves them
- Manual gears can now be enabled per user from `/hud` instead of forcing
  the whole server into manual mode
- README rewritten to document the fork, upstream attribution, language
  support and code-origin estimate

### UI and UX

- HUD styles were reworked to stay horizontal instead of vertical
- `simple` and `original` voice/speedometer presentations were aligned
  with the intended horizontal layout direction
- Adjustment panel now supports both movement and resizing
- Save buttons remain visible when there are pending changes
- Armor can disappear without leaving an empty gap in the stats row
- HUD layout reacts to minimap state so the stat row can shift left when
  radar space is unavailable or hidden
- Cinema bars are configurable and synchronized through NUI settings
- Pause-state handling added to hide UI cleanly when needed

### Compatibility

- `qbx_core` is no longer the only expected framework path
- Support expanded beyond QBox to QBCore, ESX and additional ecosystems
  listed above
- Resource now supports more than the original `ox_inventory`-only minimap
  item flow
- `custom` framework and `custom` inventory modes allow integrators to
  bridge unsupported servers without editing the core

### Fixed

- Fixed HUD style selection closing the UI before the user chose to save
- Fixed broken save flow by separating preview state from committed state
- Fixed multiple styles that were rendering vertically instead of horizontally
- Fixed several default HUD styles that had drifted away from the expected
  base presentation
- Fixed armor leaving a visual gap when the player had no armor
- Fixed minimap/stat overlap cases in horizontal layouts
- Fixed radar state synchronization while toggling hidden HUD and cinema
  mode
- Fixed legacy style persistence after the `samy/origen` to
  `simple/original` rename
- Fixed manual gears preference not being isolated to each player
- Fixed invalid resource-name scenarios by stopping the resource early
  with a clear startup message
- Fixed stamina behavior so it no longer refills to `100` when the player
  holds `Shift` while standing still
- Fixed stamina behavior so sprint usage now depends on actual movement
  instead of only the sprint key being pressed

### Internal

- Added client and server inventory helper layers in `00_common.lua`
- Added framework-specific subfolders for cleaner separation
- Added server-side persistence file for manual gears preferences
- Added startup diagnostics and version comparison helpers
- Added compatibility aliases for known alternative resource names
- Expanded locale keys for startup diagnostics and resource-name
  enforcement

### Documentation

- Added root `README.md` focused on fork status and attribution
- Added per-language README variants
- Documented upstream attribution and current code-origin estimate
- Clarified that the resource must remain named `df_hud`

### Notes

- Because older DF changes were not published in this repository as
  isolated tagged releases, `3.0.8` acts as the first consolidated
  changelog entry for the current DF fork state
- Upstream attribution remains documented in the README and should be
  preserved in future releases
