local function hasSucceeded() 
    local sensorData = PlantControllers.t8.getSensorInformation()
    local successSensorString = ""
    for _,str in ipairs(sensorData) do
        local index = string.find(str,"Current control signal (binary)")
        if index ~= nil then
            successSensorString = str
        end
    end
    if successSensorString == nil then
        PlantControllers.t7.setWorkAllowed(false)
        error("failed to find control signal in sensor data for T7 controller, something's gone wrong and T7 can't function")
    end
    local binaryString = string.match(successSensorString, "0b§e(%d+)")
    if binaryString == nil then
        PlantControllers.t7.setWorkAllowed(false)
        error("control signal conversion went wrong! this fully breaks t7 processing, we need to fix the code before we can continue")
    end
    local bits = {
        0,0,0,0
    }
    local i = 4
    for bitString in string.gmatch(string.reverse(binaryString), "%d") do
        bits[i] = tonumber(bitString)
        i = i - 1
    end
    return bits[1], bits[2], bits[3], bits[4]
end

function RunT8(targetLevel)
    local levels = GetFluidLevels()
    print("Not yet implemented")
    return false
    -- while levels.t8 < targetLevel and solids.upQuarks > 6 and solids.downQuarks > 6 and solids.topQuarks > 6 and solids.bottomQuarks > 6 and solids.strangeQuarks > 6 and solids.charmQuarks > 6 do
    --     if not PlantControllers.t8.isWorkAllowed() then
    --         PlantControllers.t8.setWorkAllowed(true)
    --     end
    --     os.sleep(120)
    -- end
    -- PlantControllers.t8.setWorkAllowed(false)
    -- return levels.t8 >= targetLevel
end