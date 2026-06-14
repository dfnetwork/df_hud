loadCfg();
loadSavedSizes();
loadSavedPositions();
loadSpeedoPos();
savedVoiceStyle = cfg.voiceStyle || DEFAULT_CFG.voiceStyle;
pendingVoiceStyle = savedVoiceStyle;
currentVoiceStyle = savedVoiceStyle;
syncCfgUI();
initCfgListeners();
applyCfg();
syncHudCardState();
syncSpeedoCardState();
commitVoiceStyle(savedVoiceStyle);
buildGaugeTicks('gauge-ticks', 100, 100, 75, 65, 53, 'rgba(255,255,255,0.3)', 'rgba(255,255,255,0.55)');
buildBars();
buildCompass();

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'setServerConfig') {
        const saved = localStorage.getItem('df_hud-cfg');
        let savedConfig = null;

        try {
            savedConfig = saved ? JSON.parse(saved) : null;
        } catch (error) {}

        if (savedConfig) {
            cfg = { ...DEFAULT_CFG, ...(data.config || {}), ...savedConfig };
        } else {
            cfg = { ...DEFAULT_CFG, ...(data.config || {}) };
        }

        if (data.manualGears) {
            manualGearsAvailable = !!data.manualGears.enabled;
            if (typeof data.manualGears.playerEnabled === 'boolean') {
                cfg.manualGearsEnabled = data.manualGears.playerEnabled;
                if (savedConfig) {
                    savedConfig.manualGearsEnabled = data.manualGears.playerEnabled;
                }
            }
            if (!manualGearsAvailable) {
                cfg.manualGearsEnabled = false;
                lastManualGearsSync = null;
            }
        }

        syncCfgUI();
        applyCfg();
        saveCfg();

        if (!savedConfig) {
            commitVoiceStyle(cfg.voiceStyle || DEFAULT_CFG.voiceStyle);
        }

        if (data.logo) {
            const logo = document.getElementById('hx-logo');
            if (logo) {
                logo.style.display = data.logo.enabled ? '' : 'none';
                logo.style.width = `${data.logo.size}px`;
                logo.style.opacity = data.logo.opacity;
                logo.style.right = `${data.logo.x}px`;
                logo.style.top = `${data.logo.y}px`;
            }
        }

        if (data.locale || data.translations) {
            applyLocale(data.locale || localeCode, data.translations || {});
        }

        if (savedConfig) {
            commitVoiceStyle(cfg.voiceStyle || DEFAULT_CFG.voiceStyle);
        }
    }

    if (data.type === 'setPauseHidden') {
        document.body.classList.toggle('pause-hidden', !!data.hidden);
    }

    if (data.type === 'compass') {
        updateCompass(data.heading ?? 0);
        const street = document.getElementById('compass-street');
        if (street) street.textContent = data.street || '';
    }

    if (data.type === 'setVisible') {
        hudVisible = !!data.visible;
        applyCfg();
    }

    if (data.type === 'setMinimapVisible') {
        minimapVisible = !!data.visible;
        if (hudRoot) hudRoot.dataset.radar = minimapVisible ? 'visible' : 'hidden';
        queueHudStatsLayout();
    }

    if (data.type === 'setBlinkerInterval') {
        blinkerCycleMs = data.interval;
        document.documentElement.style.setProperty('--blinker-duration', `${data.interval / 1000}s`);
    }

    if (data.type === 'openMenu') {
        hudMenu.classList.add('open');
    }

    if (data.type === 'toggleCinemaCommand') {
        if (!cinemaCommandActive) {
            cinemaCommandBackup = {
                hideHud: cfg.hideHud,
                cinemaMode: cfg.cinemaMode,
            };
            cfg.hideHud = true;
            cfg.cinemaMode = true;
            cinemaCommandActive = true;
        } else if (cinemaCommandBackup) {
            cfg.hideHud = cinemaCommandBackup.hideHud;
            cfg.cinemaMode = cinemaCommandBackup.cinemaMode;
            cinemaCommandActive = false;
            cinemaCommandBackup = null;
        }

        syncCfgUI();
        applyCfg();
        saveCfg();
    }

    if (data.type === 'setStyle') {
        commitHudStyle(data.style);
    }

    if (data.type === 'setSpeedoStyle') {
        commitSpeedoStyle(data.style);
    }

    if (data.type === 'stats') {
        statKeys.forEach((stat) => {
            const value = Math.max(0, Math.min(100, data[stat] ?? 0));
            statVals[stat] = value;

            const bar = document.getElementById(`${stat}-bar`);
            if (bar) bar.style.width = `${value}%`;

            document.querySelectorAll(`.origen-fill[data-stat="${stat}"], .samy-fill[data-stat="${stat}"]`).forEach((el) => {
                el.style.width = `${value}%`;
            });

            document.querySelectorAll(`.box-fill[data-stat="${stat}"]`).forEach((el) => {
                el.style.height = `${value}%`;
            });

            document.querySelectorAll(`.stat-num[data-stat="${stat}"]`).forEach((el) => {
                el.textContent = Math.round(value);
            });

            const rect = document.getElementById(`ifr-${stat}`);
            if (rect) {
                const height = 24 * (value / 100);
                rect.setAttribute('x', 0);
                rect.setAttribute('y', 24 - height);
                rect.setAttribute('width', 24);
                rect.setAttribute('height', height);
            }

            const statEl = document.getElementById(`stat-${stat}`);
            if (statEl) statEl.style.display = statVisible(stat) ? '' : 'none';
        });

        const oxygen = Math.max(0, Math.min(100, data.oxygen ?? 100));
        const oxygenEl = document.getElementById('oxygen-indicator');
        const oxygenNum = document.getElementById('oxygen-num');
        if (oxygenEl && oxygenNum) {
            oxygenNum.textContent = Math.round(oxygen);
            oxygenEl.classList.toggle('visible', oxygen < 100);
            oxygenEl.classList.toggle('critical', oxygen < 30);
        }

        queueHudStatsLayout();
    }

    if (data.type === 'voice') {
        updateVoiceHud(data);
    }

    if (data.type === 'vehicle') {
        const speedoEl = document.getElementById('speedo');
        if (!speedoEl) return;

        inVehicle = !!data.inVehicle;

        if (!data.inVehicle) {
            if (!speedoDragActive) speedoEl.style.visibility = 'hidden';
            stopSeatbeltWarning();
            stopBlinkerSound();
            refreshStatVisibility();
            return;
        }

        speedoEl.style.visibility = 'visible';
        refreshStatVisibility();

        const rawSpeed = data.speed ?? 0;
        const speed = cfg.speedUnit === 'mph' ? Math.round(rawSpeed * 0.621371) : rawSpeed;
        const unit = cfg.speedUnit === 'mph' ? 'mph' : 'km/h';
        const vehicleType = data.vehicleType ?? 'car';
        const gear = Math.max(0, Number(data.manualMode ? data.manualGear : data.gear ?? 0));
        const gearDisplay = data.manualMode ? (data.manualGearDisplay || String(data.manualGear ?? 0)) : null;
        const rpm = Math.max(0, Math.min(1, Number(data.rpm ?? 0)));

        if (vehicleType === 'heli' || vehicleType === 'plane') setActiveSpeedoPanel('speedo-air');
        else if (vehicleType === 'boat') setActiveSpeedoPanel('speedo-boat');
        else if (vehicleType === 'bicycle') setActiveSpeedoPanel('speedo-bike');
        else setActiveSpeedoPanel(currentSpeedoStyle);

        const isBicycle = vehicleType === 'bicycle';
        const hasBelt = vehicleType === 'car';

        document.querySelectorAll('#speedo [id$="-belt"]').forEach((el) => {
            el.style.display = (hasBelt && cfg.showBelt) ? '' : 'none';
        });

        if (!isBicycle && (data.blinkerLeft || data.blinkerRight)) startBlinkerSound();
        else stopBlinkerSound();

        if (hasBelt && !data.seatbelt && speed > 5) startSeatbeltWarning();
        else stopSeatbeltWarning();

        document.querySelectorAll('.speedo-num').forEach((el) => { el.textContent = speed; });
        document.querySelectorAll('.speedo-unit').forEach((el) => { el.textContent = unit; });

        updateFuel(data.fuel ?? 100);
        updateSpeedoVisuals(speed);
        updatePerformanceVisuals(speed, gear, rpm, gearDisplay);

        const indicators = {
            blinkerLeft: !!data.blinkerLeft,
            blinkerRight: !!data.blinkerRight,
            seatbelt: !!data.seatbelt,
            engineWarning: !!data.engineWarning,
            lightsMode: data.lightsMode ?? 0,
        };

        ['sm', 'sc', 'sd', 'sg', 'sa', 'scy', 'sb', 'sc2', 'sh', 'sn', 'ss', 'sr', 'sbt', 'sai'].forEach((prefix) => {
            setIndicators(prefix, indicators);
        });

        if (vehicleType === 'boat') {
            const heading = data.heading ?? 0;
            const degEl = document.getElementById('boat-hdg-deg');
            const dirEl = document.getElementById('boat-hdg-dir');
            if (degEl) degEl.textContent = `${String(heading).padStart(3, '0')}°`;
            if (dirEl) dirEl.textContent = headingToDir(heading);
        }

        if (vehicleType === 'heli' || vehicleType === 'plane') {
            const heading = data.heading ?? 0;
            const altitude = data.altitude ?? 0;
            const altAgl = data.altAgl ?? 0;
            const vertSpeed = data.vertSpeed ?? 0;
            const altEl = document.getElementById('air-alt');
            const aglEl = document.getElementById('air-agl');
            const hdgEl = document.getElementById('air-hdg');
            const vertEl = document.getElementById('air-vert');
            const badgeEl = document.getElementById('air-type-badge');
            const vsiEl = document.getElementById('air-vsi-fill');

            if (altEl) altEl.textContent = `${altitude} m`;
            if (aglEl) aglEl.textContent = `AGL ${altAgl} m`;
            if (hdgEl) hdgEl.textContent = `${String(heading).padStart(3, '0')}° ${headingToDir(heading)}`;
            if (badgeEl) badgeEl.textContent = vehicleType === 'heli' ? 'HELI' : 'AVIÓN';

            if (vertEl) {
                vertEl.textContent = `${vertSpeed > 0 ? '+' : ''}${vertSpeed}`;
                vertEl.style.color = vertSpeed > 2 ? '#55efc4' : vertSpeed < -2 ? '#ff4757' : '#dfe6e9';
            }

            if (vsiEl) {
                const clamped = Math.max(-20, Math.min(20, vertSpeed));
                const magnitude = Math.min(Math.abs(clamped) / 20 * 24, 24);
                if (clamped >= 0) {
                    vsiEl.style.bottom = '50%';
                    vsiEl.style.top = 'auto';
                    vsiEl.style.background = '#55efc4';
                } else {
                    vsiEl.style.top = '50%';
                    vsiEl.style.bottom = 'auto';
                    vsiEl.style.background = '#ff4757';
                }
                vsiEl.style.height = `${magnitude}px`;
            }
        }
    }

    if (data.type === 'seatbeltSound') {
        if (data.buckled) {
            buckleSound.currentTime = 0;
            buckleSound.play();
        } else {
            unbuckleSound.currentTime = 0;
            unbuckleSound.play();
        }
    }
});
