function RunT6(targetLevel)
    local levels = GetFluidLevels()
    while levels.t6 < targetLevel do
        if !PlantControllers.t6.isWorkAllowed() then
            PlantControllers.t6.setWorkAllowed(true)
        end
        os.sleep(120)
    end
    PlantControllers.t6.setWorkAllowed(false)
    return levels.t6 >= targetLevel
end