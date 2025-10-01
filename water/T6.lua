local LensSequence = {
    "Orundum Lens",
    "Amber Lens",
    "Aer Lens",
    "Emerald Lens",
    "Mana Diamond Lens",
    "Blue Topaz Lens",
    "Amethyst Lens",
    "Fluor-Buergerite Lens",
    "Dilithium Lens"
}

local Dilithium = "Dilithium Lens"

function RunT6(targetLevel)
    local levels = GetFluidLevels()
    local transposer = InputTransposers.t6
    for i = 1,transposer.proxy.getInventorySize(transposer.lensesSide) do
        local stack = transposer.proxy.getStackInSlot(transposer.lensesSide, i)
        if stack ~= nil then
            transposer.lensSlotMap[stack.name] = i
        end
    end
    while levels.t6 < targetLevel and levels.t5 >= T5_MAINTAIN do
        if not PlantControllers.t6.isWorkAllowed() then
            PlantControllers.t6.setWorkAllowed(true)
        end
        WaitForNextCycle(-1)
        local currentIndex = 0
        local finishedCycle = false
        while not finishedCycle do
            local signal = RedstoneIOs.lens.getInput(LENS_SENSOR_SIDE)
            if signal > 0 then
                -- Need lens change
                print("Removing current lens")
                transposer.proxy.transferItem(transposer.inputSide, transposer.lensesSide, 1, 1, 1)
                currentIndex = currentIndex + 1
                local lensType = LensSequence[currentIndex]
                if lensType == nil then
                    error("somehow requested invalid lens in T6")
                end
                local lensSlot = transposer.lensSlotMap[lensType]
                if lensSlot == nil then
                    if lensType == Dilithium then
                        print("Skipping Dilithium Lens as it is not yet present (need Mothership)")
                        finishedCycle = true
                    else
                        error(string.format("Missing %! Only dilithium is allowed to be skipped in this implementation", lensType))
                    end
                end
                print(string.format("Inserting %s", lensType))
                transposer.proxy.transferItem(transposer.lensesSide, transposer.inputSide, 1, lensSlot, 1)
                if lensType == Dilithium then
                    finishedCycle = true
                end
            end
            os.sleep(2)
        end
    end
    PlantControllers.t6.setWorkAllowed(false)
    return levels.t6 >= targetLevel
end