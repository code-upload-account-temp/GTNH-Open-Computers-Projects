function RunT3(targetLevel)
    local levels = GetFluidLevels()
    while levels.t3 < targetLevel do
        if ~PlantControllers.t3.isWorkAllowed() then
            PlantControllers.t3.setWorkAllowed(true)
        end
        os.sleep(120)
    end
    PlantControllers.t3.setWorkAllowed(false)
    return levels.t3 >= targetLevel
end