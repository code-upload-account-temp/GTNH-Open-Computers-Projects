function RunT1(targetLevel)
    local meshStorage = AE2.getItemsInNetwork({label="Activated Carbon Filter Mesh"})[1]
    local levels = GetFluidLevels()
    while levels.t1 < targetLevel and meshStorage ~= nil and meshStorage.size > 0 do
        os.sleep(120)
    end
end