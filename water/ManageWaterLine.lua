local component = require("component");
require("Config");
require("Constants");
require("Utility")

-- IMPORTANT: Read the readme, it documents assumptions and setup requirements

local ae2 = component.me_controller

if ae2 == nil then
    error("No AE2 controller detected, this code cannot run without AE2 integration!")
end

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
        sodiumHydroxideSide=nil,
        sodiumHydroxideSlot=nil,
        hydrochloricSide=nil,
        hydrochloricTankNum=nil,
        inputSide=nil,
    },
    t5={
        proxy=nil,
        heliumPlasmaSide=nil,
        heliumPlasmaTankNum=nil,
        superCoolantSide=nil,
        superCoolantTankNum=nil,
        inputSide=nil,
    },
    t6={
        proxy=nil,
        lensesSide=nil,
        lensSlotMap={}, -- TODO: fill out lens types
        inputSide=nil,
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

print("Beginning network discovery...")

for addr, v in pairs(transposers) do
    -- Get relevant transposer to run queries on
    local transposer = component.proxy(addr, "transposer")
    -- Prepare storage for network discovery findings
    local fluids = {
        ozone={present=false,side=nil,tank=nil},
        polyAlCl={present=false,side=nil,tank=nil},
        hydrochloric={present=false,side=nil,tank=nil},
        heliumPlasma={present=false,side=nil,tank=nil},
        superCoolant={present=false,side=nil,tank=nil},
        inputHatch={present=false,side=nil}
    }
    -- TODO: T7 and T8 fluid registry
    local solids = {
        sodiumHydroxide={present=false,side=nil,slot=nil},
        lenses={present=false,side=nil,slot=nil},
        inputBus={present=false,side=nil,slot=nil}
    }
    -- TODO: T7 and T8 solid inputs

    -- Scan all sides of this transposers to identify where needed inputs are
    for sideNum=0,5 do
        local tankCount = transposer.getTankCount(sideNum)
        if tankCount == 4 or tankCount == 7 or (tankCount == 1 and (transposer.getTankCapacity(sideNum,1) == T2_INPUT_HATCH_SIZE or transposer.getTankCapacity(sideNum,1) == T3_INPUT_HATCH_SIZE)) then
            fluids.inputHatch.present = true
            fluids.inputHatch.side = sideNum
        else
            for tankNum=1,tankCount do
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
                elseif contents.name == "supercoolant" then
                    fluids.superCoolant.present = true
                    fluids.superCoolant.side = sideNum
                    fluids.superCoolant.tank = tankNum
                end
            end
        end
        local inventorySize = transposer.getInventorySize(sideNum)
        if inventorySize ~= nil and inventorySize > 0 then
            local invName = transposer.getInventoryName(sideNum)
            -- Ignore all inventories that are not ingredient buffers or interfaces or dual interfaces
            if invName == ME_INGREDIENT_BUFFER_NAME then
                -- ingredient buffer is always an output
                solids.inputBus.present = true
                solids.inputBus.side = sideNum
            elseif invName == ME_INTERFACE_NAME or invName == ME_DUAL_INTERFACE_NAME then
                for slotNum=1,inventorySize do
                    local stack = transposer.getStackInSlot(sideNum, slotNum)
                    if stack ~= nil then
                        local label = stack.label
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
    end
    -- Now that we have the sides of this transposer discovered, look for a configuration which matches one of the water plants

    print("Dumping data of transposer ", addr)
    print("fluids", TableToString(fluids))
    print("solids", TableToString(solids))

    -- T2
    if fluids.ozone.present and fluids.inputHatch.present then
        print("T2 discovered at ", addr)
        inputTransposers.t2 = {
            proxy=transposer,
            ozoneSide=fluids.ozone.side,
            ozoneTankNum=fluids.ozone.tank,
            inputSide=fluids.inputHatch.side
        }
    end

    -- T3
    if fluids.polyAlCl.present and fluids.inputHatch.present then
        print("T3 discovered at ", addr)
        inputTransposers.t3 = {
            proxy=transposer,
            polyAlClSide=fluids.polyAlCl.side,
            polyAlClTankNum=fluids.polyAlCl.tank,
            inputSide=fluids.inputHatch.side
        }
    end

    -- T4
    if fluids.hydrochloric.present and solids.sodiumHydroxide.present and solids.inputBus.present and fluids.inputHatch.present and solids.inputBus.side == fluids.inputHatch.side then
        print("T4 discovered at ", addr)
        inputTransposers.t4 = {
            proxy=transposer,
            sodiumHydroxideSide=solids.sodiumHydroxide.side,
            sodiumHydroxideSlot=solids.sodiumHydroxide.slot,
            hydrochloricSide=fluids.hydrochloric.side,
            hydrochloricTankNum=fluids.hydrochloric.tank,
            inputSide=solids.inputBus.side,
        }
    end
    
    -- T5
    if fluids.heliumPlasma.present and fluids.superCoolant.present and fluids.inputHatch.present then
        print("T5 discovered at ", addr)
        inputTransposers.t5={
            proxy=transposer,
            heliumPlasmaSide=fluids.heliumPlasma.side,
            heliumPlasmaTankNum=fluids.heliumPlasma.tank,
            superCoolantSide=fluids.superCoolant.side,
            superCoolantTankNum=fluids.superCoolant.tank,
            inputSide=fluids.inputHatch.side
        }
    end

    -- T6

    if solids.lenses.present and solids.inputBus.present then
        print("T6 discovered at ", addr)
        inputTransposers.t6={
            proxy=transposer,
            lensesSide=solids.lenses.side,
            lensSlotMap={}, -- TODO: fill out lens types
            inputSide=solids.inputBus.side
        }
    end
end

print("Network discovery complete!")

-- Check sanity of controllers vs. transposers

if plantControllers.t2 ~= nil and inputTransposers.t2.proxy == nil then
    error("T2 controller present but no transposer found!")
end
if plantControllers.t3 ~= nil and inputTransposers.t3.proxy == nil then
    error("T3 controller present but no transposer found!")
end
if plantControllers.t4 ~= nil and inputTransposers.t4.proxy == nil then
    error("T4 controller present but no transposer found!")
end
if plantControllers.t5 ~= nil and inputTransposers.t5.proxy == nil then
    error("T5 controller present but no transposer found!")
end
if plantControllers.t6 ~= nil and inputTransposers.t6.proxy == nil then
    error("T6 controller present but no transposer found!")
end

-- End System Discovery

-- Tier 1


-- End Tier 1

-- Tier 2



-- End Tier 2



-- Tier 3


-- End Tier 3
