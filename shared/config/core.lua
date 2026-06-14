Config = Config or {}

-- ─── Idioma ────────────────────────────────────────────────────────────────────
Config.Language = 'es'   -- 'es' | 'en' | 'ru' | 'fr' | 'cn' | 'jp'
Config.Locale = Config.Language -- compatibilidad interna

-- ─── Framework / Inventario ───────────────────────────────────────────────────
Config.Framework = 'auto'   -- 'auto' | 'qbx' | 'qbcore'

-- ─── Stats ─────────────────────────────────────────────────────────────────────
Config.Stats = {
    updateInterval = 500,   -- ms entre cada actualización de stats
}

-- ─── Velocímetro ───────────────────────────────────────────────────────────────
Config.Speedo = {
    updateInterval = 100,   -- ms entre cada actualización del velocímetro
}

-- ─── Voz ───────────────────────────────────────────────────────────────────────
Config.Voice = {
    enabled = true,
    updateInterval = 150,       -- ms entre actualizaciones del voice HUD
    defaultStyle = 'voice-samy' -- 'voice-samy' | 'voice-origen'
}

-- ─── Intermitentes ─────────────────────────────────────────────────────────────
Config.Blinker = {
    interval = 950,   -- ms por ciclo completo (más alto = más lento)
}

-- ─── Minimapa ──────────────────────────────────────────────────────────────────
Config.Minimap = {
    item          = 'map',     -- ítem requerido para ver el minimapa a pie
    inventory     = 'auto',    -- 'auto' | 'ox_inventory' | 'qb-inventory' | 'origen_inventory'
    checkInterval = 2000,      -- ms entre comprobaciones del inventario
}

-- ─── Marchas manuales (starter) ───────────────────────────────────────────────
Config.ManualGears = {
    enabled = false,           -- sistema base desactivado por defecto
    defaultEnabled = false,    -- activar manual al entrar en vehículo
    maxGears = 6,
    requireClutch = true,      -- obliga a pisar embrague para subir/bajar marcha
    shiftCooldown = 180,       -- ms entre cambios
    ratios = { 0.18, 0.32, 0.48, 0.66, 0.84, 1.00 },
}

-- ─── Logo ──────────────────────────────────────────────────────────────────────
Config.Logo = {
    enabled = true,            -- mostrar logo en pantalla
    size    = 80,              -- tamaño en píxeles
    opacity = 0.5,             -- opacidad (0.0 - 1.0)
    x       = 16,              -- distancia desde la derecha (px)
    y       = 16,              -- distancia desde arriba (px)
}

-- ─── Defaults del menú de configuración ───────────────────────────────────────
-- Estos son los valores por defecto que se cargan la primera vez.
-- El jugador puede cambiarlos desde el menú /hud y se guardan por jugador.
Config.Defaults = {
    -- Stats visibles
    showHealth  = true,
    showArmour  = true,
    showHunger  = true,
    showThirst  = true,
    showStamina = true,

    -- Comportamiento de stats
    hideArmourAt0      = true,
    autoHide           = false,
    autoHideThreshold  = 80,
    hideInVehicle      = false,

    -- Velocímetro
    speedUnit     = 'kmh',
    gaugeMaxSpeed = 200,

    -- Indicadores del velocímetro
    showBlinkers = true,
    showEngine   = true,
    showLights   = true,
    showBelt     = true,
    showFuel     = true,

    -- Visual
    scale   = 100,
    opacity = 100,

    -- Colores
    colorHealth  = '#ff4757',
    colorArmour  = '#0984e3',
    colorHunger  = '#fdcb6e',
    colorThirst  = '#00cec9',
    colorStamina = '#6c5ce7',
    colorSpeedoPrimary = '#55efc4',
    colorSpeedoWarning = '#fdcb6e',
    colorSpeedoDanger  = '#ff4757',
    colorSpeedoAccent  = '#00d2ff',

    -- Extras
    animateStats  = true,
    streamerMode  = false,
    cinemaMode    = false,
    cinemaSize    = 13,
    hideHud       = false,
    manualGearsEnabled = Config.ManualGears.defaultEnabled and Config.ManualGears.enabled,
    voiceStyle    = Config.Voice.defaultStyle,

    -- Brújula
    showCompass       = true,
    showCompassStreet = true,
}
