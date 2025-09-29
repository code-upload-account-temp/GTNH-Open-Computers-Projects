local bufferTimeSeconds = 2

function RunT2(targetLevel)
    local levels = GetFluidLevels()
    local transposer = InputTransposers.t2
    local hatchFillTarget = math.min(T2_INPUT_HATCH_SIZE,1024000)
    while levels.t2 < targetLevel and levels.ozone >= hatchFillTarget do
        if ~PlantControllers.t2.isWorkAllowed() then
            PlantControllers.t2.setWorkAllowed(true)
        end
        WaitForNextCycle(bufferTimeSeconds)
        local fluidInInput = transposer.proxy.getFluidInTank(transposer.inputSide)
        local inputLevel = 0
        if fluidInInput ~= nil then
            inputLevel = fluidInInput.amount
        end

        local success = transposer.proxy.transferFluid(transposer.ozoneSide, transposer.inputSide, hatchFillTarget - inputLevel, transposer.ozoneTankNum)
        if ~success then
            print("Failed to transfer ozone! Please check your setup!")
            PlantControllers.t2.setWorkAllowed(false)
            return false
        end
        -- skip to new cycle before restarting logic
        os.sleep(bufferTimeSeconds * 2)
    end
    PlantControllers.t2.setWorkAllowed(false)
    return levels.t2 >= targetLevel
end