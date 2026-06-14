function loadCfg() {
    try {
        const saved = JSON.parse(localStorage.getItem('df_hud-cfg') || 'null');
        if (saved) {
            if (saved.voiceStyle) {
                saved.voiceStyle = normalizeVoiceStyle(saved.voiceStyle);
            }
            cfg = { ...DEFAULT_CFG, ...saved };
        }
    } catch (error) {}
}

function saveCfg() {
    if (cfg.voiceStyle) {
        cfg.voiceStyle = normalizeVoiceStyle(cfg.voiceStyle);
    }
    localStorage.setItem('df_hud-cfg', JSON.stringify(cfg));
}

function statVisible(stat) {
    const key = `show${stat[0].toUpperCase()}${stat.slice(1)}`;
    if (!cfg[key]) return false;
    const value = statVals[stat] ?? 100;
    if (stat === 'armour' && cfg.hideArmourAt0 && value <= 0) return false;
    if (cfg.autoHide && value >= cfg.autoHideThreshold) return false;
    if (cfg.hideInVehicle && inVehicle) return false;
    return true;
}

function refreshStatVisibility() {
    STAT_IDS.forEach((id) => {
        const el = document.getElementById(`stat-${id}`);
        if (el) el.style.display = statVisible(id) ? '' : 'none';
    });
    queueHudStatsLayout();
}

function applyCfg() {
    const root = document.documentElement.style;
    const setStopColor = (id, color) => {
        const el = document.getElementById(id);
        if (el) el.setAttribute('stop-color', color);
    };

    refreshStatVisibility();

    const scale = cfg.scale / 100;
    const opacity = cfg.opacity / 100;
    document.querySelectorAll('.stat-container').forEach((el) => {
        el.style.opacity = opacity;
    });

    applyHudElementScales(scale);
    if (voiceHud) {
        voiceHud.style.zoom = scale;
        voiceHud.style.opacity = opacity;
        voiceHud.style.visibility = (!cfg.hideHud && hudVisible) ? 'visible' : 'hidden';
    }

    root.setProperty('--color-health', cfg.colorHealth);
    root.setProperty('--color-armour', cfg.colorArmour);
    root.setProperty('--color-hunger', cfg.colorHunger);
    root.setProperty('--color-thirst', cfg.colorThirst);
    root.setProperty('--color-stamina', cfg.colorStamina);
    root.setProperty('--color-speedo-primary', cfg.colorSpeedoPrimary);
    root.setProperty('--color-speedo-warning', cfg.colorSpeedoWarning);
    root.setProperty('--color-speedo-danger', cfg.colorSpeedoDanger);
    root.setProperty('--color-speedo-accent', cfg.colorSpeedoAccent);
    root.setProperty('--stat-transition', cfg.animateStats ? '0.4s' : '0s');

    STAT_IDS.forEach((id) => {
        const rect = document.getElementById(`ifr-${id}`);
        if (rect) rect.setAttribute('fill', cfg[`color${id[0].toUpperCase()}${id.slice(1)}`]);
    });

    setStopColor('gauge-grad-start', cfg.colorSpeedoPrimary);
    setStopColor('gauge-grad-mid', cfg.colorSpeedoWarning);
    setStopColor('gauge-grad-end', cfg.colorSpeedoDanger);
    setStopColor('arc-grad-start', cfg.colorSpeedoPrimary);
    setStopColor('arc-grad-mid', cfg.colorSpeedoWarning);
    setStopColor('arc-grad-end', cfg.colorSpeedoDanger);

    const neonRing = document.getElementById('neon-ring');
    if (neonRing) {
        neonRing.setAttribute('stroke', cfg.colorSpeedoAccent);
        neonRing.style.filter = `drop-shadow(0 0 6px ${cfg.colorSpeedoAccent})`;
    }

    document.querySelectorAll('#speedo .si-blink').forEach((el) => { el.style.display = cfg.showBlinkers ? '' : 'none'; });
    document.querySelectorAll('#speedo [id$="-engine"]').forEach((el) => { el.style.display = cfg.showEngine ? '' : 'none'; });
    document.querySelectorAll('#speedo [id$="-light"]').forEach((el) => { el.style.display = cfg.showLights ? '' : 'none'; });
    document.querySelectorAll('#speedo [id$="-belt"]').forEach((el) => { el.style.display = cfg.showBelt ? '' : 'none'; });
    document.querySelectorAll('#speedo .fuel-track').forEach((el) => { el.style.display = cfg.showFuel ? '' : 'none'; });
    document.querySelectorAll('#speedo .fuel-copy').forEach((el) => { el.style.display = cfg.showFuel ? '' : 'none'; });

    const simpleFuelIcon = document.getElementById('ss-fuel-icon');
    if (simpleFuelIcon) simpleFuelIcon.style.display = cfg.showFuel ? '' : 'none';

    const originalFuelWrap = document.getElementById('so-fuel-pill');
    if (originalFuelWrap) originalFuelWrap.style.display = cfg.showFuel ? '' : 'none';

    const haloFuel = document.getElementById('sh-fuel');
    if (haloFuel) {
        const container = haloFuel.closest('.halo-item');
        if (container) container.style.display = cfg.showFuel ? '' : 'none';
    }

    if (MAX_SPEED !== cfg.gaugeMaxSpeed) {
        MAX_SPEED = cfg.gaugeMaxSpeed;
        const ticks = document.getElementById('gauge-ticks');
        if (ticks) ticks.innerHTML = '';
        buildGaugeTicks('gauge-ticks', 100, 100, 75, 65, 53, 'rgba(255,255,255,0.3)', 'rgba(255,255,255,0.55)');
    }

    document.body.classList.toggle('streamer-mode', cfg.streamerMode);

    const cinemaTop = document.getElementById('cinema-top');
    const cinemaBottom = document.getElementById('cinema-bottom');
    if (cinemaTop && cinemaBottom) {
        const height = cfg.cinemaMode ? `${cfg.cinemaSize}vh` : '0';
        cinemaTop.style.height = height;
        cinemaBottom.style.height = height;
    }

    if (lastCinemaSync !== cfg.cinemaMode) {
        lastCinemaSync = cfg.cinemaMode;
        fetch('https://df_hud/setCinema', { method: 'POST', body: JSON.stringify({ cinema: cfg.cinemaMode }) });
    }

    if (hudRoot) hudRoot.style.visibility = (!cfg.hideHud && hudVisible) ? 'visible' : 'hidden';
    if (speedoEl) speedoEl.style.visibility = (!cfg.hideHud && hudVisible && (inVehicle || speedoDragActive)) ? 'visible' : 'hidden';
    if (lastHideHudSync !== cfg.hideHud) {
        lastHideHudSync = cfg.hideHud;
        fetch('https://df_hud/setHideHud', { method: 'POST', body: JSON.stringify({ hide: cfg.hideHud }) });
    }

    if (manualGearsAvailable && lastManualGearsSync !== cfg.manualGearsEnabled) {
        lastManualGearsSync = cfg.manualGearsEnabled;
        fetch('https://df_hud/setManualGearsEnabled', { method: 'POST', body: JSON.stringify({ enabled: cfg.manualGearsEnabled }) });
    }

    const compassEl = document.getElementById('compass');
    if (compassEl) compassEl.style.display = (cfg.showCompass && hudVisible && !cfg.hideHud) ? '' : 'none';
    const streetEl = document.getElementById('compass-street');
    if (streetEl) streetEl.style.display = cfg.showCompassStreet ? '' : 'none';
}

function syncCfgUI() {
    const toggles = {
        'cfg-show-health': 'showHealth',
        'cfg-show-armour': 'showArmour',
        'cfg-show-hunger': 'showHunger',
        'cfg-show-thirst': 'showThirst',
        'cfg-show-stamina': 'showStamina',
        'cfg-hide-armour-0': 'hideArmourAt0',
        'cfg-auto-hide': 'autoHide',
        'cfg-blinkers': 'showBlinkers',
        'cfg-engine': 'showEngine',
        'cfg-lights': 'showLights',
        'cfg-belt': 'showBelt',
        'cfg-fuel': 'showFuel',
        'cfg-animate': 'animateStats',
        'cfg-hide-vehicle': 'hideInVehicle',
        'cfg-manual-gears': 'manualGearsEnabled',
        'cfg-streamer': 'streamerMode',
        'cfg-cinema': 'cinemaMode',
        'cfg-hide-hud': 'hideHud',
        'cfg-compass': 'showCompass',
        'cfg-compass-street': 'showCompassStreet',
    };

    Object.entries(toggles).forEach(([id, key]) => {
        const el = document.getElementById(id);
        if (el) el.checked = cfg[key];
    });

    const sliders = {
        'cfg-threshold': ['autoHideThreshold', 'val-threshold'],
        'cfg-maxspeed': ['gaugeMaxSpeed', 'val-maxspeed'],
        'cfg-scale': ['scale', 'val-scale'],
        'cfg-opacity': ['opacity', 'val-opacity'],
        'cfg-cinema-size': ['cinemaSize', 'val-cinema'],
    };

    Object.entries(sliders).forEach(([id, values]) => {
        const [key, labelId] = values;
        const input = document.getElementById(id);
        const valueLabel = document.getElementById(labelId);
        if (input) input.value = cfg[key];
        if (valueLabel) valueLabel.textContent = cfg[key];
    });

    STAT_IDS.forEach((id) => {
        const input = document.getElementById(`cfg-color-${id}`);
        if (input) input.value = cfg[`color${id[0].toUpperCase()}${id.slice(1)}`];
    });

    [
        ['cfg-color-speedo-primary', 'colorSpeedoPrimary'],
        ['cfg-color-speedo-warning', 'colorSpeedoWarning'],
        ['cfg-color-speedo-danger', 'colorSpeedoDanger'],
        ['cfg-color-speedo-accent', 'colorSpeedoAccent'],
    ].forEach(([id, key]) => {
        const input = document.getElementById(id);
        if (input) input.value = cfg[key];
    });

    document.querySelectorAll('#cfg-unit .seg').forEach((btn) => {
        btn.classList.toggle('active', btn.dataset.v === cfg.speedUnit);
    });

    document.getElementById('row-threshold').style.display = cfg.autoHide ? '' : 'none';
    document.getElementById('row-cinema-size').style.display = cfg.cinemaMode ? '' : 'none';
    const manualGearsRow = document.getElementById('row-manual-gears');
    if (manualGearsRow) manualGearsRow.style.display = manualGearsAvailable ? '' : 'none';
}

function initCfgListeners() {
    [
        ['cfg-show-health', 'showHealth'],
        ['cfg-show-armour', 'showArmour'],
        ['cfg-show-hunger', 'showHunger'],
        ['cfg-show-thirst', 'showThirst'],
        ['cfg-show-stamina', 'showStamina'],
        ['cfg-hide-armour-0', 'hideArmourAt0'],
        ['cfg-auto-hide', 'autoHide'],
        ['cfg-blinkers', 'showBlinkers'],
        ['cfg-engine', 'showEngine'],
        ['cfg-lights', 'showLights'],
        ['cfg-belt', 'showBelt'],
        ['cfg-fuel', 'showFuel'],
        ['cfg-animate', 'animateStats'],
        ['cfg-hide-vehicle', 'hideInVehicle'],
        ['cfg-manual-gears', 'manualGearsEnabled'],
        ['cfg-streamer', 'streamerMode'],
        ['cfg-cinema', 'cinemaMode'],
        ['cfg-hide-hud', 'hideHud'],
        ['cfg-compass', 'showCompass'],
        ['cfg-compass-street', 'showCompassStreet'],
    ].forEach(([id, key]) => {
        const input = document.getElementById(id);
        if (!input) return;
        input.addEventListener('change', () => {
            cfg[key] = input.checked;
            if (id === 'cfg-cinema' || id === 'cfg-hide-hud') {
                cinemaCommandActive = false;
                cinemaCommandBackup = null;
            }
            if (id === 'cfg-auto-hide') document.getElementById('row-threshold').style.display = cfg.autoHide ? '' : 'none';
            if (id === 'cfg-cinema') document.getElementById('row-cinema-size').style.display = cfg.cinemaMode ? '' : 'none';
            applyCfg();
            saveCfg();
        });
    });

    [
        ['cfg-threshold', 'autoHideThreshold', 'val-threshold'],
        ['cfg-maxspeed', 'gaugeMaxSpeed', 'val-maxspeed'],
        ['cfg-scale', 'scale', 'val-scale'],
        ['cfg-opacity', 'opacity', 'val-opacity'],
        ['cfg-cinema-size', 'cinemaSize', 'val-cinema'],
    ].forEach(([id, key, labelId]) => {
        const input = document.getElementById(id);
        if (!input) return;
        input.addEventListener('input', () => {
            cfg[key] = Number(input.value);
            const valueLabel = document.getElementById(labelId);
            if (valueLabel) valueLabel.textContent = cfg[key];
            applyCfg();
            saveCfg();
        });
    });

    document.querySelectorAll('#cfg-unit .seg').forEach((btn) => {
        btn.addEventListener('click', () => {
            cfg.speedUnit = btn.dataset.v;
            document.querySelectorAll('#cfg-unit .seg').forEach((seg) => seg.classList.toggle('active', seg.dataset.v === cfg.speedUnit));
            saveCfg();
        });
    });

    STAT_IDS.forEach((id) => {
        const input = document.getElementById(`cfg-color-${id}`);
        if (!input) return;
        input.addEventListener('input', () => {
            cfg[`color${id[0].toUpperCase()}${id.slice(1)}`] = input.value;
            applyCfg();
            saveCfg();
        });
    });

    [
        ['cfg-color-speedo-primary', 'colorSpeedoPrimary'],
        ['cfg-color-speedo-warning', 'colorSpeedoWarning'],
        ['cfg-color-speedo-danger', 'colorSpeedoDanger'],
        ['cfg-color-speedo-accent', 'colorSpeedoAccent'],
    ].forEach(([id, key]) => {
        const input = document.getElementById(id);
        if (!input) return;
        input.addEventListener('input', () => {
            cfg[key] = input.value;
            applyCfg();
            saveCfg();
        });
    });

    document.getElementById('cfg-colors-reset')?.addEventListener('click', () => {
        [
            'colorHealth',
            'colorArmour',
            'colorHunger',
            'colorThirst',
            'colorStamina',
            'colorSpeedoPrimary',
            'colorSpeedoWarning',
            'colorSpeedoDanger',
            'colorSpeedoAccent',
        ].forEach((key) => {
            cfg[key] = DEFAULT_CFG[key];
        });

        syncCfgUI();
        applyCfg();
        saveCfg();
    });
}
