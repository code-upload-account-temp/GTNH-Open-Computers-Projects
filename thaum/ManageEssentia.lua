-- Make sure there is exactly one me_controller connected by adapter or this will fail
-- Make sure there is exactly one database in an adapter or this will fail

local component = require("component");
local config = require("Config");

---------- Step 1: Network Setup

-- This will fail if there are too many/too few attached ME networks/compressed chest adapters
local database = component.database
local controller = component.me_controller
local interface = component.me_interface

---------- Step 2: Configure database

-- Wipe existing data
print("Wiping existing database")
for n = 1,81 do 
    database.clear(n)
end

-- Set new data
print("Writing database from config")
for _,item in ipairs(config.DatabaseRaw) do 
    if database.clear(item.slot) then
        error("Attempted to write the same database slot twice! Check config for duplicate slots.")
    end
    database.set(item.slot, item.id, item.meta)
end

---------- Step 3: Build lookups from config

-- convert aspect name strings e.g. "Ignis" to AE essentia names e.g. "gaseousignisessentia" for mapping purposes
local function aspectToGaseous(aspectName) 
    return string.format("gaseous%sessentia",string.lower(aspectName))
end

-- load configuration
local essentiaTargets = {}
for name,amount in pairs(config.AspectTargets) do
    -- Fiddle with formatting so we can use readable names in config
    essentiaTargets[aspectToGaseous(name)] = amount
end

local essentiaSources = {}
for _,item in ipairs(config.DatabaseRaw) do
    for aspect,count in pairs(item.aspects) do
        -- skip if we already have a source for this essentia
        local gaseousName = aspectToGaseous(aspect);
        if essentiaSources[gaseousName] == nil then
            essentiaSources[gaseousName] = {dbSlot=item.slot,count=count}
        end
    end
end

local function getNetworkAspectMap()
    local essentiaData = controller.getEssentiaInNetwork()
    local essentiaMap = {}
    for _, aspect in ipairs(essentiaData) do
        essentiaMap[aspect.name] = aspect
    end
    return essentiaMap
end

---------- Step 4: Endlessly manage Essentia in a loop
print("Beginning essentia management")
while true do 
    print("Checking essentia levels")
    local needAdjustment = true;
    while needAdjustment do
        needAdjustment = false -- Set up to exit if we don't change any essentia levels
        local essentiaData = getNetworkAspectMap()
        for name, target in pairs(essentiaTargets) do 
            local aspect = essentiaData[name]

            if aspect ~= nil and target <= aspect.amount then
                print(string.format("Have enough %s", aspect.label))
            else
                if aspect == nil then
                    print(string.format("%s is completely depleted, ensure valid storage exists", name))
                    aspect = {label=name,amount=0,name=name}
                end
                print(string.format("Need more %s! Have %d of %d", aspect.label, aspect.amount, target))
                -- We have a source for this essentia, it's stored in a DB slot
                needAdjustment = true
                local sourceData = essentiaSources[aspect.name]
                if sourceData == nil then
                    print(string.format("Cannot resupply %s, no configured source!", aspect.label))
                else
                    local sourceSlot = sourceData.dbSlot
                    local source = database.get(sourceSlot)
                    if source == nil then
                        error(string.format("Expected essentia source was not found in database slot %d, this should be impossible unless the database is being modified while the program is running", sourceSlot))
                    end
                    print(string.format("Creating more %s from %s", aspect.label, source.label))
                    -- Set interface to export the essentia source
                    interface.setInterfaceConfiguration(1, database.address, sourceSlot, 1)
                    local amount = aspect.amount;
                    while amount < target do
                        print(string.format("Sleeping for %d seconds while %s is produced (%d of %d)...", config.RetrySleep, name, amount, target))
                        os.sleep(config.RetrySleep)
                        -- Apparently we need to loop through all essentia until we find the one we want, no dedicated search/filter functionality
                        -- This will get easier when we scale up smelting abilities to handle smelting specific amounts in multis, since we can work on all aspects at once
                        essentiaData = getNetworkAspectMap()
                        local updatedAspect = essentiaData[name]
                        if updatedAspect ~= nil then
                            amount = updatedAspect.amount
                        else
                            amount = 0
                        end
                    end
                    -- Clear interface so we stop exporting the essentia source
                    interface.setInterfaceConfiguration(1)
                end
            end
        end
    end
    print(string.format("All aspects stocked, entering sleep for %d seconds...", config.CycleSleep))
    os.sleep(config.CycleSleep)
end