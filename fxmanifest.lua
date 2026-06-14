
name        'df_hud'
description 'A simple HUD for FiveM'
author      'DF Network'

version     '1.0.0'

fx_version 'cerulean'
game       'gta5'


ui_page 'web/index.html'


shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/config/core.lua',
    'shared/config/keybinds.lua',
    'shared/locales.lua',
    'locales/*.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
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
