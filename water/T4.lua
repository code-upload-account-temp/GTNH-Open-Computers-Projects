function RunT4(targetLevel)
    local levels = GetFluidLevels()
    while levels.t4 < targetLevel do
        if ~PlantControllers.t4.isWorkAllowed() then
            PlantControllers.t4.setWorkAllowed(true)
        end
        os.sleep(120)
    end
    PlantControllers.t4.setWorkAllowed(false)
end