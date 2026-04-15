-- Stolen from GTNH discord, original source below
-- https://discord.com/channels/181078474394566657/1266797319974813747/1266797319974813747

local component = require("component")
local sides = require("sides")
local me = component.upgrade_me
local inv = component.inventory_controller
local robot = require("robot")
local rs = component.redstone
local NUM_FLUIDS = 24
local MAX_AMOUNT = 2000000000
local card_slots = {}

print("Reading Cards...")

for i = 1, NUM_FLUIDS + 1 do
  local label = inv.getStackInInternalSlot(i).label
  local j, _ = string.find(label, "(", 1, true)
  card_slots[string.sub(label, 1, j - 2)] = i
end

print("Done")

function set_redstone(l)
  rs.setOutput({[0]=l,l,l,l,l,l})
end

function set_fluid(name)
  robot.select(card_slots[name])
  inv.equip()
  robot.use()
  inv.equip()
end

function swap_and_pump()
  print("Stopping pump")
  set_redstone(0)
  os.sleep(1)
  print("Finding lowest fluid ...")
  local min_level = MAX_AMOUNT
  local min_name = "[disabled]"
  for _, fluid in ipairs(me.getFluidsInNetwork()) do
    if fluid.amount < min_level then
      min_level = fluid.amount
      min_name = fluid.label
    end
  end
  if min_name == "[disabled]" then
    print("All fluids are full!")
    os.sleep(180)
    return
  end
  print("Lowest fluid: "..min_name)
  set_fluid(min_name)
  set_redstone(1)
  os.sleep(10)
  local new_level = MAX_AMOUNT
  for _, fluid in ipairs(me.getFluidsInNetwork()) do
    if fluid.label == min_name then
      new_level = fluid.amount
      break
    end
  end
  if new_level >= MAX_AMOUNT then
    print("Done pumping fluid")
    set_redstone(0)
    return
  end
  local pump_rate = (new_level - min_level)/10
  local pump_time = 180
  local stop_when_done = false
  print("Pump rate:", pump_rate)
  if pump_rate > 0 then
    local time_to_full = (MAX_AMOUNT - new_level)/pump_rate
    if time_to_full < pump_time then
      pump_time = time_to_full
      stop_when_done = true
    end
  end
  os.sleep(pump_time)
  if stop_when_done then
    set_redstone(0)
  end
end

while true do
  swap_and_pump()
end