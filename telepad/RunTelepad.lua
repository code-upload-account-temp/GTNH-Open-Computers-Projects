local component = require("component");

local gpu = component.gpu;

local BackgroundIndex = 1
gpu.setPaletteColor(BackgroundIndex, 0x00000000);

local function clearAll()
    local width, height = gpu.getResolution()
    gpu.setBackground(BackgroundIndex, true)
    gpu.fill(0, 0, width, height, " ")
end