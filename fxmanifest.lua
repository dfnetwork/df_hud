
name        'df_hud'
description 'A simple HUD for FiveM'
author      'DF Network'

version     '3.0.8'

fx_version 'cerulean'
game       'gta5'


ui_page 'web/index.html'


shared_scripts {
    '@ox_lib/init.lua',
    'init.lua',
    'shared/config.lua',
    'shared/config/core.lua',
    'shared/config/keybinds.lua',
    'shared/config/debug.lua',
    'shared/locales.lua',
    'locales/*.lua',
}

client_scripts {
    'client/custom/*.lua',
    'client/qbcore/*.lua',
    'client/qbox/*.lua',
    'client/esx/*.lua',
    'client/mythic/*.lua',
    'client/nd/*.lua',
    'client/ox/*.lua',
    'client/vrp/*.lua',
    'client/vrpex/*.lua',
    'client/inventory/*.lua',
    'client/main.lua',
}

server_scripts {
    'server/custom/*.lua',
    'server/qbcore/*.lua',
    'server/qbox/*.lua',
    'server/esx/*.lua',
    'server/mythic/*.lua',
    'server/nd/*.lua',
    'server/ox/*.lua',
    'server/vrp/*.lua',
    'server/vrpex/*.lua',
    'server/inventory/*.lua',
    'server/main.lua',
}

files {
    'web/index.html',
    'web/style.css',
    'web/js/*.js',
    'web/*.wav',
    'assets/*.svg',
    'assets/*.png',
}


dependencies {
    'ox_lib',
}


lua54 'yes'

escrow_ignore {
    ''
}
