function RunT1(targetLevel)
    local meshStorage = AE2.getItemsInNetwork({label="Activated Carbon Filter Mesh"})[1]
    local levels = GetFluidLevels()
    local solids = GetSolidLevels()
    while levels.t1 < targetLevel and solids.filters > 0 do
        if not PlantControllers.t1.isWorkAllowed() then
            PlantControllers.t1.setWorkAllowed(true)
        end
        os.sleep(120)
        meshStorage = AE2.getItemsInNetwork({label="Activated Carbon Filter Mesh"})[1]
        levels = GetFluidLevels()
        solids = GetSolidLevels()
    end
    PlantControllers.t1.setWorkAllowed(false)
    return levels.t1 >= targetLevel
end