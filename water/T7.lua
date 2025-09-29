function RunT7(targetLevel)
    local levels = GetFluidLevels()
    while levels.t7 < targetLevel do
        if ~PlantControllers.t7.isWorkAllowed() then
            PlantControllers.t7.setWorkAllowed(true)
        end
        os.sleep(120)
    end
    PlantControllers.t7.setWorkAllowed(false)
end