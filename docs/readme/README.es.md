# DF HUD

## Resumen

`df_hud` es un fork del repositorio público [`EstebanSole/hx-hud`](https://github.com/EstebanSole/hx-hud), mantenido por DF Network y ampliado para cubrir más frameworks, inventarios, persistencia, locales y una estructura interna mucho más modular.

## Fork y atribución

- Repositorio base: `EstebanSole/hx-hud`
- Autor acreditado en el `LICENSE` del upstream: `Moohja — Elixir Dev`
- Licencia mostrada por el upstream para atribución: [`CC BY-NC 4.0`](https://raw.githubusercontent.com/EstebanSole/hx-hud/main/LICENSE)

Nota importante:

- El README del upstream muestra una insignia MIT.
- El archivo `LICENSE` del upstream indica `CC BY-NC 4.0`.
- En este fork la atribución se documenta siguiendo el `LICENSE` del upstream.

## Estimación de origen del código

Comparación técnica realizada el **2026-06-14** contra la rama pública `main` de `hx-hud`.

- Código todavía reconociblemente derivado de `hx-hud`: **11.9%**
- Código añadido por DF o reescrito de forma sustancial en `df_hud`: **88.1%**

Metodología usada:

- Solo se comparó código fuente: `.lua`, `.js`, `.css`, `.html`
- `df_hud` actual: **70 archivos fuente**, **7,453 líneas no vacías**
- `hx-hud` upstream: **7 archivos fuente**, **3,209 líneas no vacías**
- A cada archivo actual se le buscó su mejor coincidencia textual en el upstream y se ponderó por número de líneas no vacías

Esta cifra es una **estimación técnica orientativa** para dejar clara la evolución del fork. No sustituye una interpretación legal de autoría, copyright o licencia.

## Qué aporta DF HUD frente al upstream

- Nombre del recurso fijado obligatoriamente a `df_hud`
- Reorganización por carpetas `client/`, `server/`, `shared/`, `locales/`, `web/js/`
- `init.lua` para resolver framework e inventario
- Soporte para `qbx`, `qbcore`, `esx`, `mythic`, `nd`, `ox`, `vrp`, `vrpex`, `custom`
- Soporte para `ox_inventory`, `qs-inventory`, `qb-inventory`, `ps-inventory`, `codem-inventory`, `core_inventory`, `ak47_inventory`, `esx_inventory`, `esx_inventoryhud`, `origen_inventory`, `mythic-inventory`, `ND_Core`, `vrp`, `custom`
- Persistencia por jugador para HUD, estilos y marchas manuales
- Banner de inicio, comprobación de versión y avisos de soporte
- Locales desacoplados del JS y soporte multilenguaje ampliado
- Nuevos identificadores `voice-simple` y `voice-original`
- Más lógica y compatibilidad que la implementación monolítica original

## Idiomas disponibles

- `es`
- `en`
- `fr`
- `de`
- `ru`
- `jp`
- `cn`

## Notas de instalación

- La carpeta del recurso debe llamarse exactamente `df_hud`
- Usa `ensure df_hud` en tu `server.cfg`
- Si renombras el recurso, el validador de arranque lo detendrá
- Si usas framework o inventario `custom`, configura sus hooks en `shared/config/core.lua`

## Enlaces

- README raíz: [README.md](../../README.md)
- Inglés: [README.en.md](README.en.md)
- Francés: [README.fr.md](README.fr.md)
- Alemán: [README.de.md](README.de.md)
- Ruso: [README.ru.md](README.ru.md)
- Japonés: [README.jp.md](README.jp.md)
- Chino: [README.cn.md](README.cn.md)
