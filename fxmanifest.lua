fx_version 'cerulean'
game 'gta5'

name 'ender_admin'
author 'EnderDevelopment'
description 'Standalone custom FiveM administration menu'
version '1.0.0'

ui_page 'ui/index.html'

shared_script 'config.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js'
}
