local function getTemp() 
    local sensorData = PlantControllers.t5.getSensorInformation()
    local tempSensorString = ""
    for _,str in ipairs(sensorData) do
        local index = string.find(str,"Current temperature")
        if index ~= nil then
            tempSensorString = str
        end
    end
    if tempSensorString == nil then
        PlantControllers.t5.setWorkAllowed(false)
        error("temp string conversion went wrong! this fully breaks t5 processing, we need to fix the code before we can continue")
    end
    local tempString = string.match(tempSensorString, "§e(%d+)K")
    if tempString == nil then
        PlantControllers.t5.setWorkAllowed(false)
        error("temp string conversion went wrong! this fully breaks t5 processing, we need to fix the code before we can continue")
    end
    return tonumber(tempString)
end

function RunT5(targetLevel)
    local levels = GetFluidLevels()
    local transposer = InputTransposers.t5
    while levels.t5 < targetLevel and levels.helium > 2000 and levels.supercoolant > 40000 and levels.t4 >= T4_MAINTAIN do
        if not PlantControllers.t5.isWorkAllowed() then
            PlantControllers.t5.setWorkAllowed(true)
        end
        WaitForNextCycle(-1)
        local timesHeated = 0
        local timesCooled = 0
        while timesCooled < 3 do
            local temp = getTemp()
            if temp == 10000 and timesCooled == timesHeated then
                timesHeated = timesHeated + 1
            elseif temp == 0 and timesCooled < timesHeated then
                timesCooled = timesCooled + 1
            else 
                if timesHeated == timesCooled then
                    -- heating
                    local targetTemp = 10000
                    local diff = targetTemp-temp
                    local amountHelium = diff / 100
                    local consumeTimeSeconds = amountHelium / 10
                    local success = transposer.proxy.transferFluid(transposer.heliumPlasmaSide, transposer.inputSide, amountHelium, transposer.heliumPlasmaTankNum-1)
                    if not success then
                        print("Failed to transfer helium plasma! Please check your setup!")
                        PlantControllers.t5.setWorkAllowed(false)
                        return false
                    end
                    os.sleep(consumeTimeSeconds+1)
                else
                    -- cooling
                    local targetTemp = 0
                    local diff = temp-targetTemp
                    local amountCoolant = diff / 5
                    local consumeTimeSeconds = amountCoolant / 100
                    local success = transposer.proxy.transferFluid(transposer.superCoolantSide, transposer.inputSide, amountCoolant, transposer.superCoolantTankNum-1)
                    if not success then
                        print("Failed to transfer super coolant! Please check your setup!")
                        PlantControllers.t5.setWorkAllowed(false)
                        return false
                    end
                    os.sleep(consumeTimeSeconds+1)
                end
            end
            
        end
        levels = GetFluidLevels()
    end
    PlantControllers.t5.setWorkAllowed(false)
    return levels.t5 >= targetLevel
end