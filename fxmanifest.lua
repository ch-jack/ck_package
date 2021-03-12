fx_version 'cerulean'

game 'gta5'

lua54 'yes'

ui_page "nui/ui.html"

files {
  "nui/ui.html",
  "nui/css/*.css",
  "nui/js/*.js",
  "nui/img/items/*.png",
}

client_script 'client/*.lua'

server_scripts{
  '@mysql-async/lib/MySQL.lua',
  'server/*.lua'
}
