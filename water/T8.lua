function RunT8(targetLevel)
    local levels = GetFluidLevels()
    while levels.t8 < targetLevel do
        if ~PlantControllers.t8.isWorkAllowed() then
            PlantControllers.t8.setWorkAllowed(true)
        end
        os.sleep(120)
    end
    PlantControllers.t8.setWorkAllowed(false)
end