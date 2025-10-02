local component = require("component");
AE2 = component.me_controller

if AE2 == nil then
    error("No AE2 controller detected, this code cannot run without AE2 integration!")
end

PlantControllers = { t0 = nil, t1 = nil, t2 = nil, t3 = nil, t4 = nil, t5 = nil, t6 = nil, t7 = nil, t8 = nil }
InputTransposers = {
    t2 = {
        proxy = nil,
        ozoneSide = nil,
        ozoneTankNum = nil,
        inputSide = nil
    },
    t3 = {
        proxy = nil,
        polyAlClSide = nil,
        polyAlClTankNum = nil,
        inputSide = nil
    },
    t4 = {
        proxy = nil,
        sodiumHydroxideSide = nil,
        sodiumHydroxideSlot = nil,
        hydrochloricSide = nil,
        hydrochloricTankNum = nil,
        inputSide = nil,
    },
    t5 = {
        proxy = nil,
        heliumPlasmaSide = nil,
        heliumPlasmaTankNum = nil,
        superCoolantSide = nil,
        superCoolantTankNum = nil,
        inputSide = nil,
    },
    t6 = {
        proxy = nil,
        lensesSide = nil,
        --- @type table<string, number>
        lensSlotMap = {}, 
        inputSide = nil,
    },
    t7 = {
        proxy = nil,
        fluidsSide = nil,
        --- @type table<string, number>
        fluidsTankMap = {
            superCoolant = 1,
            helium = 2,
            neon = 3,
            krypton = 4,
            xenon = 5,
            neutronium = 6
        },
        superConductorSide = nil,
        superConductorTankNum = nil,
        inputSide = nil,
    },
    t8 = {
        proxy = nil,
        quarksSide = nil,
        --- @type table<string, number>
        quarksSlotMap = {
            up = 1,
            down = 2,
            top = 3,
            bottom = 4,
            strange = 5,
            charm = 6
        },
        inputSide = nil
    }
}
RedstoneIOs = {
    lens=component.redstone -- since we only use redstone for T6, we can just assume that the only redstone IO is for the lens
}

local machines = component.list("gt_machine")

local transposers = component.list("transposer")

for addr, v in pairs(machines) do
    local machine = component.proxy(addr, "gt_machine")
    local name = machine.getName()
    if name == MULTI_T0_NAME then
        PlantControllers.t0 = machine
    elseif name == MULTI_T1_NAME then
        PlantControllers.t1 = machine
    elseif name == MULTI_T2_NAME then
        PlantControllers.t2 = machine
    elseif name == MULTI_T3_NAME then
        PlantControllers.t3 = machine
    elseif name == MULTI_T4_NAME then
        PlantControllers.t4 = machine
    elseif name == MULTI_T5_NAME then
        PlantControllers.t5 = machine
    elseif name == MULTI_T6_NAME then
        PlantControllers.t6 = machine
    elseif name == MULTI_T7_NAME then
        PlantControllers.t7 = machine
    elseif name == MULTI_T8_NAME then
        PlantControllers.t8 = machine
    end
end

print("Beginning network discovery...")

for addr, v in pairs(transposers) do
    -- Get relevant transposer to run queries on
    local transposer = component.proxy(addr, "transposer")
    -- Prepare storage for network discovery findings
    local superconductorFluidName = SUPERCONDUCTOR_BASE_LABEL_PREFIX .. T7_SUPERCONDUCTOR_BASE_TIER
    local fluids = {
        ozone = { present = false, side = nil, tank = nil },
        polyAlCl = { present = false, side = nil, tank = nil },
        hydrochloric = { present = false, side = nil, tank = nil },
        heliumPlasma = { present = false, side = nil, tank = nil },
        superCoolant = { present = false, side = nil, tank = nil },
        heliumGas = { present = false, side = nil, tank = nil },
        neonGas = { present = false, side = nil, tank = nil },
        kryptonGas = { present = false, side = nil, tank = nil },
        xenonGas = { present = false, side = nil, tank = nil },
        neutronium = { present = false, side = nil, tank = nil },
        superConductor = { present = false, side = nil, tank = nil },
        inputHatch = { present = false, side = nil }
    }
    -- TODO: T7 and T8 fluid registry
    local solids = {
        sodiumHydroxide = { present = false, side = nil, slot = nil },
        lenses = { present = false, side = nil },
        quarks = { present = false, side = nil },
        inputBus = { present = false, side = nil, slot = nil }
    }
    -- TODO: T7 and T8 solid inputs

    -- Scan all sides of this transposers to identify where needed inputs are
    for sideNum = 0, 5 do
        local tankCount = transposer.getTankCount(sideNum)
        if tankCount == 4 or tankCount == 7 or (tankCount == 1 and (transposer.getTankCapacity(sideNum, 1) == T2_INPUT_HATCH_SIZE or transposer.getTankCapacity(sideNum, 1) == T3_INPUT_HATCH_SIZE)) then
            fluids.inputHatch.present = true
            fluids.inputHatch.side = sideNum
        else
            for tankNum = 1, tankCount do
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
                elseif contents.name == HELIUM_GAS_NAME then
                    fluids.heliumGas.present = true
                    fluids.heliumGas.side = sideNum
                    fluids.heliumGas.tank = tankNum
                elseif contents.name == NEON_GAS_NAME then
                    fluids.neonGas.present = true
                    fluids.neonGas.side = sideNum
                    fluids.neonGas.tank = tankNum
                elseif contents.name == KRYPTON_GAS_NAME then
                    fluids.kryptonGas.present = true
                    fluids.kryptonGas.side = sideNum
                    fluids.kryptonGas.tank = tankNum
                elseif contents.name == XENON_GAS_NAME then
                    fluids.xenonGas.present = true
                    fluids.xenonGas.side = sideNum
                    fluids.xenonGas.tank = tankNum
                elseif contents.name == MOLTEN_NEUTRONIUM_NAME then
                    fluids.neutronium.present = true
                    fluids.neutronium.side = sideNum
                    fluids.neutronium.tank = tankNum
                elseif contents.label == superconductorFluidName then
                    fluids.superConductor.present = true
                    fluids.superConductor.side = sideNum
                    fluids.superConductor.tank = tankNum
                end
            end
        end
        local inventorySize = transposer.getInventorySize(sideNum)
        if inventorySize ~= nil and inventorySize > 0 then
            local invName = transposer.getInventoryName(sideNum)
            -- Ignore all inventories that are not ingredient buffers or interfaces or dual interfaces
            if invName == ME_INGREDIENT_BUFFER_NAME or inventorySize == 1 then
                -- ingredient buffer is always a machine input
                -- single-slot inventory (e.g. lens housing) is also input
                solids.inputBus.present = true
                solids.inputBus.side = sideNum
            elseif invName == ME_INTERFACE_NAME or invName == ME_DUAL_INTERFACE_NAME then
                for slotNum = 1, inventorySize do
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
                        elseif stack.label == "Orundum Lens" then
                            solids.lenses.present = true
                            solids.lenses.side = sideNum
                        elseif string.find(stack.label, QUARK_CATALYST_LABEL_SUFFIX) ~= nil then
                            solids.quarks.present = true
                            solids.quarks.side = sideNum
                        end
                    end
                end
            end
        end
    end

    -- T2
    if fluids.ozone.present and fluids.inputHatch.present then
        print("T2 discovered at ", addr)
        InputTransposers.t2 = {
            proxy = transposer,
            ozoneSide = fluids.ozone.side,
            ozoneTankNum = fluids.ozone.tank,
            inputSide = fluids.inputHatch.side
        }
    end

    -- T3
    if fluids.polyAlCl.present and fluids.inputHatch.present then
        print("T3 discovered at ", addr)
        InputTransposers.t3 = {
            proxy = transposer,
            polyAlClSide = fluids.polyAlCl.side,
            polyAlClTankNum = fluids.polyAlCl.tank,
            inputSide = fluids.inputHatch.side
        }
    end

    -- T4
    if fluids.hydrochloric.present and solids.sodiumHydroxide.present and solids.inputBus.present and fluids.inputHatch.present and solids.inputBus.side == fluids.inputHatch.side then
        print("T4 discovered at ", addr)
        InputTransposers.t4 = {
            proxy = transposer,
            sodiumHydroxideSide = solids.sodiumHydroxide.side,
            sodiumHydroxideSlot = solids.sodiumHydroxide.slot,
            hydrochloricSide = fluids.hydrochloric.side,
            hydrochloricTankNum = fluids.hydrochloric.tank,
            inputSide = solids.inputBus.side,
        }
    end

    -- T5
    if fluids.heliumPlasma.present and fluids.superCoolant.present and fluids.inputHatch.present then
        print("T5 discovered at ", addr)
        InputTransposers.t5 = {
            proxy = transposer,
            heliumPlasmaSide = fluids.heliumPlasma.side,
            heliumPlasmaTankNum = fluids.heliumPlasma.tank,
            superCoolantSide = fluids.superCoolant.side,
            superCoolantTankNum = fluids.superCoolant.tank,
            inputSide = fluids.inputHatch.side
        }
    end

    -- T6

    if solids.lenses.present and solids.inputBus.present then
        print("T6 discovered at ", addr)
        InputTransposers.t6 = {
            proxy = transposer,
            lensesSide = solids.lenses.side,
            lensSlotMap = {}, 
            inputSide = solids.inputBus.side
        }
    end

    -- T7

    if fluids.heliumGas.present and fluids.neonGas.present and fluids.kryptonGas.present and fluids.xenonGas.presnet and fluids.superCoolant.present and fluids.neutronium.present and fluids.superConductor.present and fluids.inputHatch.present then
        print("T7 discovered at ", addr)
        InputTransposers.t7 = {
            proxy = transposer,
            fluidsSide = fluids.heliumGas.side, -- Assuming all fluids except superconductor base are in one dual interface
            fluidsTankMap = {
                superCoolant = fluids.superCoolant.tank,
                helium = fluids.heliumGas.tank,
                neon = fluids.neonGas.tank,
                krypton = fluids.kryptonGas.tank,
                xenon = fluids.xenonGas.tank,
                neutronium = fluids.neutronium.tank
            },
            inputSide = fluids.inputHatch.side,
            superConductorSide = fluids.superConductor.side,
            superConductorTankNum = fluids.superConductor.tank
        }
    end

    -- T8

    if solids.quarks.present and solids.inputBus.present then
        print("T8 discovered at ", addr)
        InputTransposers.t8 = {
            proxy = transposer,
            lensesSide = solids.quarks.side,
            --- @type table<string, number>
            quarksSlotMap = {
                up = 1,
                down = 2,
                top = 3,
                bottom = 4,
                strange = 5,
                charm = 6
            },
            inputSide = solids.inputBus.side
        }
        for i = 1,transposer.getInventorySize(solids.quarks.side) do
            local label = transposer.getStackInSlot(solids.quarks.side, i).label
            if label == "UP" .. QUARK_CATALYST_LABEL_SUFFIX then
                InputTransposers.t8.quarksSlotMap.up = i
            elseif label == "DOWN" .. QUARK_CATALYST_LABEL_SUFFIX then
                InputTransposers.t8.quarksSlotMap.down = i
            elseif label == "TOP" .. QUARK_CATALYST_LABEL_SUFFIX then
                InputTransposers.t8.quarksSlotMap.top = i
            elseif label == "BOTTOM" .. QUARK_CATALYST_LABEL_SUFFIX then
                InputTransposers.t8.quarksSlotMap.bottom = i
            elseif label == "STRANGE" .. QUARK_CATALYST_LABEL_SUFFIX then
                InputTransposers.t8.quarksSlotMap.strange = i
            elseif label == "CHARM" .. QUARK_CATALYST_LABEL_SUFFIX then
                InputTransposers.t8.quarksSlotMap.charm = i
            end
        end
    end
end

print("Network discovery complete!")

-- Check sanity of controllers vs. transposers

if (PlantControllers.t2 == nil) ~= (InputTransposers.t2.proxy == nil) then
    error(string.format("T2 controller/transposer mismatch! %s/%s", PlantControllers.t2 == nil,
        InputTransposers.t2.proxy == nil))
end
if (PlantControllers.t3 == nil) ~= (InputTransposers.t3.proxy == nil) then
    error(string.format("T3 controller/transposer mismatch! %s/%s", PlantControllers.t3 == nil,
        InputTransposers.t3.proxy == nil))
end
if (PlantControllers.t4 == nil) ~= (InputTransposers.t4.proxy == nil) then
    error(string.format("T4 controller/transposer mismatch! %s/%s", PlantControllers.t4 == nil,
        InputTransposers.t4.proxy == nil))
end
if (PlantControllers.t5 == nil) ~= (InputTransposers.t5.proxy == nil) then
    error(string.format("T5 controller/transposer mismatch! %s/%s", PlantControllers.t5 == nil,
        InputTransposers.t5.proxy == nil))
end
if (PlantControllers.t6 == nil) ~= (InputTransposers.t6.proxy == nil) or (PlantControllers.t6 == nil) ~= (RedstoneIOs.lens == nil) then
    error(string.format("T6 controller/transposer/redstone mismatch! %s/%s/%s", PlantControllers.t6 == nil,
        InputTransposers.t6.proxy == nil,
        RedstoneIOs.lens == nil))
end
if (PlantControllers.t7 == nil) ~= (InputTransposers.t7.proxy == nil) then
    error(string.format("T7 controller/transposer mismatch! %s/%s", PlantControllers.t7 == nil,
        InputTransposers.t7.proxy == nil))
end
if (PlantControllers.t8 == nil) ~= (InputTransposers.t8.proxy == nil) then
    error(string.format("T8 controller/transposer mismatch! %s/%s", PlantControllers.t8 == nil,
        InputTransposers.t8.proxy == nil))
end
