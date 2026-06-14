function applyLocale(locale, translations = {}) {
    localeCode = locale || localeCode;
    localeMap = translations || {};

    const set = (selector, text) => {
        const el = document.querySelector(selector);
        if (el) el.textContent = text;
    };

    set('.nav-item[data-section="section-style"] span', t('nav-style', 'HUD Style'));
    set('.nav-item[data-section="section-speedo"] span', t('nav-speedo', 'Speedometer Style'));
    set('.nav-item[data-section="section-adjust"] span', t('nav-adjust', 'HUD Adjustment'));
    set('.nav-item[data-section="section-config"] span', t('nav-config', 'Settings'));
    set('#section-style .section-title', t('sec-style-title', 'HUD Style'));
    set('#section-style .section-desc', t('sec-style-desc', 'Select how player stats are displayed.'));
    set('#section-speedo .section-title', t('sec-speedo-title', 'Speedometer Style'));
    set('#section-speedo .section-desc', t('sec-speedo-desc', 'Select how speed and vehicle indicators are displayed.'));
    set('#section-adjust .section-title', t('sec-adjust-title', 'HUD Adjustment'));
    set('#section-adjust .section-desc', t('sec-adjust-desc', 'Drag or resize each element to your preferred position.'));
    set('#section-config .section-title', t('sec-config-title', 'Settings'));

    set('#voice-style-title', t('voice-title', 'Voice HUD'));
    set('#voice-style-desc', t('voice-desc', 'Change the voice indicator style.'));
    set('#voice-label-samy', t('voice-style-samy', 'Samy'));
    set('#voice-label-origen', t('voice-style-origen', 'Origen'));

    document.getElementById('hud-menu-close').textContent = t('btn-close', '✕ Close');
    saveStyleBtn.textContent = t('btn-save-style', 'Save style');
    saveSpeedoBtn.textContent = t('btn-save-speedo', 'Save speedometer');
    saveVoiceBtn.textContent = t('btn-save-voice', 'Save voice');
    document.getElementById('style-preview-hint').textContent = t('hint-preview', 'Preview until you save.');
    document.getElementById('speedo-preview-hint').textContent = t('hint-preview', 'Preview until you save.');
    document.getElementById('voice-preview-hint').textContent = t('hint-preview', 'Preview until you save.');
    document.getElementById('adj-reset-all').textContent = t('btn-reset-adjust', '↺ Restablecer ajuste');
    document.getElementById('cfg-colors-reset').textContent = t('btn-reset-colors', '↺ Reset colors');

    document.querySelectorAll('.adj-btn[data-drag]').forEach((btn) => {
        if (btn.dataset.drag === 'stats-group') btn.textContent = t('btn-move-group', 'Move group');
        if (btn.dataset.drag === 'stats-individual') btn.textContent = t('btn-move-individual', 'Move individual');
        if (btn.dataset.drag === 'speedo') btn.textContent = t('btn-move-speedo', 'Move');
    });
    document.querySelectorAll('.adj-btn[data-resize]').forEach((btn) => {
        if (btn.dataset.resize === 'stats') btn.textContent = t('btn-resize-stats', 'Resize stats');
        if (btn.dataset.resize === 'speedo') btn.textContent = t('btn-resize-speedo', 'Resize speedometer');
    });

    const groupKeys = ['cfg-hd-stats', 'cfg-hd-speedo', 'cfg-hd-visual', 'cfg-hd-behav', 'cfg-hd-extras', 'cfg-hd-mmcomp'];
    document.querySelectorAll('.cfg-group-hd').forEach((el, index) => {
        if (groupKeys[index]) el.textContent = t(groupKeys[index], el.textContent);
    });

    const labelMap = {
        'cfg-show-health': 'lbl-health',
        'cfg-show-armour': 'lbl-armour',
        'cfg-show-hunger': 'lbl-hunger',
        'cfg-show-thirst': 'lbl-thirst',
        'cfg-show-stamina': 'lbl-stamina',
        'cfg-hide-armour-0': 'lbl-hide-armour-0',
        'cfg-auto-hide': 'lbl-auto-hide',
        'cfg-blinkers': 'lbl-blinkers',
        'cfg-engine': 'lbl-engine',
        'cfg-lights': 'lbl-lights',
        'cfg-belt': 'lbl-belt',
        'cfg-fuel': 'lbl-fuel',
        'cfg-animate': 'lbl-animate',
        'cfg-hide-vehicle': 'lbl-hide-vehicle',
        'cfg-compass': 'lbl-compass',
        'cfg-compass-street': 'lbl-compass-street',
    };

    Object.entries(labelMap).forEach(([id, key]) => {
        const input = document.getElementById(id);
        if (!input) return;
        const row = input.closest('.cfg-row');
        const label = row?.querySelector('.cfg-lbl');
        if (label) label.textContent = t(key, label.textContent);
    });

    const hintMap = {
        'cfg-streamer': ['lbl-streamer', 'hint-streamer'],
        'cfg-cinema': ['lbl-cinema', 'hint-cinema'],
        'cfg-hide-hud': ['lbl-hide-hud', 'hint-hide-hud'],
        'cfg-manual-gears': ['lbl-manual-gears', 'hint-manual-gears'],
    };

    Object.entries(hintMap).forEach(([id, keys]) => {
        const input = document.getElementById(id);
        if (!input) return;
        const row = input.closest('.cfg-row');
        const label = row?.querySelector('.cfg-lbl');
        const hint = row?.querySelector('.cfg-hint');
        if (label) label.textContent = t(keys[0], label.textContent);
        if (hint) hint.textContent = t(keys[1], hint.textContent);
    });
}

function syncSaveButtons() {
    saveStyleBtn.disabled = pendingHudStyle === savedHudStyle;
    saveSpeedoBtn.disabled = pendingSpeedoStyle === savedSpeedoStyle;
    saveVoiceBtn.disabled = pendingVoiceStyle === savedVoiceStyle;
}

function syncHudCardState() {
    document.querySelectorAll('.menu-card[data-style]').forEach((card) => {
        card.classList.toggle('selected', card.dataset.style === pendingHudStyle);
        card.classList.toggle('saved', card.dataset.style === savedHudStyle);
    });
    syncSaveButtons();
}

function syncSpeedoCardState() {
    document.querySelectorAll('.speedo-card-select').forEach((card) => {
        card.classList.toggle('selected', card.dataset.speedo === pendingSpeedoStyle);
        card.classList.toggle('saved', card.dataset.speedo === savedSpeedoStyle);
    });
    syncSaveButtons();
}

function syncVoiceCardState() {
    document.querySelectorAll('.voice-card-select').forEach((card) => {
        card.classList.toggle('selected', card.dataset.voiceStyle === pendingVoiceStyle);
        card.classList.toggle('saved', card.dataset.voiceStyle === savedVoiceStyle);
    });
    syncSaveButtons();
}

function setStyle(id) {
    pendingHudStyle = id;
    hudRoot.dataset.style = id;
    hudRoot.dataset.layout = horizontalHudStyles.has(id) ? 'horizontal' : 'compact';
    document.querySelectorAll('.stat-item').forEach((el) => {
        el.classList.toggle('active', el.dataset.style === id);
    });
    queueHudStatsLayout();
    syncHudCardState();
}

function setSpeedoStyle(id) {
    pendingSpeedoStyle = id;
    currentSpeedoStyle = id;
    setActiveSpeedoPanel(id);
    syncSpeedoCardState();
}

function setVoiceStyle(id) {
    pendingVoiceStyle = id;
    currentVoiceStyle = id;
    if (voiceHud) voiceHud.dataset.style = id;
    document.querySelectorAll('.voice-style').forEach((el) => {
        el.classList.toggle('active', el.dataset.voiceStyle === id);
    });
    syncVoiceCardState();
}

function commitHudStyle(id) {
    savedHudStyle = id;
    pendingHudStyle = id;
    setStyle(id);
}

function commitSpeedoStyle(id) {
    savedSpeedoStyle = id;
    pendingSpeedoStyle = id;
    setSpeedoStyle(id);
}

function commitVoiceStyle(id) {
    savedVoiceStyle = id;
    pendingVoiceStyle = id;
    cfg.voiceStyle = id;
    setVoiceStyle(id);
}

function closeMenu() {
    if (pendingHudStyle !== savedHudStyle) setStyle(savedHudStyle);
    if (pendingSpeedoStyle !== savedSpeedoStyle) setSpeedoStyle(savedSpeedoStyle);
    if (pendingVoiceStyle !== savedVoiceStyle) setVoiceStyle(savedVoiceStyle);

    hudMenu.classList.remove('open');
    menuContent.classList.remove('expanded');
    menuSidebar.classList.remove('expanded');
    document.querySelectorAll('.nav-item').forEach((item) => item.classList.remove('active'));
    document.querySelectorAll('.menu-section').forEach((section) => section.classList.remove('active'));
    activeSection = null;
    setDragMode(null);
    setSpeedoDragMode(false);
    fetch('https://df_hud/closeMenu', { method: 'POST', body: JSON.stringify({}) });
}

document.getElementById('hud-menu-close').addEventListener('click', closeMenu);

document.querySelectorAll('.nav-item').forEach((item) => {
    item.addEventListener('click', () => {
        const target = item.dataset.section;
        const sameSection = activeSection === target;

        document.querySelectorAll('.nav-item').forEach((nav) => nav.classList.remove('active'));
        document.querySelectorAll('.menu-section').forEach((section) => section.classList.remove('active'));

        if (sameSection) {
            menuContent.classList.remove('expanded');
            menuSidebar.classList.remove('expanded');
            activeSection = null;
            return;
        }

        item.classList.add('active');
        document.getElementById(target)?.classList.add('active');
        menuContent.classList.add('expanded');
        menuSidebar.classList.add('expanded');
        activeSection = target;
    });
});

document.querySelectorAll('.menu-card[data-style]').forEach((card) => {
    card.addEventListener('click', () => setStyle(card.dataset.style));
});

document.querySelectorAll('.speedo-card-select').forEach((card) => {
    card.addEventListener('click', () => setSpeedoStyle(card.dataset.speedo));
});

document.querySelectorAll('.voice-card-select').forEach((card) => {
    card.addEventListener('click', () => setVoiceStyle(card.dataset.voiceStyle));
});

saveStyleBtn.addEventListener('click', () => {
    if (pendingHudStyle === savedHudStyle) return;
    fetch('https://df_hud/selectStyle', { method: 'POST', body: JSON.stringify({ style: pendingHudStyle }) });
});

saveSpeedoBtn.addEventListener('click', () => {
    if (pendingSpeedoStyle === savedSpeedoStyle) return;
    fetch('https://df_hud/selectSpeedoStyle', { method: 'POST', body: JSON.stringify({ style: pendingSpeedoStyle }) });
});

saveVoiceBtn.addEventListener('click', () => {
    if (pendingVoiceStyle === savedVoiceStyle) return;
    cfg.voiceStyle = pendingVoiceStyle;
    saveCfg();
    commitVoiceStyle(pendingVoiceStyle);
});
