function RunT5(targetLevel)
    local levels = GetFluidLevels()
    while levels.t5 < targetLevel and levels.helium > 2000 and levels.supercoolant > 40000 and levels.t4 >= T4_MAINTAIN do
        if not PlantControllers.t5.isWorkAllowed() then
            PlantControllers.t5.setWorkAllowed(true)
        end
        os.sleep(120)
    end
    PlantControllers.t5.setWorkAllowed(false)
    return levels.t5 >= targetLevel
end