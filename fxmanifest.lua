fx_version "adamant"
game "rdr3"
lua54 "yes"

author 'JustRoy edited by xv-scripts'
description 'This script is made by JustRoy edited by xv-scripts'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

version '1.0'
vorp_checker 'yes'
vorp_name '^4Resource version Check^3'
vorp_github 'https://github.com/JustRoys/jr-3dme'

shared_scripts {
    'config/language.lua',
    'config/config.lua',
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    'config/sv_config.lua',
    'server/server.lua',
}