require("Config");
require("Constants");
require("NetworkDiscovery") -- discovery logic is here

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

local function getRemainingSecondsInCycle()
    local currentTicks = PlantControllers.t0.getWorkProgress()
    local remainingTicks = CYCLE_MAX_TICKS - currentTicks
    return remainingTicks/20
end

function GetFluidLevels()
    local levels = {
        t1=0,t2=0,t3=0,t4=0,t5=0,t6=0,t7=0,t8=0,
        ozone=0,
        polyAlCl=0,
        hydrochloric=0,
        helium=0,
        supercoolant=0
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
    end
end