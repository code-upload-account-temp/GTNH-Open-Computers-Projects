local bufferTimeSeconds = 2


function RunT3(targetLevel)
    local levels = GetFluidLevels()
    local transposer = InputTransposers.t3
    local hatchFillTarget = 0
    while hatchFillTarget < 900000 and hatchFillTarget + 100000 < T3_INPUT_HATCH_SIZE do
        hatchFillTarget = hatchFillTarget + 100000
    end
    while levels.t3 < targetLevel and levels.polyAlCl >= hatchFillTarget do
        if not PlantControllers.t3.isWorkAllowed() then
            PlantControllers.t3.setWorkAllowed(true)
        end
        WaitForNextCycle(bufferTimeSeconds)
        local fluidInInput = transposer.proxy.getFluidInTank(transposer.inputSide)
        local inputLevel = 0
        if fluidInInput ~= nil then
            inputLevel = fluidInInput.amount
        end

        local success = transposer.proxy.transferFluid(transposer.polyAlClSide, transposer.inputSide, hatchFillTarget - inputLevel, transposer.polyAlClTankNum)
        if not success then
            print("Failed to transfer poly aluminium chloride! Please check your setup!")
            PlantControllers.t3.setWorkAllowed(false)
            return false
        end
        -- skip to new cycle before restarting logic
        os.sleep(bufferTimeSeconds * 2)
    end
    PlantControllers.t3.setWorkAllowed(false)
    return levels.t3 >= targetLevel
end