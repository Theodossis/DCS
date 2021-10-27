--[[
    Unit Counter Script - Version: 1.00 - 2/10/2021 by Theodossis Papadopoulos 
    -- With love for =GR= Spanker
       ]]
local BLUE_UNIT_LIMITS = {} -- Do not touch
local RED_UNIT_LIMITS = {} -- Do not touch
local msgTimer = 10

-- ----------------------UNIT LIMITS----------------------
BLUE_UNIT_LIMITS[1] = {
  TYPE_NAME = "M-1 Abrams",
  SPAWNED = 1,
  LIMIT = 4
}
BLUE_UNIT_LIMITS[2] = {
  TYPE_NAME = "Tor 9A331",
  SPAWNED = 0,
  LIMIT = 10
}
BLUE_UNIT_LIMITS[3] = {
  TYPE_NAME = "T-72B3",
  SPAWNED = 0,
  LIMIT = 10
}

RED_UNIT_LIMITS[1] = {
  TYPE_NAME = "BMP-3",
  SPAWNED = 0,
  LIMIT = 5
}
RED_UNIT_LIMITS[2] = {
  TYPE_NAME = "Tor 9A331",
  SPAWNED = 0,
  LIMIT = 1
}
RED_UNIT_LIMITS[3] = {
  TYPE_NAME = "T-72B3",
  SPAWNED = 0,
  LIMIT = 10
}

-- ----------------------CODE DO NOT TOUCH----------------------
local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function manageBirth(unit)
  --trigger.action.outText(unit:getTypeName(), msgTimer)
  if unit:getCoalition() == coalition.side.BLUE then
    for i=1, tablelength(BLUE_UNIT_LIMITS) do
      if unit:getTypeName() == BLUE_UNIT_LIMITS[i].TYPE_NAME then
        if BLUE_UNIT_LIMITS[i].SPAWNED == BLUE_UNIT_LIMITS[i].LIMIT then
          unit:destroy()
          trigger.action.outTextForCoalition(coalition.side.BLUE, "Could not spawn " .. unit:getTypeName() .. " due to unit spawn limits", msgTimer)
        else 
          BLUE_UNIT_LIMITS[i].SPAWNED = BLUE_UNIT_LIMITS[i].SPAWNED + 1
        end
      end
    end
  elseif unit:getCoalition() == coalition.side.RED then
    for i=1, tablelength(RED_UNIT_LIMITS) do
      if unit:getTypeName() == RED_UNIT_LIMITS[i].TYPE_NAME then
        if RED_UNIT_LIMITS[i].SPAWNED == RED_UNIT_LIMITS[i].LIMIT then
          unit:destroy()
          trigger.action.outTextForCoalition(coalition.side.RED, "Could not spawn " .. unit:getTypeName() .. " due to unit spawn limits", msgTimer)
        else 
          RED_UNIT_LIMITS[i].SPAWNED = RED_UNIT_LIMITS[i].SPAWNED + 1
        end
      end
    end
  end
end

function printUnitLimits(group)
  local text = "Unit limits in your coalition: \n ------------------------------"
  local debug = false
  if group:getCoalition() == coalition.side.BLUE or debug then
    for i=1, tablelength(BLUE_UNIT_LIMITS) do
      text = text .. "Type: " .. BLUE_UNIT_LIMITS[i].TYPE_NAME .. " used " .. BLUE_UNIT_LIMITS[i].SPAWNED .. "/" .. BLUE_UNIT_LIMITS[i].LIMIT .. "\n"
    end
  end
  if group:getCoalition() == coalition.side.RED or debug then
    for i=1, tablelength(RED_UNIT_LIMITS) do
      text = text .. "Type: " .. RED_UNIT_LIMITS[i].TYPE_NAME .. " used " .. RED_UNIT_LIMITS[i].SPAWNED .. "/" .. RED_UNIT_LIMITS[i].LIMIT .. "\n"
    end
  end
  trigger.action.outTextForGroup(group:getID(), text, msgTimer)
end


local EV_MANAGER = {}
function EV_MANAGER:onEvent(event)
  if event.id == world.event.S_EVENT_BIRTH then
    if event.initiator:getCategory() == Object.Category.UNIT then
      if event.initiator:getGroup():getCategory() == Group.Category.GROUND then
        manageBirth(event.initiator)
      elseif event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE or event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
        local group = event.initiator:getGroup()
        local gpid = group:getID()
        missionCommands.removeItemForGroup(gpid, {[1] = "Show unit limits"})
        missionCommands.addCommandForGroup(gpid, "Show unit limits", nil, printUnitLimits, group)
      end
    end
  end
end
world.addEventHandler(EV_MANAGER)