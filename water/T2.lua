function RunT2(targetLevel)
    local levels = GetFluidLevels()
    while levels.t2 < targetLevel do
        if ~PlantControllers.t2.isWorkAllowed() then
            PlantControllers.t2.setWorkAllowed(true)
        end
        os.sleep(120)
    end
    PlantControllers.t2.setWorkAllowed(false)
end