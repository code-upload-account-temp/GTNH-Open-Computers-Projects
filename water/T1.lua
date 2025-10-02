function RunT1(targetLevel)
    local levels = GetFluidLevels()
    local solids = GetSolidLevels()
    while levels.t1 < targetLevel and solids.filters > 0 do
        if not PlantControllers.t1.isWorkAllowed() then
            PlantControllers.t1.setWorkAllowed(true)
        end
        os.sleep(120)
        levels = GetFluidLevels()
        solids = GetSolidLevels()
    end
    PlantControllers.t1.setWorkAllowed(false)
    return levels.t1 >= targetLevel
end