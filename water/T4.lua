local function getpH() 
    local sensorData = PlantControllers.t4.getSensorInformation()
    local phSensorString = ""
    for _,str in ipairs(sensorData) do
        local index = string.find(str,"Current pH Value")
        if index ~= nil then
            phSensorString = str
        end
    end
    if phSensorString == nil then
        print("failed to find ph value in sensor data for T4 controller, something's gone wrong and T4 can't function")
        PlantControllers.t4.setWorkAllowed(false)
        error("pH string conversion went wrong! this fully breaks t4 processing, we need to fix the code before we can continue")
    end
    local phString = string.match(phSensorString, "§e(%d+%.%d+)")
    if phString == nil then
        PlantControllers.t4.setWorkAllowed(false)
        error("pH string conversion went wrong! this fully breaks t4 processing, we need to fix the code before we can continue")
    end
    return tonumber(phString)
end

function RunT4(targetLevel)
    local levels = GetFluidLevels()
    local solids = GetSolidLevels()
    local transposer = InputTransposers.t4
    if levels.t4 < targetLevel then
        WaitForNextCycle(2)
        if not PlantControllers.t4.isWorkAllowed() then
            PlantControllers.t4.setWorkAllowed(true)
        end
        while levels.t4 < targetLevel and levels.hydrochloric > 16000 and solids.sodiumHydroxide > 512 and levels.t3 > T3_MAINTAIN do
            WaitForNextCycle(-1)
            local phBalanced = false
            local phConfirmed = false
            while not phConfirmed do
                local pH = getpH()
                if pH > 6.95 and pH < 7.05 then
                    -- Perfect, we're done
                    print("pH balanced at ", pH)
                    if phBalanced then
                        phConfirmed = true
                    end
                    phBalanced = true
                elseif pH >= 7.05 then
                    -- Need to add hydrochloric, 10L per 0.01
                    print("Adding HCl at ", pH)
                    local difference = (pH - 7)/0.01
                    local hcl = difference * 10
                    local success = transposer.proxy.transferFluid(transposer.hydrochloricSide, transposer.inputSide, hcl, transposer.hydrochloricTankNum-1)
                    if not success then
                        print("Failed to transfer hydrochloric acid! Please check your setup!")
                        PlantControllers.t4.setWorkAllowed(false)
                        return false
                    end
                else
                    -- Need to add sodium hydroxide, 1 per 0.01
                    print("Adding NaOH at ", pH)
                    local difference = (7 - pH)/0.01
                    local NaOH = difference
                    if NaOH > 64 then
                        NaOH = 64 -- we only move a stack at a time at most, maximum 4 iterations to move the biggest distance upwards
                    end
                    transposer.proxy.transferItem(transposer.sodiumHydroxideSide, transposer.inputSide, NaOH)
                end
                os.sleep(2)
            end
            levels = GetFluidLevels()
            solids = GetSolidLevels()
        end
        PlantControllers.t2.setWorkAllowed(false)
    end
    return levels.t2 >= targetLevel
end