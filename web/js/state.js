let localeCode = 'es';
let localeMap = {};

function t(key, fallback = '') {
    return localeMap[key] || fallback || key;
}

const statKeys = ['health', 'armour', 'hunger', 'thirst', 'stamina'];
const STAT_IDS = [...statKeys];
const allPanels = ['hud-boxes', 'hud-bars', 'hud-origen', 'hud-samy', 'hud-circles', 'hud-stars', 'hud-diamonds', 'hud-hex', 'hud-vbar', 'hud-numbered', 'hud-pills', 'hud-icons', 'hud-3d'];
const allSpeedos = ['speedo-minimal', 'speedo-card', 'speedo-dash', 'speedo-gauge', 'speedo-arc', 'speedo-cyber', 'speedo-bars', 'speedo-corner', 'speedo-halo', 'speedo-neon', 'speedo-samy', 'speedo-race'];
const allVoiceStyles = ['voice-samy', 'voice-origen'];
const vehicleSpeedos = ['speedo-bike', 'speedo-boat', 'speedo-air'];
const allExtSpeedos = [...allSpeedos, ...vehicleSpeedos];
const horizontalHudStyles = new Set(allPanels);

let MAX_SPEED = 200;
const GAUGE_ARC = 353.43;
const ARC_ARC = 228.9;
const NEON_CIRC = 452.39;

let currentSpeedoStyle = 'speedo-minimal';
let currentVoiceStyle = 'voice-samy';
let inVehicle = false;
let hudVisible = false;
let minimapVisible = false;
let cinemaCommandActive = false;
let cinemaCommandBackup = null;
let manualGearsAvailable = false;
let lastCinemaSync = null;
let lastHideHudSync = null;
let lastManualGearsSync = null;

let dragMode = null;
let activeDragStat = null;
let dragStartX = 0;
let dragStartY = 0;
let dragOrigPos = {};

let speedoDragActive = false;
let speedoDragStartX = 0;
let speedoDragStartY = 0;
let speedoDragOrigLeft = 0;
let speedoDragOrigTop = 0;

let blinkerInterval = null;
let blinkerPhase = 0;
let blinkerCycleMs = 650;
let seatbeltBeepInterval = null;

const DEFAULT_CFG = {
    showHealth: true,
    showArmour: true,
    showHunger: true,
    showThirst: true,
    showStamina: true,
    hideArmourAt0: false,
    autoHide: false,
    autoHideThreshold: 80,
    speedUnit: 'kmh',
    gaugeMaxSpeed: 200,
    showBlinkers: true,
    showEngine: true,
    showLights: true,
    showBelt: true,
    showFuel: true,
    scale: 100,
    opacity: 100,
    colorHealth: '#ff4757',
    colorArmour: '#0984e3',
    colorHunger: '#fdcb6e',
    colorThirst: '#00cec9',
    colorStamina: '#6c5ce7',
    colorSpeedoPrimary: '#55efc4',
    colorSpeedoWarning: '#fdcb6e',
    colorSpeedoDanger: '#ff4757',
    colorSpeedoAccent: '#00d2ff',
    animateStats: true,
    hideInVehicle: false,
    streamerMode: false,
    cinemaMode: false,
    cinemaSize: 13,
    hideHud: false,
    manualGearsEnabled: false,
    showCompass: true,
    showCompassStreet: true,
    voiceStyle: 'voice-samy',
};

let cfg = { ...DEFAULT_CFG };
const statVals = { health: 100, armour: 0, hunger: 100, thirst: 100, stamina: 100 };

const hudMenu = document.getElementById('hud-menu');
const menuContent = document.getElementById('hud-menu-content');
const menuSidebar = document.getElementById('hud-menu-sidebar');
const hudRoot = document.getElementById('hud');
const voiceHud = document.getElementById('voice-hud');
const saveStyleBtn = document.getElementById('save-style-btn');
const saveSpeedoBtn = document.getElementById('save-speedo-btn');
const saveVoiceBtn = document.getElementById('save-voice-btn');

let activeSection = null;
let savedHudStyle = 'hud-boxes';
let pendingHudStyle = 'hud-boxes';
let savedSpeedoStyle = currentSpeedoStyle;
let pendingSpeedoStyle = currentSpeedoStyle;
let savedVoiceStyle = cfg.voiceStyle;
let pendingVoiceStyle = cfg.voiceStyle;

const buckleSound = new Audio('carbuckle.wav');
const unbuckleSound = new Audio('carunbuckle.wav');
const audioCtx = new (window.AudioContext || window.webkitAudioContext)();

function headingToDir(h) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[Math.round(((h % 360) + 360) % 360 / 45) % 8];
}

function setActiveSpeedoPanel(id) {
    allExtSpeedos.forEach((panelId) => {
        const el = document.getElementById(panelId);
        if (el) el.classList.remove('active');
    });

    const target = document.getElementById(id);
    if (target) target.classList.add('active');
}

function playBeep() {
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.connect(gain);
    gain.connect(audioCtx.destination);
    osc.type = 'sine';
    osc.frequency.value = 880;
    gain.gain.setValueAtTime(0.25, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.18);
    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.18);
}

function startSeatbeltWarning() {
    if (seatbeltBeepInterval) return;
    playBeep();
    seatbeltBeepInterval = setInterval(playBeep, 1800);
}

function stopSeatbeltWarning() {
    if (!seatbeltBeepInterval) return;
    clearInterval(seatbeltBeepInterval);
    seatbeltBeepInterval = null;
}

function playBlinkerTick() {
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.connect(gain);
    gain.connect(audioCtx.destination);
    osc.type = 'square';
    osc.frequency.value = blinkerPhase % 2 === 0 ? 540 : 430;
    gain.gain.setValueAtTime(0.12, audioCtx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.04);
    osc.start(audioCtx.currentTime);
    osc.stop(audioCtx.currentTime + 0.04);
    blinkerPhase += 1;
}

function startBlinkerSound() {
    if (blinkerInterval) return;
    blinkerPhase = 0;
    playBlinkerTick();
    blinkerInterval = setInterval(playBlinkerTick, blinkerCycleMs / 2);
}

function stopBlinkerSound() {
    if (!blinkerInterval) return;
    clearInterval(blinkerInterval);
    blinkerInterval = null;
}

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && hudMenu.classList.contains('open')) {
        closeMenu();
    }
});
