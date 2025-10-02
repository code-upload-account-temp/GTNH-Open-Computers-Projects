require("os")
require("Config");
require("Constants");
require("NetworkDiscovery"); -- discovery logic is here
require("TierControllers");

CYCLE_MAX_TICKS = 20 * 120

-- IMPORTANT: Read the readme, it documents assumptions and setup requirements

-- Turn everything except the main plant off while we work out what we want to run, this won't interrupt existing cycles, just present a new one from starting
if (PlantControllers.t1 ~= nil) then
    PlantControllers.t1.setWorkAllowed(false)
end
if (PlantControllers.t2 ~= nil) then
    PlantControllers.t2.setWorkAllowed(false)
end
if (PlantControllers.t3 ~= nil) then
    PlantControllers.t3.setWorkAllowed(false)
end
if (PlantControllers.t4 ~= nil) then
    PlantControllers.t4.setWorkAllowed(false)
end
if (PlantControllers.t5 ~= nil) then
    PlantControllers.t5.setWorkAllowed(false)
end
if (PlantControllers.t6 ~= nil) then
    PlantControllers.t6.setWorkAllowed(false)
end
if (PlantControllers.t7 ~= nil) then
    PlantControllers.t7.setWorkAllowed(false)
end
if (PlantControllers.t8 ~= nil) then
    PlantControllers.t8.setWorkAllowed(false)
end

function GetRemainingSecondsInCycle()
    local currentTicks = PlantControllers.t0.getWorkProgress()
    local remainingTicks = CYCLE_MAX_TICKS - currentTicks
    return remainingTicks/20
end

function WaitForNextCycle(bufferTimeSeconds)
    -- sends us to bufferTime before the start of the next cycle, enough time to pre-buffer inputs with some room for error on the OS level
    local startWait = GetRemainingSecondsInCycle()
    if startWait > bufferTimeSeconds then
        os.sleep(startWait-bufferTimeSeconds)
    end
end

function GetSolidLevels()
    local levels = {
        filters = 0,
        sodiumHydroxide = 0,
        upQuarks = 0,
        downQuarks = 0,
        topQuarks = 0,
        bottomQuarks = 0,
        strangeQuarks = 0,
        charmQuarks = 0
    }
    local filterStack = AE2.getItemsInNetwork({label="Activated Carbon Filter Mesh"})[1]
    if filterStack ~= nil then
        levels.filters = filterStack.size
    end
    local NaOHStack = AE2.getItemsInNetwork({label="Sodium Hydroxide Dust"})[1]
    if NaOHStack ~= nil then
        levels.sodiumHydroxide = NaOHStack.size
    end
    local quarksList = AE2.getItemsInNetwork({label=QUARK_CATALYST_LABEL_SUFFIX})
    for _, stack in ipairs(quarksList) do
        local metaId = stack.damage - 32235
        if metaId == 0 then
            levels.upQuarks = stack.size
        elseif metaId == 1 then
            levels.downQuarks = stack.size
        elseif metaId == 2 then
            levels.strangeQuarks = stack.size
        elseif metaId == 3 then
            levels.charmQuarks = stack.size
        elseif metaId == 4 then
            levels.bottomQuarks = stack.size
        elseif metaId == 5 then
            levels.topQuarks = stack.size
        end
    end
    return levels
end

function GetFluidLevels()
    local levels = {
        t1=0,t2=0,t3=0,t4=0,t5=0,t6=0,t7=0,t8=0,
        ozone=0,
        polyAlCl=0,
        hydrochloric=0,
        helium=0,
        supercoolant=0,
        heliumGas=0,
        neonGas=0,
        kryptonGas=0,
        xenonGas=0,
        neutronium=0,
        superConductorBase=0,
        infinity=0,
    }
    local fluids = AE2.getFluidsInNetwork()
    for _,fluid in ipairs(fluids) do
        if fluid.name == WATER_T1_NAME then
            levels.t1 = fluid.amount
        end
        if fluid.name == WATER_T2_NAME then
            levels.t2 = fluid.amount
        end
        if fluid.name == WATER_T3_NAME then
            levels.t3 = fluid.amount
        end
        if fluid.name == WATER_T4_NAME then
            levels.t4 = fluid.amount
        end
        if fluid.name == WATER_T5_NAME then
            levels.t5 = fluid.amount
        end
        if fluid.name == WATER_T6_NAME then
            levels.t6 = fluid.amount
        end
        if fluid.name == WATER_T7_NAME then
            levels.t7 = fluid.amount
        end
        if fluid.name == WATER_T8_NAME then
            levels.t8 = fluid.amount
        end
        if fluid.name == "ozone" then
            levels.ozone = fluid.amount
        end
        if fluid.name == "polyaluminiumchloride" then
            levels.polyAlCl = fluid.amount
        end
        if fluid.name == "hydrochloricacid_gt5u" then
            levels.hydrochloric = fluid.amount
        end
        if fluid.name == "plasma.helium" then
            levels.helium = fluid.amount
        end
        if fluid.name == "supercoolant" then
            levels.supercoolant = fluid.amount
        end
        if fluid.name == HELIUM_GAS_NAME then
            levels.heliumGas = fluid.amount
        end
        if fluid.name == NEON_GAS_NAME then
            levels.neonGas = fluid.amount
        end
        if fluid.name == KRYPTON_GAS_NAME then
            levels.kryptonGas = fluid.amount
        end
        if fluid.name == XENON_GAS_NAME then
            levels.xenonGas = fluid.amount
        end
        if fluid.name == MOLTEN_NEUTRONIUM_NAME then
            levels.neutronium = fluid.amount
        end
        if fluid.name == MOLTEN_INFINITY_NAME then
            levels.infinity = fluid.amount
        end
        if fluid.name == SUPERCONDUCTOR_BASE_LABEL_PREFIX .. T7_SUPERCONDUCTOR_BASE_TIER then
            levels.superConductorBase = fluid.amount
        end
    end
    return levels
end

-- Recursively increases the amount needed of earlier water levels based on higher tier demands, so we batch correctly
local function calculateMissingSingleTier(tierExists, nextTierNeeded, level, target, minBatch, successChance) 
    if not tierExists then
        -- We don't have this tier installed, ignore config and demand nothing
        return 0, 0
    end
    local missing = 0
    if nextTierNeeded > level then
        if level >= target then
            missing = nextTierNeeded + target - level
        else 
            missing = nextTierNeeded - level
        end
    end
    if level < target then
        missing = missing + target - level
        if (missing < minBatch) then
            missing = minBatch
        end
    end
    if (missing > 0 and missing < minBatch) then
        missing = minBatch
    end
    local inputNeeded = missing / (0.9 * successChance)
    return missing, inputNeeded
end

local function calculateMissing()
    local levels = GetFluidLevels()
    local t8Missing, t7Needed = calculateMissingSingleTier(PlantControllers.t8 ~= nil, 0,        levels.t8, T8_MAINTAIN, T8_MIN_BATCH, SUCCESS_CHANCE_GUESS_T8)
    local t7Missing, t6Needed = calculateMissingSingleTier(PlantControllers.t7 ~= nil, t7Needed, levels.t7, T7_MAINTAIN, T7_MIN_BATCH, SUCCESS_CHANCE_GUESS_T7)
    local t6Missing, t5Needed = calculateMissingSingleTier(PlantControllers.t6 ~= nil, t6Needed, levels.t6, T6_MAINTAIN, T6_MIN_BATCH, SUCCESS_CHANCE_GUESS_T6)
    local t5Missing, t4Needed = calculateMissingSingleTier(PlantControllers.t5 ~= nil, t5Needed, levels.t5, T5_MAINTAIN, T5_MIN_BATCH, SUCCESS_CHANCE_GUESS_T5)
    local t4Missing, t3Needed = calculateMissingSingleTier(PlantControllers.t4 ~= nil, t4Needed, levels.t4, T4_MAINTAIN, T4_MIN_BATCH, SUCCESS_CHANCE_GUESS_T4)
    local t3Missing, t2Needed = calculateMissingSingleTier(PlantControllers.t3 ~= nil, t3Needed, levels.t3, T3_MAINTAIN, T3_MIN_BATCH, SUCCESS_CHANCE_GUESS_T3)
    local t2Missing, t1Needed = calculateMissingSingleTier(PlantControllers.t2 ~= nil, t2Needed, levels.t2, T2_MAINTAIN, T2_MIN_BATCH, SUCCESS_CHANCE_GUESS_T2)
    local t1Missing, _ =        calculateMissingSingleTier(PlantControllers.t1 ~= nil, t1Needed, levels.t1, T1_MAINTAIN, 0,            SUCCESS_CHANCE_GUESS_T1)
    local missing = {
        t1=t1Missing,
        t2=t2Missing,
        t3=t3Missing,
        t4=t4Missing,
        t5=t5Missing,
        t6=t6Missing,
        t7=t7Missing,
        t8=t8Missing,
    }
    return missing
end

while true do
    local levels = GetFluidLevels()
    local missing = calculateMissing()
    if missing.t1 > 0 then
        print(string.format("Running T1 to generate %gL", missing.t1))
        if not RunT1(levels.t1 + missing.t1) then
            print("Failed to generate full amount of T1")
        end
    elseif missing.t2 > 0 then
        print(string.format("Running T2 to generate %gL", missing.t2))
        if not RunT2(levels.t2 + missing.t2) then
            print("Failed to generate full amount of T2")
        end
    elseif missing.t3 > 0 then
        print(string.format("Running T3 to generate %gL", missing.t3))
        if not RunT3(levels.t3 + missing.t3) then
            print("Failed to generate full amount of T3")
        end
    elseif missing.t4 > 0 then
        print(string.format("Running T4 to generate %gL", missing.t4))
        if not RunT4(levels.t4 + missing.t4) then
            print("Failed to generate full amount of T4")
        end
    elseif missing.t5 > 0 then
        print(string.format("Running T5 to generate %gL", missing.t5))
        if not RunT5(levels.t5 + missing.t5) then
            print("Failed to generate full amount of T5")
        end
    elseif missing.t6 > 0 then
        print(string.format("Running T6 to generate %gL", missing.t6))
        if not RunT6(levels.t6 + missing.t6) then
            print("Failed to generate full amount of T6")
        end
    elseif missing.t7 > 0 then
        print(string.format("Running T7 to generate %gL", missing.t7))
        if not RunT7(levels.t7 + missing.t7) then
            print("Failed to generate full amount of T7")
        end
    elseif missing.t8 > 0 then
        print(string.format("Running T8 to generate %gL", missing.t8))
        if not RunT8(levels.t8 + missing.t8) then
            print("Failed to generate full amount of T8")
        end
    end
    os.sleep(10) -- TODO: proper cycle logic, this is just preventing unbreakable loop for now
end