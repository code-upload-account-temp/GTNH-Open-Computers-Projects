local component = require("component");

local MULTI_T0_NAME = "multimachine.purificationplant"
local MULTI_T1_NAME = "multimachine.purificationunitclarifier"
local MULTI_T2_NAME = "multimachine.purificationunitozonation"
local MULTI_T3_NAME = "multimachine.purificationunitflocculation"
local MULTI_T4_NAME = "multimachine.purificationunitphadjustment"
local MULTI_T5_NAME = "multimachine.purificationunitplasmaheater"
local MULTI_T6_NAME = "multimachine.purificationunituvtreatment"
local MULTI_T7_NAME = "multimachine.purificationunitdegasifier"
local MULTI_T8_NAME = "multimachine.purificationunitextractor"

-- Config

-- End Config

-- System Discovery

local plantControllers = {}
local inputTransposers = {}

local machines = component.list("gt_machine")

local transposers = component.list("transposer")

for addr, v in pairs(machines) do
    local machine = component.proxy(addr, "gt_machine")
    local name = machine.getName()
    if name == MULTI_T0_NAME then
        plantControllers.t0 = addr
    elseif name == MULTI_T1_NAME then
        plantControllers.t1 = addr
    elseif name == MULTI_T2_NAME then
        plantControllers.t2 = addr
    elseif name == MULTI_T3_NAME then
        plantControllers.t3 = addr
    elseif name == MULTI_T4_NAME then
        plantControllers.t4 = addr
    elseif name == MULTI_T5_NAME then
        plantControllers.t5 = addr
    elseif name == MULTI_T6_NAME then
        plantControllers.t6 = addr
    elseif name == MULTI_T7_NAME then
        plantControllers.t7 = addr
    elseif name == MULTI_T8_NAME then
        plantControllers.t8 = addr
    end
end

for addr, v in pairs(transposers) do
    local transposer = component.proxy(addr, "transposer")
    local fluids = {
        ozone={present=false,side=nil,tank=nil},
        polyAlCl={present=false,side=nil,tank=nil},
        hydrochloric={present=false,side=nil,tank=nil},
        heliumPlasma={present=false,side=nil,tank=nil},
        inputHatch={present=false,side=nil}
    }
    -- TODO: T7 and T8 fluid registry
    local solids = {
        filters={present=false,side=nil},
        sodiumHydroxide={present=false,side=nil},
        lenses={present=false,side=nil}
    }
    -- TODO: T7 and T8 solid inputs

    -- Scan all sides of all transposers to identify where needed inputs are
    for sideNum in 0, 5 do
        local tankCount = transposer.getTankCount(sideNum)
        for tankNum in 1,tankCount do
                local contents = transposer.getFluidInTank(sideNum, tankNum)
            if contents.name == "ozone" then
                fluids.ozone.present = true
                fluids.ozone.side = sideNum
                fluids.ozone.tank = tankNum
            elseif contents.name == "polyaluminiumchloride" then
                fluids.polyAlCl.present = true
                fluids.polyAlCl.side = sideNum
                fluids.polyAlCl.tank = tankNum
            elseif contents.name == "hydrochloricacid_gt5u" then
                fluids.hydrochloric.present = true
                fluids.hydrochloric.side = sideNum
                fluids.hydrochloric.tank = tankNum
            elseif contents.name == "plasma.helium" then
                fluids.heliumPlasma.present = true
                fluids.heliumPlasma.side = sideNum
                fluids.heliumPlasma.tank = tankNum
            elseif contents.amount ~= nil & (contents.name == nil | string.find(contents.name, "purifiedwater") ~= nil) then
                fluids.inputHatch.present = true
                fluids.inputHatch.side = sideNum
            end
        end
        local inventorySize = transposer.getInventorySize(sideNum)
        if inventorySize ~= nil & inventorySize > 0 then
            for slotNum in 1,inventorySize do
                local stack = transposer.getStackInSlot(sideNum, slotNum)
                if stack.label == "Activated Carbon Filter Mesh" then
                    solids.filters.present = true
                    solids.filters.side = sideNum
                elseif stack.label == "Sodium Hydroxide Dust" then
                    solids.sodiumHydroxide.present = true
                    solids.sodiumHydroxide.side = sideNum
                elseif stack.label == "Orundum Lens" then
                    solids.lenses.present = true
                    solids.lenses.side = sideNum
                end
            end
        end
    end
end

-- End System Discovery

-- Tier 1


-- End Tier 1

-- Tier 2



-- End Tier 2



-- Tier 3


-- End Tier 3
