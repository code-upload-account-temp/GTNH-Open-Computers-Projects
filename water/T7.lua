function RunT7(targetLevel)
    local levels = GetFluidLevels()
    while levels.t7 < targetLevel do
        if not PlantControllers.t7.isWorkAllowed() then
            PlantControllers.t7.setWorkAllowed(true)
        end
        os.sleep(120)
    end
    PlantControllers.t7.setWorkAllowed(false)
    return levels.t7 >= targetLevel
end