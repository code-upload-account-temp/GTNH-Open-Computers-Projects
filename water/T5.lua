function RunT5(targetLevel)
    local levels = GetFluidLevels()
    while levels.t5 < targetLevel do
        if !PlantControllers.t5.isWorkAllowed() then
            PlantControllers.t5.setWorkAllowed(true)
        end
        os.sleep(120)
    end
    PlantControllers.t5.setWorkAllowed(false)
    return levels.t5 >= targetLevel
end