local shell = require('shell')
local args = {...}
local branch = "main"
local repo = string.format('https://raw.githubusercontent.com/code-upload-account-temp/GTNH-Open-Computers-Projects/refs/heads/%s/water/', branch)
local scripts = {
    "Config.lua",
    "Constants.lua",
    "ManageWaterLine.lua",
    "NetworkDiscovery.lua",
    ".shrc"
}

-- INSTALL
for i=1, #scripts do
    shell.execute(string.format('wget -f %s%s/%s', repo, branch, scripts[i]))
end