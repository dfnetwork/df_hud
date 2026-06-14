let statsCustomPositioning = false;
let hudLayoutFrame = null;
const HUD_POSITIONS_STORAGE_KEY = 'df_hud-positions';
const HUD_POSITIONS_VERSION = 2;
const HUD_SIZES_STORAGE_KEY = 'df_hud-sizes';
const HUD_SIZES_VERSION = 1;
const HUD_SCALE_MIN = 0.65;
const HUD_SCALE_MAX = 2.25;

let resizeMode = null;
let activeResizeStat = null;
let resizingSpeedo = false;
let resizeStartX = 0;
let resizeStartY = 0;
let resizeStartScale = 1;
let resizeReferenceSize = 120;

let statSizeScales = Object.fromEntries(STAT_IDS.map((id) => [id, 1]));
let speedoSizeScale = 1;

function clamp(value, min, max) {
    return Math.min(max, Math.max(min, value));
}

function getPointerCoords(event) {
    const point = event.touches ? event.touches[0] : event;
    return { x: point.clientX, y: point.clientY };
}

function getBaseHudScale(baseScale = null) {
    if (typeof baseScale === 'number' && Number.isFinite(baseScale)) {
        return baseScale;
    }

    return (cfg?.scale ?? 100) / 100;
}

function applyHudElementScales(baseScale = null) {
    const resolvedScale = getBaseHudScale(baseScale);

    STAT_IDS.forEach((id) => {
        const el = document.getElementById(`stat-${id}`);
        if (!el) return;
        el.style.zoom = resolvedScale * (statSizeScales[id] ?? 1);
    });

    const speedoEl = document.getElementById('speedo');
    if (speedoEl) {
        speedoEl.style.zoom = resolvedScale * speedoSizeScale;
    }

    queueHudStatsLayout();
}

function loadSavedSizes() {
    statSizeScales = Object.fromEntries(STAT_IDS.map((id) => [id, 1]));
    speedoSizeScale = 1;

    try {
        const saved = JSON.parse(localStorage.getItem(HUD_SIZES_STORAGE_KEY) || 'null');
        if (!saved) {
            applyHudElementScales();
            return;
        }

        if (saved.version !== HUD_SIZES_VERSION || typeof saved !== 'object') {
            localStorage.removeItem(HUD_SIZES_STORAGE_KEY);
            applyHudElementScales();
            return;
        }

        if (saved.stats && typeof saved.stats === 'object') {
            STAT_IDS.forEach((id) => {
                const scale = Number(saved.stats[id]);
                if (Number.isFinite(scale)) {
                    statSizeScales[id] = clamp(scale, HUD_SCALE_MIN, HUD_SCALE_MAX);
                }
            });
        }

        if (Number.isFinite(Number(saved.speedo))) {
            speedoSizeScale = clamp(Number(saved.speedo), HUD_SCALE_MIN, HUD_SCALE_MAX);
        }
    } catch (error) {
        localStorage.removeItem(HUD_SIZES_STORAGE_KEY);
    }

    applyHudElementScales();
}

function saveHudSizes() {
    localStorage.setItem(HUD_SIZES_STORAGE_KEY, JSON.stringify({
        version: HUD_SIZES_VERSION,
        stats: statSizeScales,
        speedo: speedoSizeScale,
    }));
}

function resetHudSizes() {
    localStorage.removeItem(HUD_SIZES_STORAGE_KEY);
    statSizeScales = Object.fromEntries(STAT_IDS.map((id) => [id, 1]));
    speedoSizeScale = 1;
    applyHudElementScales();
}

function applyPos(el, left, top) {
    el.style.left = `${left}px`;
    el.style.top = `${top}px`;
    el.style.bottom = 'auto';
}

function getHudLayoutMetric(name, fallback) {
    const host = document.getElementById('hud') || document.documentElement;
    const raw = getComputedStyle(host).getPropertyValue(name).trim();
    const value = Number.parseFloat(raw);
    return Number.isFinite(value) ? value : fallback;
}

function layoutHudStats(force = false) {
    if (!hudRoot) {
        return;
    }

    if (hudRoot.dataset.layout !== 'horizontal') {
        if (force && !statsCustomPositioning) {
            STAT_IDS.forEach((id) => {
                const el = document.getElementById(`stat-${id}`);
                if (!el) return;
                el.style.left = '';
                el.style.top = '';
                el.style.bottom = '';
            });
        }
        return;
    }

    if (!force && (dragMode || statsCustomPositioning)) {
        return;
    }

    const startLeft = getHudLayoutMetric(minimapVisible ? '--hud-row-start-visible' : '--hud-row-start-hidden', minimapVisible ? 146 : 22);
    const bottom = getHudLayoutMetric(minimapVisible ? '--hud-row-bottom-visible' : '--hud-row-bottom-hidden', minimapVisible ? 96 : 28);
    const gap = getHudLayoutMetric('--hud-row-gap', 8);
    let currentLeft = startLeft;

    STAT_IDS.forEach((id) => {
        const el = document.getElementById(`stat-${id}`);
        if (!el || el.style.display === 'none') return;

        const width = Math.ceil(el.getBoundingClientRect().width || el.offsetWidth || 0);
        el.style.left = `${currentLeft}px`;
        el.style.top = 'auto';
        el.style.bottom = `${bottom}px`;
        currentLeft += width + gap;
    });
}

function queueHudStatsLayout(force = false) {
    if (hudLayoutFrame) cancelAnimationFrame(hudLayoutFrame);
    hudLayoutFrame = requestAnimationFrame(() => {
        hudLayoutFrame = null;
        layoutHudStats(force);
    });
}

function loadSavedPositions() {
    try {
        const saved = JSON.parse(localStorage.getItem(HUD_POSITIONS_STORAGE_KEY) || 'null');
        if (!saved) return;

        if (saved.version !== HUD_POSITIONS_VERSION || !saved.positions || typeof saved.positions !== 'object') {
            localStorage.removeItem(HUD_POSITIONS_STORAGE_KEY);
            statsCustomPositioning = false;
            queueHudStatsLayout(true);
            return;
        }

        statsCustomPositioning = saved.mode === 'custom';
        STAT_IDS.forEach((id) => {
            const pos = saved.positions[id];
            const el = document.getElementById(`stat-${id}`);
            if (pos && el) applyPos(el, pos.left, pos.top);
        });
    } catch (error) {}
}

function saveCurPositions() {
    const positions = {};
    STAT_IDS.forEach((id) => {
        const el = document.getElementById(`stat-${id}`);
        if (!el) return;
        const rect = el.getBoundingClientRect();
        positions[id] = { left: rect.left, top: rect.top };
    });

    statsCustomPositioning = true;
    localStorage.setItem(HUD_POSITIONS_STORAGE_KEY, JSON.stringify({
        version: HUD_POSITIONS_VERSION,
        mode: 'custom',
        positions,
    }));
}

function resetAllPositions() {
    localStorage.removeItem(HUD_POSITIONS_STORAGE_KEY);
    statsCustomPositioning = false;
    STAT_IDS.forEach((id) => {
        const el = document.getElementById(`stat-${id}`);
        if (!el) return;
        el.style.left = '';
        el.style.top = '';
        el.style.bottom = '';
    });
    queueHudStatsLayout(true);
}

function snapshotPositions() {
    STAT_IDS.forEach((id) => {
        const el = document.getElementById(`stat-${id}`);
        if (!el) return;
        const rect = el.getBoundingClientRect();
        dragOrigPos[id] = { left: rect.left, top: rect.top };
        applyPos(el, rect.left, rect.top);
    });
}

function clearResizeMode() {
    resizeMode = null;
    activeResizeStat = null;
    resizingSpeedo = false;

    STAT_IDS.forEach((id) => {
        const el = document.getElementById(`stat-${id}`);
        if (el) el.classList.remove('resize-active');
    });

    const speedoEl = document.getElementById('speedo');
    if (speedoEl) {
        speedoEl.classList.remove('resize-active');
        if (!inVehicle && !speedoDragActive) {
            speedoEl.style.visibility = 'hidden';
        }
    }

    document.querySelectorAll('.adj-btn[data-resize]').forEach((btn) => {
        btn.classList.remove('adj-btn-on');
    });
}

function setResizeMode(mode) {
    if (resizeMode === mode) {
        clearResizeMode();
        return;
    }

    setDragMode(null);
    setSpeedoDragMode(false);
    clearResizeMode();

    resizeMode = mode;
    document.querySelectorAll('.adj-btn[data-resize]').forEach((btn) => {
        btn.classList.toggle('adj-btn-on', btn.dataset.resize === mode);
    });

    if (mode === 'stats') {
        STAT_IDS.forEach((id) => {
            const el = document.getElementById(`stat-${id}`);
            if (el) el.classList.add('resize-active');
        });
        return;
    }

    if (mode === 'speedo') {
        const speedoEl = document.getElementById('speedo');
        if (!speedoEl) return;
        setActiveSpeedoPanel(currentSpeedoStyle);
        speedoEl.style.visibility = 'visible';
        speedoEl.classList.add('resize-active');
    }
}

function onPointerMove(event) {
    const { x, y } = getPointerCoords(event);
    const deltaX = x - dragStartX;
    const deltaY = y - dragStartY;

    if (dragMode === 'group') {
        STAT_IDS.forEach((id) => {
            const el = document.getElementById(`stat-${id}`);
            if (el && dragOrigPos[id]) applyPos(el, dragOrigPos[id].left + deltaX, dragOrigPos[id].top + deltaY);
        });
    } else if (dragMode === 'individual' && activeDragStat) {
        const el = document.getElementById(`stat-${activeDragStat}`);
        if (el && dragOrigPos[activeDragStat]) {
            applyPos(el, dragOrigPos[activeDragStat].left + deltaX, dragOrigPos[activeDragStat].top + deltaY);
        }
    }

    if (event.cancelable) event.preventDefault();
}

function onPointerUp() {
    document.removeEventListener('mousemove', onPointerMove);
    document.removeEventListener('mouseup', onPointerUp);
    document.removeEventListener('touchmove', onPointerMove);
    document.removeEventListener('touchend', onPointerUp);
    saveCurPositions();
    activeDragStat = null;
}

function onStatPointerDown(event) {
    if (!dragMode) return;
    if (event.target.closest('.resize-handle')) return;

    const { x, y } = getPointerCoords(event);
    dragStartX = x;
    dragStartY = y;
    if (dragMode === 'individual') activeDragStat = event.currentTarget.dataset.stat;
    snapshotPositions();
    document.addEventListener('mousemove', onPointerMove);
    document.addEventListener('mouseup', onPointerUp);
    document.addEventListener('touchmove', onPointerMove, { passive: false });
    document.addEventListener('touchend', onPointerUp);
    if (event.cancelable) event.preventDefault();
}

function setDragMode(mode) {
    if (dragMode === mode) mode = null;
    if (mode) {
        clearResizeMode();
        setSpeedoDragMode(false);
    }

    dragMode = mode;
    STAT_IDS.forEach((id) => {
        const el = document.getElementById(`stat-${id}`);
        if (el) el.classList.toggle('drag-active', !!mode);
    });
    document.querySelectorAll('.adj-btn[data-drag]').forEach((btn) => {
        btn.classList.toggle('adj-btn-on', btn.dataset.drag === `stats-${mode}`);
    });
}

function applySpeedoPos(left, top) {
    const el = document.getElementById('speedo');
    if (!el) return;
    el.style.left = `${left}px`;
    el.style.top = `${top}px`;
    el.style.right = 'auto';
    el.style.bottom = 'auto';
}

function loadSpeedoPos() {
    try {
        const saved = JSON.parse(localStorage.getItem('df_hud-speedo-pos') || 'null');
        if (saved) applySpeedoPos(saved.left, saved.top);
    } catch (error) {}
}

function saveSpeedoPos() {
    const el = document.getElementById('speedo');
    if (!el) return;
    const rect = el.getBoundingClientRect();
    localStorage.setItem('df_hud-speedo-pos', JSON.stringify({ left: rect.left, top: rect.top }));
}

function resetSpeedoPos() {
    localStorage.removeItem('df_hud-speedo-pos');
    const el = document.getElementById('speedo');
    if (!el) return;
    el.style.left = '';
    el.style.top = '';
    el.style.right = '';
    el.style.bottom = '';
}

function onSpeedoPointerMove(event) {
    const { x, y } = getPointerCoords(event);
    applySpeedoPos(speedoDragOrigLeft + x - speedoDragStartX, speedoDragOrigTop + y - speedoDragStartY);
    if (event.cancelable) event.preventDefault();
}

function onSpeedoPointerUp() {
    document.removeEventListener('mousemove', onSpeedoPointerMove);
    document.removeEventListener('mouseup', onSpeedoPointerUp);
    document.removeEventListener('touchmove', onSpeedoPointerMove);
    document.removeEventListener('touchend', onSpeedoPointerUp);
    saveSpeedoPos();
}

function onSpeedoPointerDown(event) {
    if (!speedoDragActive) return;
    if (event.target.closest('.resize-handle')) return;

    const { x, y } = getPointerCoords(event);
    const el = document.getElementById('speedo');
    if (!el) return;
    const rect = el.getBoundingClientRect();
    speedoDragStartX = x;
    speedoDragStartY = y;
    speedoDragOrigLeft = rect.left;
    speedoDragOrigTop = rect.top;
    applySpeedoPos(rect.left, rect.top);
    document.addEventListener('mousemove', onSpeedoPointerMove);
    document.addEventListener('mouseup', onSpeedoPointerUp);
    document.addEventListener('touchmove', onSpeedoPointerMove, { passive: false });
    document.addEventListener('touchend', onSpeedoPointerUp);
    if (event.cancelable) event.preventDefault();
}

function setSpeedoDragMode(active) {
    speedoDragActive = active;
    const el = document.getElementById('speedo');
    if (!el) return;

    if (active) {
        clearResizeMode();
        setActiveSpeedoPanel(currentSpeedoStyle);
        el.style.visibility = 'visible';
        el.classList.add('drag-active');
        el.addEventListener('mousedown', onSpeedoPointerDown);
        el.addEventListener('touchstart', onSpeedoPointerDown, { passive: false });
    } else {
        el.classList.remove('drag-active');
        el.removeEventListener('mousedown', onSpeedoPointerDown);
        el.removeEventListener('touchstart', onSpeedoPointerDown);
        if (!inVehicle) el.style.visibility = 'hidden';
    }

    const btn = document.querySelector('.adj-btn[data-drag="speedo"]');
    if (btn) btn.classList.toggle('adj-btn-on', active);
}

function onResizePointerMove(event) {
    const { x, y } = getPointerCoords(event);
    const deltaX = x - resizeStartX;
    const deltaY = y - resizeStartY;
    const dominantDelta = Math.abs(deltaX) >= Math.abs(deltaY) ? deltaX : deltaY;
    const nextScale = clamp(resizeStartScale * (1 + (dominantDelta / Math.max(resizeReferenceSize, 60))), HUD_SCALE_MIN, HUD_SCALE_MAX);

    if (resizingSpeedo) {
        speedoSizeScale = nextScale;
    } else if (activeResizeStat) {
        statSizeScales[activeResizeStat] = nextScale;
    }

    applyHudElementScales();
    if (event.cancelable) event.preventDefault();
}

function onResizePointerUp() {
    document.removeEventListener('mousemove', onResizePointerMove);
    document.removeEventListener('mouseup', onResizePointerUp);
    document.removeEventListener('touchmove', onResizePointerMove);
    document.removeEventListener('touchend', onResizePointerUp);

    if (resizingSpeedo || activeResizeStat) {
        saveHudSizes();
    }

    activeResizeStat = null;
    resizingSpeedo = false;
}

function onResizeHandlePointerDown(event) {
    if (!resizeMode) return;

    const handle = event.currentTarget;
    const { x, y } = getPointerCoords(event);
    const targetType = handle.dataset.resizeType;
    const targetId = handle.dataset.resizeId;

    if (targetType === 'stat') {
        if (resizeMode !== 'stats') return;
        activeResizeStat = targetId;
        resizingSpeedo = false;
        resizeStartScale = statSizeScales[targetId] ?? 1;
    } else {
        if (resizeMode !== 'speedo') return;
        activeResizeStat = null;
        resizingSpeedo = true;
        resizeStartScale = speedoSizeScale;
    }

    const host = handle.parentElement;
    const rect = host ? host.getBoundingClientRect() : { width: 120, height: 120 };
    resizeReferenceSize = Math.max(rect.width, rect.height, 60);
    resizeStartX = x;
    resizeStartY = y;

    document.addEventListener('mousemove', onResizePointerMove);
    document.addEventListener('mouseup', onResizePointerUp);
    document.addEventListener('touchmove', onResizePointerMove, { passive: false });
    document.addEventListener('touchend', onResizePointerUp);

    event.stopPropagation();
    if (event.cancelable) event.preventDefault();
}

function createResizeHandle(type, id) {
    const handle = document.createElement('button');
    handle.type = 'button';
    handle.className = 'resize-handle';
    handle.dataset.resizeType = type;
    if (id) handle.dataset.resizeId = id;
    handle.setAttribute('aria-label', type === 'speedo' ? 'Resize speedometer' : 'Resize stat');
    handle.addEventListener('mousedown', onResizeHandlePointerDown);
    handle.addEventListener('touchstart', onResizeHandlePointerDown, { passive: false });
    return handle;
}

function ensureResizeHandles() {
    STAT_IDS.forEach((id) => {
        const el = document.getElementById(`stat-${id}`);
        if (!el || el.querySelector('.resize-handle')) return;
        el.appendChild(createResizeHandle('stat', id));
    });

    const speedoEl = document.getElementById('speedo');
    if (speedoEl && !speedoEl.querySelector('.resize-handle')) {
        speedoEl.appendChild(createResizeHandle('speedo'));
    }
}

STAT_IDS.forEach((id) => {
    const el = document.getElementById(`stat-${id}`);
    if (!el) return;
    el.addEventListener('mousedown', onStatPointerDown);
    el.addEventListener('touchstart', onStatPointerDown, { passive: false });
});

ensureResizeHandles();

document.querySelectorAll('.adj-btn[data-drag]').forEach((btn) => {
    btn.addEventListener('click', () => {
        if (btn.dataset.drag === 'stats-group') setDragMode('group');
        if (btn.dataset.drag === 'stats-individual') setDragMode('individual');
    });
});

document.querySelectorAll('.adj-btn[data-resize]').forEach((btn) => {
    btn.addEventListener('click', () => setResizeMode(btn.dataset.resize));
});

document.querySelector('.adj-btn[data-drag="speedo"]').addEventListener('click', () => setSpeedoDragMode(!speedoDragActive));

document.getElementById('adj-reset-all').addEventListener('click', () => {
    resetAllPositions();
    resetSpeedoPos();
    resetHudSizes();
    setDragMode(null);
    setSpeedoDragMode(false);
    clearResizeMode();
});
