# DF HUD

## Zusammenfassung

`df_hud` ist ein Fork des offentlichen Repositories [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud), gepflegt von DF Network und deutlich erweitert um mehr Frameworks, Inventare, Persistenz, Sprachen und eine wesentlich modularere interne Struktur.

## Fork und Attributierung

- Basis-Repository: `EstebanSole/hx-hud`
- Im upstream-`LICENSE` genannter Autor: `Moohja — Elixir Dev`
- Fuer die Attributierung beruecksichtigte upstream-Lizenz: [`CC BY-NC 4.0`](https://raw.githubusercontent.com/EstebanSole/hx-hud/main/LICENSE)

Wichtiger Hinweis:

- Das upstream-README zeigt ein MIT-Badge.
- Die upstream-Datei `LICENSE` nennt `CC BY-NC 4.0`.
- Dieser Fork dokumentiert die Attributierung anhand der upstream-`LICENSE`.

## Schaetzung zur Code-Herkunft

Technischer Vergleich vom **2026-06-14** mit dem oeffentlichen `main`-Branch von `hx-hud`.

- Code, der noch klar als von `hx-hud` abgeleitet erkennbar ist: **11.9%**
- Von DF hinzugefuegter oder wesentlich umgeschriebener Code in `df_hud`: **88.1%**

Methodik:

- Verglichen wurde nur Quellcode: `.lua`, `.js`, `.css`, `.html`
- Aktuelles `df_hud`: **70 Quelldateien**, **7,453 nicht-leere Zeilen**
- Upstream `hx-hud`: **7 Quelldateien**, **3,209 nicht-leere Zeilen**
- Jede aktuelle Datei wurde mit ihrem besten textuellen Treffer im Upstream verglichen und nach nicht-leeren Zeilen gewichtet

Diese Zahl ist eine **technische Annaeherung** fuer die Dokumentation. Sie ist **keine** rechtliche Entscheidung zu Urheberschaft, Copyright oder Lizenzumfang.

## Was DF HUD hinzufuegt

- Ressourcenname fest auf `df_hud` gesetzt
- Neu organisierte Struktur mit `client/`, `server/`, `shared/`, `locales/`, `web/js/`
- `init.lua` fuer Framework- und Inventar-Aufloesung
- Unterstuetzung fuer `qbx`, `qbcore`, `esx`, `mythic`, `nd`, `ox`, `vrp`, `vrpex`, `custom`
- Unterstuetzung fuer `ox_inventory`, `qs-inventory`, `qb-inventory`, `ps-inventory`, `codem-inventory`, `core_inventory`, `ak47_inventory`, `esx_inventory`, `esx_inventoryhud`, `origen_inventory`, `mythic-inventory`, `ND_Core`, `vrp`, `custom`
- Pro-Spieler-Persistenz fuer HUD-Einstellungen, Styles und manuelle Gaenge
- Start-Banner, Versionspruefung und Hinweise fuer Custom-Support
- Vom NUI-JS getrennte Locale-Dateien mit erweiterter Sprachenabdeckung
- Neue Bezeichner `voice-simple` und `voice-original`
- Deutlich mehr Kompatibilitaet und Laufzeitlogik als die urspruengliche monolithische Implementierung

## Verfuegbare Sprachen

- `es`
- `en`
- `fr`
- `de`
- `ru`
- `jp`
- `cn`

## Installationshinweise

- Der Ressourcenordner muss exakt `df_hud` heissen
- Verwende `ensure df_hud` in der `server.cfg`
- Wenn du die Ressource umbenennst, stoppt die Startvalidierung sie absichtlich
- Wenn du `custom` als Framework oder Inventar nutzt, konfiguriere die Hooks in `shared/config/core.lua`

## Links

- Root README: [README.md](../../README.md)
- Spanisch: [README.es.md](README.es.md)
- Englisch: [README.en.md](README.en.md)
- Franzoesisch: [README.fr.md](README.fr.md)
- Russisch: [README.ru.md](README.ru.md)
- Japanisch: [README.jp.md](README.jp.md)
- Chinesisch: [README.cn.md](README.cn.md)
