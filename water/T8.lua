local function hasSucceeded() 
    local sensorData = PlantControllers.t8.getSensorInformation()
    local successSensorString = nil
    for _,str in ipairs(sensorData) do
        local index = string.find(str, "Quark Combination correctly identified")
        if index ~= nil then
            successSensorString = str
        end
    end
    if successSensorString == nil then
        PlantControllers.t8.setWorkAllowed(false)
        error("failed to find control signal in sensor data for T8 controller, something's gone wrong and T8 can't function")
    end
    local successString = string.match(successSensorString, "§c(%a+)")
    if successString == nil then
        PlantControllers.t8.setWorkAllowed(false)
        error("control signal conversion went wrong! this fully breaks t8 processing, we need to fix the code before we can continue")
    end
    return successString == "Yes"
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