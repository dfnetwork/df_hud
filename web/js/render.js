function buildGaugeTicks(tickGroupId, cx, cy, rOuter, rInner, rText, color, textColor) {
    const group = document.getElementById(tickGroupId);
    if (!group) return;

    for (let i = 0; i <= 10; i += 1) {
        const speed = Math.round(i * MAX_SPEED / 10);
        const angle = (-135 + i * 27) * Math.PI / 180;
        const sinA = Math.sin(angle);
        const cosA = Math.cos(angle);

        const x1 = cx + rOuter * sinA;
        const y1 = cy - rOuter * cosA;
        const x2 = cx + rInner * sinA;
        const y2 = cy - rInner * cosA;
        const xt = cx + rText * sinA;
        const yt = cy - rText * cosA;

        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', x1.toFixed(2));
        line.setAttribute('y1', y1.toFixed(2));
        line.setAttribute('x2', x2.toFixed(2));
        line.setAttribute('y2', y2.toFixed(2));
        line.setAttribute('stroke', color);
        line.setAttribute('stroke-width', '1.5');
        group.appendChild(line);

        const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        text.setAttribute('x', xt.toFixed(2));
        text.setAttribute('y', yt.toFixed(2));
        text.setAttribute('text-anchor', 'middle');
        text.setAttribute('dominant-baseline', 'middle');
        text.setAttribute('fill', textColor);
        text.setAttribute('font-size', '9');
        text.setAttribute('font-family', 'Inter, sans-serif');
        text.setAttribute('font-weight', '500');
        text.textContent = speed;
        group.appendChild(text);
    }

    for (let i = 1; i < 20; i += 2) {
        const angle = (-135 + i * 13.5) * Math.PI / 180;
        const sinA = Math.sin(angle);
        const cosA = Math.cos(angle);
        const x1 = cx + rOuter * sinA;
        const y1 = cy - rOuter * cosA;
        const x2 = cx + (rOuter - 4) * sinA;
        const y2 = cy - (rOuter - 4) * cosA;
        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', x1.toFixed(2));
        line.setAttribute('y1', y1.toFixed(2));
        line.setAttribute('x2', x2.toFixed(2));
        line.setAttribute('y2', y2.toFixed(2));
        line.setAttribute('stroke', color);
        line.setAttribute('stroke-width', '0.8');
        line.setAttribute('stroke-opacity', '0.5');
        group.appendChild(line);
    }
}

function buildBars() {
    const grid = document.getElementById('speed-bar-grid');
    if (!grid) return;
    for (let i = 0; i < 20; i += 1) {
        const bar = document.createElement('div');
        bar.className = 'speed-bar-col';
        bar.id = `sbar-${i}`;
        bar.style.height = `${20 + (i % 3) * 3}%`;
        grid.appendChild(bar);
    }
}

const CMP_WIDTH = 260;
const CMP_PX_PER_DEG = CMP_WIDTH / 90;
const CMP_CARDINALS = { 0: 'N', 45: 'NE', 90: 'E', 135: 'SE', 180: 'S', 225: 'SO', 270: 'O', 315: 'NO' };

function buildCompass() {
    const track = document.getElementById('compass-track');
    if (!track) return;
    track.innerHTML = '';

    for (let deg = -180; deg <= 540; deg += 15) {
        const normalized = ((deg % 360) + 360) % 360;
        const mark = document.createElement('div');
        mark.className = 'cmp-mark';
        mark.style.left = `${(deg + 180) * CMP_PX_PER_DEG}px`;

        if (CMP_CARDINALS[normalized] !== undefined) {
            mark.classList.add('cmp-cardinal');
            const cardinal = document.createElement('div');
            cardinal.className = `cmp-card${normalized === 0 ? ' dir-n' : ''}`;
            cardinal.textContent = CMP_CARDINALS[normalized];
            mark.appendChild(cardinal);
        } else {
            const tick = document.createElement('div');
            tick.className = 'cmp-tick';
            mark.appendChild(tick);
        }

        track.appendChild(mark);
    }
}

function updateCompass(heading) {
    const track = document.getElementById('compass-track');
    if (!track) return;
    const translateX = (CMP_WIDTH / 2) - (heading + 180) * CMP_PX_PER_DEG;
    track.style.transform = `translateX(${translateX.toFixed(1)}px)`;
    const deg = document.getElementById('compass-deg');
    if (deg) deg.textContent = `${String(Math.round(heading) % 360).padStart(3, '0')}°`;
}

function updateFuel(value) {
    document.querySelectorAll('.fuel-fill').forEach((el) => {
        el.style.width = `${value}%`;
        el.classList.remove('low', 'danger');
        if (value <= 15) el.classList.add('danger');
        else if (value <= 30) el.classList.add('low');
    });

    document.querySelectorAll('.fuel-fill-vert').forEach((el) => {
        el.style.height = `${value}%`;
        el.classList.remove('low', 'danger');
        if (value <= 15) el.classList.add('danger');
        else if (value <= 30) el.classList.add('low');
    });

    const haloNum = document.getElementById('sh-fuel-num');
    if (haloNum) {
        haloNum.textContent = `${Math.round(value)}%`;
        haloNum.style.color = value <= 15 ? cfg.colorSpeedoDanger : value <= 30 ? cfg.colorSpeedoWarning : 'rgba(255,255,255,0.80)';
    }

    const haloIcon = document.getElementById('sh-fuel');
    if (haloIcon) {
        haloIcon.classList.remove('warn', 'on');
        if (value <= 15) haloIcon.classList.add('warn');
    }

    const fuelIcon = document.getElementById('sc-fuel-icon');
    if (fuelIcon) fuelIcon.classList.toggle('warn', value <= 15);

    const samyFuelIcon = document.getElementById('ss-fuel-icon');
    if (samyFuelIcon) samyFuelIcon.classList.toggle('warn', value <= 15);

    const raceFuelText = document.getElementById('sr-fuel-text');
    if (raceFuelText) raceFuelText.textContent = `${Math.round(value)}%`;
}

function updateSpeedoVisuals(speed) {
    const clamped = Math.min(speed, MAX_SPEED);
    const ratio = clamped / MAX_SPEED;
    const angle = -135 + ratio * 270;

    const needle = document.getElementById('gauge-needle');
    if (needle) {
        needle.style.transformBox = 'fill-box';
        needle.style.transformOrigin = 'bottom center';
        needle.style.transform = `rotate(${angle.toFixed(2)}deg)`;
    }

    const gaugeFill = document.getElementById('gauge-fill');
    if (gaugeFill) gaugeFill.style.strokeDashoffset = (GAUGE_ARC * (1 - ratio)).toFixed(2);

    const arcFill = document.getElementById('arc-fill');
    if (arcFill) arcFill.style.strokeDashoffset = (ARC_ARC * (1 - ratio)).toFixed(2);

    const neonRing = document.getElementById('neon-ring');
    if (neonRing) neonRing.style.strokeDasharray = `${(NEON_CIRC * ratio).toFixed(2)} ${NEON_CIRC}`;

    for (let i = 0; i < 20; i += 1) {
        const bar = document.getElementById(`sbar-${i}`);
        if (!bar) continue;
        const threshold = (i / 20) * MAX_SPEED;
        bar.classList.remove('lit-green', 'lit-yellow', 'lit-red');
        if (clamped > threshold) {
            if (i < 12) bar.classList.add('lit-green');
            else if (i < 16) bar.classList.add('lit-yellow');
            else bar.classList.add('lit-red');
        }
    }
}

function updatePerformanceVisuals(speed, gear, rpm, gearDisplay = null) {
    const raceGear = document.getElementById('sr-gear');
    if (raceGear) raceGear.textContent = gearDisplay || (speed <= 0 ? 'N' : (gear <= 0 ? 'R' : String(gear)));

    const raceFill = document.getElementById('sr-rpm-fill');
    if (raceFill) raceFill.style.width = `${Math.max(0, Math.min(1, rpm)) * 100}%`;

    document.querySelectorAll('#speedo-race .race-rpm-seg').forEach((seg, index, list) => {
        const threshold = (index + 1) / list.length;
        let color = 'rgba(255,255,255,0.10)';
        if (rpm >= threshold) {
            if (threshold > 0.8) color = cfg.colorSpeedoDanger;
            else if (threshold > 0.6) color = cfg.colorSpeedoWarning;
            else color = 'rgba(255,255,255,0.82)';
        }
        seg.style.backgroundColor = color;
    });
}

function setIndicators(prefix, indicators) {
    const { blinkerLeft, blinkerRight, seatbelt, engineWarning, lightsMode } = indicators;
    const blinkLeft = document.getElementById(`${prefix}-blink-l`);
    const blinkRight = document.getElementById(`${prefix}-blink-r`);
    const belt = document.getElementById(`${prefix}-belt`);
    const engine = document.getElementById(`${prefix}-engine`);
    const light = document.getElementById(`${prefix}-light`);

    if (blinkLeft) blinkLeft.classList.toggle('active', !!blinkerLeft);
    if (blinkRight) blinkRight.classList.toggle('active', !!blinkerRight);
    if (belt) {
        belt.classList.remove('warn', 'on', 'high');
        if (seatbelt) belt.classList.add('high');
    }
    if (engine) {
        engine.classList.remove('warn', 'on');
        if (engineWarning) engine.classList.add('warn');
    }
    if (light) {
        light.classList.remove('warn', 'on', 'high');
        if (lightsMode === 1) light.classList.add('on');
        if (lightsMode === 2) light.classList.add('high');
    }
}

function getVoiceModeLabel(mode, radioActive) {
    if (radioActive) return t('voice-range-radio', 'Radio');
    if (mode === 'whisper') return t('voice-range-whisper', 'Whisper');
    if (mode === 'shout') return t('voice-range-shout', 'Shouting');
    return t('voice-range-normal', 'Normal');
}

function updateVoiceHud(data) {
    const range = Number(data.range ?? 3.0);
    const talking = !!data.talking;
    const mode = data.mode || 'normal';
    const radioActive = !!data.radioActive;
    const radioChannel = Number(data.radioChannel ?? 0);

    const samyBar = document.getElementById('voice-samy-bar');
    if (samyBar) {
        const width = range <= 1.6 ? 24 : range <= 3.5 ? 48 : 72;
        samyBar.style.width = `${width}px`;
        samyBar.classList.toggle('talking', talking);
        samyBar.classList.toggle('silent', !talking);
    }

    const origenShell = document.querySelector('.voice-origen-shell');
    if (origenShell) origenShell.classList.toggle('talking', talking);

    document.querySelectorAll('.voice-origen-step').forEach((step) => {
        const stepMode = step.dataset.mode;
        const active = stepMode === 'whisper' ? true : stepMode === 'normal' ? mode !== 'whisper' : mode === 'shout';
        step.classList.toggle('active', active);
    });

    const radio = document.getElementById('voice-origen-radio');
    if (radio) radio.classList.toggle('active', radioActive);

    const label = document.getElementById('voice-origen-label');
    if (label) label.textContent = getVoiceModeLabel(mode, radioActive);

    const channel = document.getElementById('voice-origen-channel');
    if (channel) channel.textContent = radioActive && radioChannel > 0 ? `CH ${radioChannel}` : '';
}
