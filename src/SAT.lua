--[[
    SAT - Satellite Imagery Script - Version: 1.0 - 16/1/2020 by Theodossis Papadopoulos
    -- Requires MIST
       ]]
local maxSATTargets = 8 -- How much targets will SAT provide at maximum
local imageEvery = 600 -- How many seconds between each SAT Image update (if SAT station is still alive)
local SAT_NAMES_BLUE = {"SAT_1", "SAT_2"} -- Names of units/statics providing SAT Imagery for BLUE team
local SAT_NAMES_RED = {"SAT_RED"} -- Names of units/statics providing SAT Imagery for RED team
local mainbaseBlue = "Al Ain International Airport"
local mainbaseRed = "Khasab"

-- --------------------------CODE DO NOT TOUCH--------------------------
local DET_TARGETS_BLUE = {} -- UNIT_NAME, TYPE, POS (IN VEC3) which targets have blue SAT detected
local DET_TARGETS_RED = {} -- Which targets have red SAT detected

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function tableConcat(t1, t2)
  for i=1, #t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

function round(x, n)
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return x / n
end

local function tableStr(tab)
  local finalStr = ""
  for i=1, tablelength(tab) do
    finalStr = finalStr .. tab[i] .. " "
  end
  return finalStr
end

function updateTargets()
  -- For Blue team (searching RED targets)
  if tablelength(SAT_NAMES_BLUE) > 0 then
    DET_TARGETS_BLUE = {}
    local minDistUnits = {}
    for k=1, maxSATTargets do
      local minTemp = Group.getByName("MAX_DIST"):getUnit(1)
      for i, gp in pairs(coalition.getGroups(coalition.side.RED)) do
        if gp:getCategory() == Group.Category.GROUND then
          for j, un in pairs(gp:getUnits()) do
            if((un:getPosition().p.x - Airbase.getByName(mainbaseBlue):getPosition().p.x)^2 + (un:getPosition().p.z - Airbase.getByName(mainbaseBlue):getPosition().p.z)^2)^0.5 < ((minTemp:getPosition().p.x - Airbase.getByName(mainbaseBlue):getPosition().p.x)^2 + (minTemp:getPosition().p.z - Airbase.getByName(mainbaseBlue):getPosition().p.z)^2)^0.5 then -- FOUND CLOSER
              if contains(minDistUnits, un) == false and un:isActive() == true then
                minTemp = un
              end
            end
          end
        end
      end
      if contains(minDistUnits, minTemp) == false then
        minDistUnits[tablelength(minDistUnits) + 1] = minTemp
      end
    end
    for i=1, tablelength(minDistUnits) do
      local un = minDistUnits[i]
      if un:getName() ~= "MAX_DIST" then
        DET_TARGETS_BLUE[tablelength(DET_TARGETS_BLUE) + 1] = {["UNIT_NAME"] = un:getName(), ["TYPE"] = un:getTypeName(), ["POS"] = un:getPosition().p}
      end
    end
    trigger.action.outTextForCoalition(coalition.side.BLUE, "SAT targets have been updated", 20)
  end
  -- For Red team (searching BLUE targets)
  if tablelength(SAT_NAMES_RED) > 0 then
    DET_TARGETS_RED = {}
    local minDistUnits = {}
    for k=1, maxSATTargets do
      local minTemp = Group.getByName("MAX_DIST"):getUnit(1)
      for i, gp in pairs(coalition.getGroups(coalition.side.BLUE)) do
        if gp:getCategory() == Group.Category.GROUND then
          for j, un in pairs(gp:getUnits()) do
            if((un:getPosition().p.x - Airbase.getByName(mainbaseRed):getPosition().p.x)^2 + (un:getPosition().p.z - Airbase.getByName(mainbaseRed):getPosition().p.z)^2)^0.5 < ((minTemp:getPosition().p.x - Airbase.getByName(mainbaseRed):getPosition().p.x)^2 + (minTemp:getPosition().p.z - Airbase.getByName(mainbaseRed):getPosition().p.z)^2)^0.5 then -- FOUND CLOSER
              if contains(minDistUnits, un) == false and un:isActive() == true then
                minTemp = un
              end
            end
          end
        end
      end
      if contains(minDistUnits, minTemp) == false then
        minDistUnits[tablelength(minDistUnits) + 1] = minTemp
      end
    end
    for i=1, tablelength(minDistUnits) do
      local un = minDistUnits[i]
      if un:getName() ~= "MAX_DIST" then
        DET_TARGETS_RED[tablelength(DET_TARGETS_RED) + 1] = {["UNIT_NAME"] = un:getName(), ["TYPE"] = un:getTypeName(), ["POS"] = un:getPosition().p}
      end
    end
    trigger.action.outTextForCoalition(coalition.side.RED, "SAT targets have been updated", 20)
  end
end

function showTargets(gpid)
  local earlyBreak = false
  local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
  local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
  local allUnits = tableConcat(blueUnits, redUnits)
  for j=1, tablelength(allUnits) do
    local us = allUnits[j]
    if us:getGroup():getID() == gpid then -- Found him/them for two seat
      earlyBreak = true
      local finalMsg = nil
      if us:getCoalition() == coalition.side.BLUE then
        if tablelength(SAT_NAMES_BLUE) > 0 then -- Do satellite comm towers work?
          finalMsg = "Satellite report for enemy targets: (Fetching from " .. tableStr(SAT_NAMES_BLUE) .. ")"
          for i=1, tablelength(DET_TARGETS_BLUE) do
            local lati, longi, alt = coord.LOtoLL(DET_TARGETS_BLUE[i].POS)
            finalMsg = finalMsg .. "\nTarget Type: " .. DET_TARGETS_BLUE[i].TYPE .. " at coordinates    " .. mist.tostringLL(lati, longi, 4) .. "   " .. round(alt*3.281, 0) .. "ft"
          end
        else
          finalMsg = "Satellite communication towers have been destroyed! Your team no longer have Satellite Imagery"
        end
      elseif us:getCoalition() == coalition.side.RED then
        if tablelength(SAT_NAMES_RED) > 0 then -- Do satellite comm towers work?
          finalMsg = "Satellite report for enemy targets:  (Fetching from " .. tableStr(SAT_NAMES_RED) .. ")"
          for i=1, tablelength(DET_TARGETS_RED) do
            local lati, longi, alt = coord.LOtoLL(DET_TARGETS_RED[i].POS)
            finalMsg = finalMsg .. "\nTarget Type: " .. DET_TARGETS_RED[i].TYPE .. " at coordinates    " .. mist.tostringLL(lati, longi, 4) .. "    " .. round(alt*3.281, 0) .. "ft"
          end
        else
          finalMsg = "Satellite communication towers have been destroyed! Your team no longer have Satellite Imagery"
        end
      end
      trigger.action.outTextForGroup(gpid, finalMsg, 45)
    end
    if earlyBreak == true then
      break
    end
  end
end

local EV_MANAGER = {}
function EV_MANAGER:onEvent(event)
  if event.id == world.event.S_EVENT_BIRTH then
    if event.initiator:getCategory() == Object.Category.UNIT then
      if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE or event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
        local gpid = event.initiator:getGroup():getID()
        missionCommands.removeItemForGroup(event.initiator:getGroup():getID(), {[1] = "Show SAT targets"})
        missionCommands.addCommandForGroup(gpid, "Show SAT targets", nil, showTargets, gpid)
      end
    end
  elseif event.id == world.event.S_EVENT_DEAD then -- SAT Death
    if event.initiator:getCategory() == Object.Category.UNIT or event.initiator:getCategory() == Object.Category.STATIC then
      -- Check for Blue team
      if event.initiator:getCoalition() == coalition.side.BLUE then
        for i=1, tablelength(SAT_NAMES_BLUE) do
          if SAT_NAMES_BLUE[i] == event.initiator:getName() then -- FOUND IT
            table.remove(SAT_NAMES_BLUE, i)
          end
        end
        trigger.action.outTextForCoalition(coalition.side.BLUE, "Our satellite station: " .. event.initiator:getName() .. " has just been destroyed!", 30)
        trigger.action.outTextForCoalition(coalition.side.RED, "We have successfully destroyed blue's team satellite station: " .. event.initiator:getName(), 30)
      end
      -- Check for Red team
      if event.initiator:getCoalition() == coalition.side.RED then
        for i=1, tablelength(SAT_NAMES_RED) do
          if SAT_NAMES_RED[i] == event.initiator:getName() then -- FOUND IT
            table.remove(SAT_NAMES_RED, i)
          end
        end
        trigger.action.outTextForCoalition(coalition.side.RED, "Our satellite station: " .. event.initiator:getName() .. " has just been destroyed!", 30)
        trigger.action.outTextForCoalition(coalition.side.BLUE, "We have successfully destroyed red's team satellite station: " .. event.initiator:getName(), 30)
      end
    end
  end
  -- Debug
  --[[if event.id == world.event.S_EVENT_TAKEOFF then
    if event.place ~= nil then
      if event.place:getCategory() == Object.Category.BASE then
        if event.place:getName() == "Al Ain International Airport" then
          trigger.action.outText("true", 15)
        end
      end
    end
  end ]]
end
world.addEventHandler(EV_MANAGER)

mist.scheduleFunction(updateTargets, nil, timer.getTime(), imageEvery)