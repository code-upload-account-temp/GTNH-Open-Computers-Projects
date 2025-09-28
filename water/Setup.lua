local shell = require('shell')
local args = {...}
local branch = "main"
local repo = string.format('https://raw.githubusercontent.com/code-upload-account-temp/GTNH-Open-Computers-Projects/refs/heads/%s/water/', branch)
local scripts = {
    "Config.lua",
    "Constants.lua",
    "ManageWaterLine.lua",
    "NetworkDiscovery.lua",
    "TierControllers.lua",
    "T1.lua",
    "T2.lua",
    "T3.lua",
    "T4.lua",
    "T5.lua",
    "T6.lua",
    "T7.lua",
    "T8.lua",
    ".shrc"
}

-- INSTALL
for i=1, #scripts do
    shell.execute(string.format('wget -f %s/%s', repo, scripts[i]))
end