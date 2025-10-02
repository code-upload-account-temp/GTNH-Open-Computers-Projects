local function getControlSignal() 
    local sensorData = PlantControllers.t7.getSensorInformation()
    local controlSensorString = ""
    for _,str in ipairs(sensorData) do
        local index = string.find(str,"Current control signal (binary)")
        if index ~= nil then
            controlSensorString = str
        end
    end
    if controlSensorString == nil then
        PlantControllers.t4.setWorkAllowed(false)
        error("failed to find control signal in sensor data for T7 controller, something's gone wrong and T7 can't function")
    end
    local binaryString = string.match(controlSensorString, "0b§e(%d+)")
    if binaryString == nil then
        PlantControllers.t4.setWorkAllowed(false)
        error("control signal conversion went wrong! this fully breaks t7 processing, we need to fix the code before we can continue")
    end
    local bits = {
        0,0,0,0
    }
    local bitNum = 4
    for bitString in string.gmatch(string.reverse(binaryString), "%d") do
        bits[bitNum] = tonumber(bitString)
        bitNum = bitNum - 1
    end
    return bits[1], bits[2], bits[3], bits[4]
end

function RunT7(targetLevel)
    local levels = GetFluidLevels()
    local solids = GetSolidLevels()
    local transposer = InputTransposers.t7
    if levels.t4 < targetLevel then
        WaitForNextCycle(2)
        if not PlantControllers.t7.isWorkAllowed() then
            PlantControllers.t7.setWorkAllowed(true)
        end
        while levels.t7 < targetLevel and solids.upQuarks > 6 and solids.downQuarks > 6 and solids.topQuarks > 6 and solids.bottomQuarks > 6 and solids.strangeQuarks > 6 and solids.charmQuarks > 6 and levels.t6 > T6_MAINTAIN do
            WaitForNextCycle(-1)
            local bit1, bit2, bit3, bit4 = getControlSignal()
            -- TODO: process bits
            levels = GetFluidLevels()
            solids = GetSolidLevels()
        end
        PlantControllers.t7.setWorkAllowed(false)
    end
    return levels.t7 >= targetLevel
end