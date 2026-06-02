fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Yasser (Storm Development)'
description 'YS Blackmarket - Blackmarket sécurisé avec interface NUI futuriste'
version '1.0.0'

-- Client-side scripts
client_scripts {
    'config.lua',
    'client.lua'
}

-- Server-side scripts
server_scripts {
    'config.lua',
    'server.lua'
}

-- NUI (HTML/JS/CSS) files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/assets/images/weapons/*.png',
    'html/assets/images/items/*.png',
    'html/assets/sounds/*.wav'
}