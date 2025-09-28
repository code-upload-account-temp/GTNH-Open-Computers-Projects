local component = require("component");

-- IMPORTANT ASSUMPTIONS

-- 1. Adapter + MFU to every controller in the line
-- 2. EXACTLY one transposer per purification unit, connected to non-ME input hatch/bus for most, connected to an ingredient buffer for T4/T5
-- 3. Machines with both fluid and solid inputs have all fluids in type-locked tanks, all solids present
-- 4. All item buffers are ME interfaces
-- 5. All fluid buffers have size specified in config
-- 6. All fluids other than transposer buffers (transposer buffers should be exported, not storage bused) stored in AE network with Adapter + MFU controller connection

-- I would have used dual interfaces for ALL fluid buffers instead of just some, but that would have severely limited throughput on ozone

-- Definitions - TODO: Move into an import once this is stable

local MULTI_T0_NAME = "multimachine.purificationplant"
local MULTI_T1_NAME = "multimachine.purificationunitclarifier"
local MULTI_T2_NAME = "multimachine.purificationunitozonation"
local MULTI_T3_NAME = "multimachine.purificationunitflocculation"
local MULTI_T4_NAME = "multimachine.purificationunitphadjustment"
local MULTI_T5_NAME = "multimachine.purificationunitplasmaheater"
local MULTI_T6_NAME = "multimachine.purificationunituvtreatment"
local MULTI_T7_NAME = "multimachine.purificationunitdegasifier"
local MULTI_T8_NAME = "multimachine.purificationunitextractor"
local ME_INTERFACE_NAME = "tile.appliedenergistics2.BlockInterface"
local ME_DUAL_INTERFACE_NAME = "tile.fluid_interface"
local ME_INGREDIENT_BUFFER_NAME = "tile.ingredient_buffer"

-- End Definitions

-- Config

local T2_INPUT_HATCH_SIZE = 1024000
local T2_BUFFER_TANK_SIZE = 4000000
local T3_INPUT_HATCH_SIZE = 1024000
local T3_BUFFER_TANK_SIZE = 4000000
local T4_INPUT_HATCH_SIZE = 8000
local T3_BUFFER_TANK_SIZE = 32000
local T5_INPUT_HATCH_SIZE = 8000
local T5_BUFFER_TANK_SIZE = 32000

-- End Config

-- System Discovery

local plantControllers = {t0=nil,t1=nil,t2=nil,t3=nil,t4=nil,t5=nil,t6=nil,t7=nil,t8=nil}
local inputTransposers = {
    t2={
        proxy=nil,
        ozoneSide=nil,
        ozoneTankNum=nil,
        inputSide=nil
    },
    t3={
        proxy=nil,
        polyAlClSide=nil,
        polyAlClTankNum=nil,
        inputSide=nil
    },
    t4={
        proxy=nil,

    }
}

local machines = component.list("gt_machine")

local transposers = component.list("transposer")

for addr, v in pairs(machines) do
    local machine = component.proxy(addr, "gt_machine")
    local name = machine.getName()
    if name == MULTI_T0_NAME then
        plantControllers.t0 = machine
    elseif name == MULTI_T1_NAME then
        plantControllers.t1 = machine
    elseif name == MULTI_T2_NAME then
        plantControllers.t2 = machine
    elseif name == MULTI_T3_NAME then
        plantControllers.t3 = machine
    elseif name == MULTI_T4_NAME then
        plantControllers.t4 = machine
    elseif name == MULTI_T5_NAME then
        plantControllers.t5 = machine
    elseif name == MULTI_T6_NAME then
        plantControllers.t6 = machine
    elseif name == MULTI_T7_NAME then
        plantControllers.t7 = machine
    elseif name == MULTI_T8_NAME then
        plantControllers.t8 = machine
    end
end

for addr, v in pairs(transposers) do
    -- Get relevant transposer to run queries on
    local transposer = component.proxy(addr, "transposer")
    -- Prepare storage for network discovery findings
    local fluids = {
        ozone={present=false,side=nil,tank=nil},
        polyAlCl={present=false,side=nil,tank=nil},
        hydrochloric={present=false,side=nil,tank=nil},
        heliumPlasma={present=false,side=nil,tank=nil},
        inputHatch={present=false,side=nil}
    }
    -- TODO: T7 and T8 fluid registry
    local solids = {
        sodiumHydroxide={present=false,side=nil,slot=nil},
        lenses={present=false,side=nil,slot=nil},
        inputBus={present=false,side=nil,slot=nil}
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
            elseif tankCount == 6 | tankCount == 1 then
                -- assume input hatch for now, we can error later if it's the wrong size
                -- This will cause problems if unrelated tanks are placed next to the transposers!
                fluids.inputHatch.present = true
                fluids.inputHatch.side = sideNum
            end
        end
        local inventorySize = transposer.getInventorySize(sideNum)
        if inventorySize ~= nil & inventorySize > 0 then
            local invName = transposer.getInventoryName(sideNum)
            -- Ignore all inventories that are not ingredient buffers or interfaces or dual interfaces
            if invName == ME_INGREDIENT_BUFFER_NAME then
                -- ingredient buffer is always an output
                solids.inputBus.present = true
                solids.inputBus.side = sideNum
            elseif invName == ME_INTERFACE_NAME | invName == ME_DUAL_INTERFACE_NAME then
                for slotNum in 1,inventorySize do
                    local stack = transposer.getStackInSlot(sideNum, slotNum)
                    if stack.label == "Activated Carbon Filter Mesh" then
                        solids.filters.present = true
                        solids.filters.side = sideNum
                        solids.filters.slot = slotNum
                    elseif stack.label == "Sodium Hydroxide Dust" then
                        solids.sodiumHydroxide.present = true
                        solids.sodiumHydroxide.side = sideNum
                        solids.sodiumHydroxide.slot = slotNum
                    elseif stack.label == "Orundum Lens" then -- TODO: the rest of the lenses
                        solids.lenses.present = true
                        solids.lenses.side = sideNum
                        solids.lenses.slot = slotNum
                    end
                end
            end
        end
    end
    -- Now that we have the network discovered, look for a configuration which matches one of the water plants

    -- T2
    if fluids.ozone.present & fluids.inputHatch.present then
        inputTransposers.t2.proxy = transposer
        inputTransposers.t2.inputSide = fluids.inputHatch.side
        inputTransposers.t2.ozoneSide = fluids.ozone.side
        inputTransposers.t2.ozoneTankNum = fluids.ozone.tank
    end
    
end

-- End System Discovery

-- Tier 1


-- End Tier 1

-- Tier 2



-- End Tier 2



-- Tier 3


-- End Tier 3
