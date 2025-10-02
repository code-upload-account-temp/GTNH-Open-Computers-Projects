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
        PlantControllers.t7.setWorkAllowed(false)
        error("failed to find control signal in sensor data for T7 controller, something's gone wrong and T7 can't function")
    end
    local binaryString = string.match(controlSensorString, "0b§e(%d+)")
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

function RunT7(targetLevel)
    local levels = GetFluidLevels()
    local solids = GetSolidLevels()
    local transposer = InputTransposers.t7
    if levels.t7 < targetLevel then
        WaitForNextCycle(2)
        if not PlantControllers.t7.isWorkAllowed() then
            PlantControllers.t7.setWorkAllowed(true)
        end
        while levels.t7 < targetLevel and solids.upQuarks > 6 and solids.downQuarks > 6 and solids.topQuarks > 6 and solids.bottomQuarks > 6 and solids.strangeQuarks > 6 and solids.charmQuarks > 6 and levels.t6 > T6_MAINTAIN do
            WaitForNextCycle(-1)
            local bit4, bit3, bit2, bit1 = getControlSignal()
            if not bit4 then
                -- skip all other processing if bit4 is set
                if bit3 then
                    -- needs neutronium
                    print("Adding neutronium for T7")
                    local success = transposer.proxy.transferFluid(transposer.fluidsSide, transposer.inputSide, 4608, transposer.fluidsTankMap.neutronium-1)
                    if not success then
                        PlantControllers.t7.setWorkAllowed(false)
                        print("failed to transfer molten neutronium for t7, check your setup!")
                        return false
                    end
                end
                if bit2 then
                    -- needs superconductor base
                    print("Adding molten superconductor base for T7")
                    local success = transposer.proxy.transferFluid(transposer.superConductorSide, transposer.inputSide, 1440, transposer.superConductorTankNum-1)
                    if not success then
                        PlantControllers.t7.setWorkAllowed(false)
                        print("failed to transfer molten superconductor base for t7, check your setup!")
                        return false
                    end
                end
                if bit1 then
                    -- needs noble gas, bits 2 and 3 tell us which one (double duty with neutronium and superconductor)
                    local tankNum = -1
                    local amount = 0
                    if bit2 and bit3 then

                        -- xenon
                        tankNum = transposer.fluidsTankMap.xenon
                        amount = 2500
                    elseif bit3 then
                        -- krypton
                        tankNum = transposer.fluidsTankMap.krypton
                        amount = 5000
                    elseif bit2 then
                        -- neon
                        tankNum = transposer.fluidsTankMap.neon
                        amount = 7500
                    else
                        -- helium
                        tankNum = transposer.fluidsTankMap.helium
                        amount = 10000
                    end
                    print("Adding noble gas for T7")
                    local success = transposer.proxy.transferFluid(transposer.fluidsSide, transposer.inputSide, amount, tankNum-1)
                    if not success then
                        PlantControllers.t7.setWorkAllowed(false)
                        print("failed to transfer noble gas for t7, check your setup!")
                        return false
                    end
                end
            else
                print("Bit 4 was set for T7, skipping all fluid input")
            end
            -- TODO: process bits
            levels = GetFluidLevels()
            solids = GetSolidLevels()
        end
        PlantControllers.t7.setWorkAllowed(false)
    end
    return levels.t7 >= targetLevel
end