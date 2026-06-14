<div align="center">

# HX HUD

**A modern, fully customizable HUD for FiveM (QBX/QBCore)**

[![Language](https://img.shields.io/badge/Lua-5.4-blue?style=flat-square&logo=lua)](https://www.lua.org/)
[![Framework](https://img.shields.io/badge/QBX__Core-compatible-green?style=flat-square)](https://github.com/Qbox-project/qbx_core)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

<br/>

**[🇪🇸 Español](#-español) · [🇬🇧 English](#-english) · [🎞️ Preview](https://streamable.com/5s3bzb)**

</div>

---

<br/>

# 🇪🇸 Español

## Descripción

**HX HUD** es un sistema de interfaz de usuario (HUD) moderno y completamente personalizable para servidores de FiveM basados en **QBX Core / QBCore**. Ofrece múltiples estilos visuales, un velocímetro avanzado, brújula superior, indicadores de vehículo y un menú de configuración en tiempo real accesible directamente desde el juego.

---

## Características

- **11 estilos de HUD** para las estadísticas del jugador: Cuadrados, Barras, Círculos, Estrellas, Diamantes, Hexágonos, Barras verticales, Con números, Píldoras, Iconos y 3D.
- **10 estilos de velocímetro**: Minimal, Tarjeta, Dashboard, Analógico, Arco, Cyberpunk, Barras, Esquina, Halo y Neón. Más paneles especiales para bicicleta, barco y aeronaves.
- **Brújula superior** con cinta de rumbo, grados, punto cardinal y nombre de la calle/zona actual.
- **Indicadores de vehículo**: intermitentes, cinturón de seguridad, luces, aviso de motor y nivel de combustible.
- **Sistema de sonido**: sonido de intermitente al ritmo configurado, sonido de cinturón al abrocharse/desabrocharse y pitido de advertencia al circular sin cinturón.
- **Modo cine**: barras negras configurables arriba y abajo de la pantalla.
- **Modo streamer**: oculta los valores numéricos del HUD.
- **Minimapa dinámico**: se muestra solo al conducir o si el jugador tiene el ítem configurado.
- **Posicionamiento libre**: arrastra el conjunto de stats, cada stat individual y el velocímetro a cualquier posición de la pantalla.
- **Configuración por jugador**: cada ajuste se guarda en el navegador y persiste entre sesiones.
- **Soporte de idiomas**: `es` (español) y `en` (inglés), configurable desde el servidor.
- **Logo personalizable**: muestra un logo en pantalla con posición, tamaño y opacidad configurables.

---

## Dependencias

| Recurso | Obligatorio |
|---|---|
| [ox_lib](https://github.com/overextended/ox_lib) | ✅ Sí |
| [qbx_core](https://github.com/Qbox-project/qbx_core) o [qb-core](https://github.com/qbcore-framework/qb-core) | ✅ Sí, uno de los dos |
| [ox_inventory](https://github.com/overextended/ox_inventory), [qb-inventory](https://github.com/qbcore-framework/qb-inventory) o [origen_inventory](https://docs.origennetwork.com/scripts/origen_inventory) | ✅ Sí, uno de los tres para el minimapa |

---

## Instalación

1. Clona o descarga este repositorio.
2. Coloca la carpeta `hx-hud` dentro de `resources/[tu-categoria]/`.
3. Añade `ensure hx-hud` a tu `server.cfg`.
4. Configura el archivo `shared/config.lua` según tus preferencias.
5. Reinicia el servidor o ejecuta `refresh` y luego `start hx-hud`.

---

## Configuración (`shared/config.lua`)

```lua
Config.Language = 'es'   -- Idioma del menú: 'es' | 'en' | 'ru' | 'fr' | 'cn' | 'jp'
Config.Framework = 'auto'   -- 'auto' | 'qbx' | 'qbcore'
```

### Stats
```lua
Config.Stats = {
    updateInterval = 500,   -- Milisegundos entre cada actualización de stats
}
```

### Velocímetro
```lua
Config.Speedo = {
    updateInterval = 100,   -- Milisegundos entre cada actualización del velocímetro
}
```

### Intermitentes
```lua
Config.Blinker = {
    interval = 950,   -- Duración de un ciclo completo en ms (más alto = más lento)
}
```

### Minimapa
```lua
Config.Minimap = {
    item          = 'phone',   -- Ítem requerido para ver el minimapa a pie
    inventory     = 'auto',    -- 'auto' | 'ox_inventory' | 'qb-inventory' | 'origen_inventory'
    checkInterval = 2000,      -- ms entre comprobaciones del inventario
}
```

### Logo
```lua
Config.Logo = {
    enabled = true,    -- Mostrar logo en pantalla
    size    = 80,      -- Tamaño en píxeles
    opacity = 0.5,     -- Opacidad (0.0 = invisible, 1.0 = opaco)
    x       = 16,      -- Distancia desde la derecha en píxeles
    y       = 16,      -- Distancia desde arriba en píxeles
}
```

### Defaults del menú `/hud`

Estos valores se aplican la primera vez que un jugador entra al servidor. Puede cambiarlos desde el menú y se guardan por jugador.

| Opción | Tipo | Defecto | Descripción |
|---|---|---|---|
| `showHealth` | boolean | `true` | Mostrar barra de vida |
| `showArmour` | boolean | `true` | Mostrar barra de escudo |
| `showHunger` | boolean | `true` | Mostrar barra de hambre |
| `showThirst` | boolean | `true` | Mostrar barra de sed |
| `showStamina` | boolean | `true` | Mostrar barra de stamina |
| `hideArmourAt0` | boolean | `false` | Ocultar escudo cuando llega a 0 |
| `autoHide` | boolean | `false` | Ocultar stats automáticamente si están altas |
| `autoHideThreshold` | number | `80` | % a partir del cual se oculta el stat |
| `hideInVehicle` | boolean | `false` | Ocultar stats al conducir |
| `speedUnit` | string | `'kmh'` | Unidad de velocidad: `'kmh'` o `'mph'` |
| `gaugeMaxSpeed` | number | `200` | Velocidad máxima del medidor (160–320) |
| `showBlinkers` | boolean | `true` | Mostrar indicadores de intermitente |
| `showEngine` | boolean | `true` | Mostrar aviso de motor |
| `showLights` | boolean | `true` | Mostrar indicador de luces |
| `showBelt` | boolean | `true` | Mostrar indicador de cinturón |
| `showFuel` | boolean | `true` | Mostrar nivel de combustible |
| `scale` | number | `100` | Escala del HUD (50–200%) |
| `opacity` | number | `100` | Opacidad del HUD (10–100%) |
| `colorHealth` | string | `'#ff4757'` | Color de la barra de vida |
| `colorArmour` | string | `'#0984e3'` | Color de la barra de escudo |
| `colorHunger` | string | `'#fdcb6e'` | Color de la barra de hambre |
| `colorThirst` | string | `'#00cec9'` | Color de la barra de sed |
| `colorStamina` | string | `'#6c5ce7'` | Color de la barra de stamina |
| `animateStats` | boolean | `true` | Animaciones suaves en las barras |
| `streamerMode` | boolean | `false` | Ocultar valores numéricos |
| `cinemaMode` | boolean | `false` | Barras negras arriba y abajo |
| `cinemaSize` | number | `13` | Tamaño de las barras de cine (5–25 vh) |
| `hideHud` | boolean | `false` | Ocultar HUD y minimapa completamente |
| `showCompass` | boolean | `true` | Mostrar brújula superior |
| `showCompassStreet` | boolean | `true` | Mostrar nombre de la calle en la brújula |

---

## Comandos y controles

| Acción | Tecla por defecto |
|---|---|
| Abrir menú de configuración | `/hud` |
| Intermitente izquierdo | `←` |
| Intermitente derecho | `→` |
| Luces de emergencia | `↓` |
| Cinturón de seguridad | `B` |
| Luces del vehículo | `H` |

> Las teclas son remapeables desde los ajustes de controles de FiveM.

---

## Estructura de archivos

```
hx-hud/
├── fxmanifest.lua      — Manifiesto del recurso
├── client/
│   └── main.lua        — Lógica del cliente (HUD, vehículo, brújula, estadísticas)
├── server/
│   └── main.lua        — Lógica del servidor
├── shared/
│   ├── config.lua      — Configuración principal
│   └── locales.lua     — Registro y resolución de traducciones
├── locales/
│   ├── es.lua          — Español
│   ├── en.lua          — English
│   ├── ru.lua          — Русский
│   ├── fr.lua          — Français
│   ├── cn.lua          — 中文
│   └── jp.lua          — 日本語
├── assets/
│   ├── logo.svg        — Logo en formato SVG
│   └── logo.png        — Logo en formato PNG
└── web/
    ├── index.html      — Estructura del HUD
    ├── style.css       — Estilos visuales
    ├── js/             — Lógica del NUI separada por módulos
    ├── carbuckle.wav   — Sonido cinturón abrochado
    └── carunbuckle.wav — Sonido cinturón desabrochado
```

---

<br/>

---

<br/>

# 🇬🇧 English

## Description

**HX HUD** is a modern, fully customizable HUD system for FiveM servers running **QBX Core / QBCore**. It provides multiple visual styles, an advanced speedometer, a top compass bar, vehicle indicators, and a real-time configuration menu accessible directly in-game.

---

## Features

- **11 HUD styles** for player stats: Boxes, Bars, Circles, Stars, Diamonds, Hexagons, Vertical bars, Numbered, Pills, Icons and 3D.
- **10 speedometer styles**: Minimal, Card, Dashboard, Gauge, Arc, Cyberpunk, Bars, Corner, Halo and Neon. Plus special panels for bicycle, boat and aircraft.
- **Top compass bar** with heading tape, degrees, cardinal point and current street/zone name.
- **Vehicle indicators**: blinkers, seatbelt, headlights, engine warning and fuel level.
- **Sound system**: blinker tick sound at the configured rhythm, buckle/unbuckle sounds, and a seatbelt warning beep when driving without one.
- **Cinema mode**: configurable black bars at the top and bottom of the screen.
- **Streamer mode**: hides all numeric values from the HUD.
- **Dynamic minimap**: shown only while driving or if the player has the configured inventory item.
- **Free positioning**: drag the stat group, each individual stat and the speedometer anywhere on screen.
- **Per-player config**: all settings are saved in the browser's localStorage and persist between sessions.
- **Language support**: `es` (Spanish) and `en` (English), configurable from the server.
- **Customizable logo**: display a logo with configurable position, size and opacity.

---

## Dependencies

| Resource | Required |
|---|---|
| [ox_lib](https://github.com/overextended/ox_lib) | ✅ Yes |
| [qbx_core](https://github.com/Qbox-project/qbx_core) or [qb-core](https://github.com/qbcore-framework/qb-core) | ✅ Yes, one of them |
| [ox_inventory](https://github.com/overextended/ox_inventory), [qb-inventory](https://github.com/qbcore-framework/qb-inventory) or [origen_inventory](https://docs.origennetwork.com/scripts/origen_inventory) | ✅ Yes, one of them for the minimap |

---

## Installation

1. Clone or download this repository.
2. Place the `hx-hud` folder inside `resources/[your-category]/`.
3. Add `ensure hx-hud` to your `server.cfg`.
4. Configure `shared/config.lua` to your liking.
5. Restart the server or run `refresh` then `start hx-hud`.

---

## Configuration (`shared/config.lua`)

```lua
Config.Language = 'en'   -- Menu language: 'es' | 'en' | 'ru' | 'fr' | 'cn' | 'jp'
Config.Framework = 'auto'   -- 'auto' | 'qbx' | 'qbcore'
```

### Stats
```lua
Config.Stats = {
    updateInterval = 500,   -- Milliseconds between each stats update
}
```

### Speedometer
```lua
Config.Speedo = {
    updateInterval = 100,   -- Milliseconds between each speedometer update
}
```

### Blinkers
```lua
Config.Blinker = {
    interval = 950,   -- Full blink cycle duration in ms (higher = slower)
}
```

### Minimap
```lua
Config.Minimap = {
    item          = 'phone',   -- Item required to see the minimap on foot
    inventory     = 'auto',    -- 'auto' | 'ox_inventory' | 'qb-inventory' | 'origen_inventory'
    checkInterval = 2000,      -- ms between inventory checks
}
```

### Logo
```lua
Config.Logo = {
    enabled = true,    -- Show logo on screen
    size    = 80,      -- Size in pixels
    opacity = 0.5,     -- Opacity (0.0 = invisible, 1.0 = fully opaque)
    x       = 16,      -- Distance from the right edge in pixels
    y       = 16,      -- Distance from the top in pixels
}
```

### `/hud` Menu Defaults

These values are applied the first time a player joins. They can be changed via the in-game menu and are saved per player.

| Option | Type | Default | Description |
|---|---|---|---|
| `showHealth` | boolean | `true` | Show health bar |
| `showArmour` | boolean | `true` | Show armour bar |
| `showHunger` | boolean | `true` | Show hunger bar |
| `showThirst` | boolean | `true` | Show thirst bar |
| `showStamina` | boolean | `true` | Show stamina bar |
| `hideArmourAt0` | boolean | `false` | Hide armour bar when it reaches 0 |
| `autoHide` | boolean | `false` | Auto-hide stats when they are high |
| `autoHideThreshold` | number | `80` | % above which the stat is hidden |
| `hideInVehicle` | boolean | `false` | Hide stats while driving |
| `speedUnit` | string | `'kmh'` | Speed unit: `'kmh'` or `'mph'` |
| `gaugeMaxSpeed` | number | `200` | Maximum gauge speed (160–320) |
| `showBlinkers` | boolean | `true` | Show blinker indicators |
| `showEngine` | boolean | `true` | Show engine warning |
| `showLights` | boolean | `true` | Show headlight indicator |
| `showBelt` | boolean | `true` | Show seatbelt indicator |
| `showFuel` | boolean | `true` | Show fuel level |
| `scale` | number | `100` | HUD scale (50–200%) |
| `opacity` | number | `100` | HUD opacity (10–100%) |
| `colorHealth` | string | `'#ff4757'` | Health bar colour |
| `colorArmour` | string | `'#0984e3'` | Armour bar colour |
| `colorHunger` | string | `'#fdcb6e'` | Hunger bar colour |
| `colorThirst` | string | `'#00cec9'` | Thirst bar colour |
| `colorStamina` | string | `'#6c5ce7'` | Stamina bar colour |
| `animateStats` | boolean | `true` | Smooth bar animations |
| `streamerMode` | boolean | `false` | Hide numeric values |
| `cinemaMode` | boolean | `false` | Black bars top and bottom |
| `cinemaSize` | number | `13` | Cinema bar size (5–25 vh) |
| `hideHud` | boolean | `false` | Completely hide HUD and minimap |
| `showCompass` | boolean | `true` | Show top compass bar |
| `showCompassStreet` | boolean | `true` | Show street name on the compass |

---

## Commands & Keybindings

| Action | Default key |
|---|---|
| Open configuration menu | `/hud` |
| Left blinker | `←` |
| Right blinker | `→` |
| Hazard lights | `↓` |
| Seatbelt | `B` |
| Vehicle headlights | `H` |

> Keys can be rebound in the FiveM key binding settings.

---

## File Structure

```
hx-hud/
├── fxmanifest.lua      — Resource manifest
├── client/
│   └── main.lua        — Client logic (HUD, vehicle, compass, stats)
├── server/
│   └── main.lua        — Server logic
├── shared/
│   ├── config.lua      — Main configuration
│   └── locales.lua     — Locale registry and resolver
├── locales/
│   ├── es.lua          — Spanish
│   ├── en.lua          — English
│   ├── ru.lua          — Russian
│   ├── fr.lua          — French
│   ├── cn.lua          — Chinese
│   └── jp.lua          — Japanese
├── assets/
│   ├── logo.svg        — Logo in SVG format
│   └── logo.png        — Logo in PNG format
└── web/
    ├── index.html      — HUD structure
    ├── style.css       — Visual styles
    ├── js/             — Split NUI logic modules
    ├── carbuckle.wav   — Seatbelt buckle sound
    └── carunbuckle.wav — Seatbelt unbuckle sound
```

---

<div align="center">

Made with ❤️ by **DF Network**

</div>
