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
    local solids = GetSolidLevels()
    local transposer = InputTransposers.t8
    local slots = transposer.quarksSlotMap
    -- 123456 135264 152436 (copied a minimal sequence from the wiki)
    local sequence = {
        slots.up, slots.down, slots.top, slots.bottom, slots.strange, slots.charm,
        slots.up, slots.top, slots.strange, slots.down, slots.charm, slots.bottom,
        slots.up, slots.strange, slots.down, slots.bottom, slots.top, slots.charm,
    }
    while levels.t8 < targetLevel and solids.upQuarks > 6 and solids.downQuarks > 6 and solids.topQuarks > 6 and solids.bottomQuarks > 6 and solids.strangeQuarks > 6 and solids.charmQuarks > 6 and levels.infinity >= 10368 and levels.t7 > T7_MAINTAIN do
        WaitForNextCycle(2)
        if not PlantControllers.t8.isWorkAllowed() then
            PlantControllers.t8.setWorkAllowed(true)
        end
        WaitForNextCycle(-1)
        local index = 1
        while not hasSucceeded() and index <= 18 do
            transposer.proxy.transferItem(transposer.quarksSide, transposer.inputSide, 1, sequence[index], 1)
            index = index + 1
            os.sleep(2)
        end
        if not hasSucceeded() then
            -- We somehow tried literally every combination but failed, this *shouldn't* happen unless we're not actually succeeding at moving quark catalysts around
            PlantControllers.t8.setWorkAllowed(false)
            print("Full sequence completed without success in T8! This shouldn't be possible unless the setup is broken")
        end
        levels = GetFluidLevels()
        solids = GetSolidLevels()
    end
    print(string.format("Ending T8 run at input levels:\nT8 Water: %i, Up Quarks: %i, Down Quarks: %i, Top Quarks: %i, Bottom Quarks: %i, Strange Quarks: %i, Charm Quarks: %i, T7 Water: %i", levels.t8, solids.upQuarks, solids.downQuarks, solids.topQuarks, solids.bottomQuarks, solids.strangeQuarks, solids.charmQuarks, levels.t7))
    PlantControllers.t8.setWorkAllowed(false)
    return levels.t8 >= targetLevel
end