--[[
    Diplomats capture script - Version: 1.1 - 21/2/2020 by Theodossis Papadopoulos
    -- Requires MIST
    -- Compatible with my Point System
       ]]
-- --------------------------CODE DO NOT TOUCH--------------------------
local BLUE_DIPLOMATS = {}
local RED_DIPLOMATS =  {}
-- ---------------------------CONFIGURATION---------------------------
local safezoneBlue = "BLUE_SAFEZONE"
local safezoneRed = "RED_SAFEZONE"
local showSmokes = true

BLUE_DIPLOMATS[1] = {
  Zone = "BLUE_DIPLOMAT_1",
  Briefing = "1",
  Points = 2
}
BLUE_DIPLOMATS[2] = {
  Zone = "BLUE_DIPLOMAT_2",
  Briefing = "2",
  Points = 2
}
RED_DIPLOMATS[1] = {
  Zone = "RED_DIPLOMAT_1",
  Briefing = "",
  Points = 2
}
-- --------------------------CODE DO NOT TOUCH--------------------------
local carry = {} -- carry[i] { GPID = gpid, Diplomat = pointer}

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local function tableConcat(t1, t2)
  for i=1, #t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

local function isInZone(un, zonename)
  local zone = trigger.misc.getZone(zonename)
  return ((un:getPosition().p.x - zone.point.x)^2 + (un:getPosition().p.z - zone.point.z)^2)^0.5 < zone.radius
end

local function isCarrying(gpid)
  for i=1, tablelength(carry) do
    if carry[i].GPID == gpid then
      return true
    end
  end
  return false
end

local function getCarryPointer(gpid)
  for i=1, tablelength(carry) do
    if carry[i].GPID == gpid then
      return i
    end
  end
  return nil
end

local function getCarryingDiplomat(gpid)
  for i=1, tablelength(carry) do
    if carry[i].GPID == gpid then
      return carry[i].Diplomat
    end
  end
  return nil
end

local function showDiplomats(gpid)
  local earlyBreak = false
  local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
  local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
  local allUnits = tableConcat(blueUnits, redUnits)
  for j=1, tablelength(allUnits) do
    local us = allUnits[j]
    if us:getGroup():getID() == gpid then -- Found him/them for two seat
      earlyBreak = true
      local finalMsg = "Diplomat capture menu:"
      if us:getCoalition() == coalition.side.BLUE then
        for i=1, tablelength(BLUE_DIPLOMATS) do
          if BLUE_DIPLOMATS[i].Status == "WAIT" then
            finalMsg = finalMsg .. "\n#" .. i .. " : " .. BLUE_DIPLOMATS[i].Briefing
          else
            finalMsg = finalMsg .. "\n#" .. i .. " : " .. BLUE_DIPLOMATS[i].Status 
          end
        end
      elseif us:getCoalition() == coalition.side.RED then
        for i=1, tablelength(RED_DIPLOMATS) do
          if RED_DIPLOMATS[i].Status == "WAIT" then
            finalMsg = finalMsg .. "\n#" .. i .. " : " .. RED_DIPLOMATS[i].Briefing
          else
            finalMsg = finalMsg .. "\n#" .. i .. " : " .. RED_DIPLOMATS[i].Status 
          end
        end
      end
      trigger.action.outTextForGroup(gpid, finalMsg, 30)
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
      if event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
        local gpid = event.initiator:getGroup():getID()
        missionCommands.removeItemForGroup(event.initiator:getGroup():getID(), {[1] = "Show Diplomats"})
        missionCommands.addCommandForGroup(gpid, "Show Diplomats", nil, showDiplomats, gpid)
      end
    end
  elseif event.id == world.event.S_EVENT_LAND then
    if event.initiator:getCategory() == Object.Category.UNIT then
      if event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
        local un = event.initiator
        local gpid = event.initiator:getGroup():getID()
        if un:getCoalition() == coalition.side.BLUE then
          local earlyBreak = false
          if isInZone(un, safezoneBlue) then
            if isCarrying(gpid) then
              if extraBluePoints ~= nil then
                extraBluePoints = extraBluePoints + BLUE_DIPLOMATS[getCarryingDiplomat(gpid)].Points
              end
              BLUE_DIPLOMATS[getCarryingDiplomat(gpid)].Status = "DELIVERED"
              table.remove(carry, getCarryPointer(gpid))
              trigger.action.outTextForGroup(gpid, "Diplomat delivered! Good job!", 15);
              earlyBreak = true
            end
          end
          for i=1, tablelength(BLUE_DIPLOMATS) do
            if earlyBreak == true then
              break
            end
            if isInZone(un, BLUE_DIPLOMATS[i].Zone) == true then -- Player in diplomat zone
              earlyBreak = true
              if BLUE_DIPLOMATS[i].Status == "WAIT" then
                if isCarrying(gpid) then
                  trigger.action.outTextForGroup(gpid, "You are already carrying a diplomat!", 15)
                else
                  carry[tablelength(carry) + 1] = {["GPID"] = gpid, ["Diplomat"] = i}
                  BLUE_DIPLOMATS[i].Status = "DELIVERING"
                  trigger.action.outTextForGroup(gpid, "Diplomat loaded! Deliver him back to safezone!", 15)
                end
              end 
            end
          end
        elseif un:getCoalition() == coalition.side.RED then
          local earlyBreak = false
          if isInZone(un, safezoneRed) then
            if isCarrying(gpid) then
              if extraRedPoints ~= nil then
                extraRedPoints = extraRedPoints + RED_DIPLOMATS[getCarryingDiplomat(gpid)].Points
              end
              RED_DIPLOMATS[getCarryingDiplomat(gpid)].Status = "DELIVERED"
              table.remove(carry, getCarryPointer(gpid))
              trigger.action.outTextForGroup(gpid, "Diplomat delivered! Good job!", 15);
              earlyBreak = true
            end
          end
          for i=1, tablelength(RED_DIPLOMATS) do
            if earlyBreak == true then
              break
            end
            if isInZone(un, RED_DIPLOMATS[i].Zone) == true then -- Player in diplomat zone
              earlyBreak = true
              if RED_DIPLOMATS[i].Status == "WAIT" then
                if isCarrying(gpid) then
                  trigger.action.outTextForGroup(gpid, "You are already carrying a diplomat!", 15)
                else
                  carry[tablelength(carry) + 1] = {["GPID"] = gpid, ["Diplomat"] = i}
                  RED_DIPLOMATS[i].Status = "DELIVERING"
                  trigger.action.outTextForGroup(gpid, "Diplomat loaded! Deliver him back to safezone!", 15)
                end
              end 
            end
          end
        end
      end
    end
  elseif event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
    if event.initiator ~= nil then
      if event.initiator:getCategory() == Object.Category.UNIT then
        if event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
          local un = event.initiator
          local gpid = event.initiator:getGroup():getID()
          if un:getCoalition() == coalition.side.BLUE then
            if isCarrying(gpid) then
              BLUE_DIPLOMATS[getCarryingDiplomat(gpid)].Status = "DEAD"
              table.remove(carry, getCarryPointer(gpid))
            end
          elseif un:getCoalition() == coalition.side.RED then
            if isCarrying(gpid) then
              RED_DIPLOMATS[getCarryingDiplomat(gpid)].Status = "DEAD"
              table.remove(carry, getCarryPointer(gpid))
            end
          end
        end
      end
    end
  end
end
world.addEventHandler(EV_MANAGER)

-- Setup
for i=1, tablelength(BLUE_DIPLOMATS) do
  BLUE_DIPLOMATS[i].Status = "WAIT"
end
for i=1, tablelength(RED_DIPLOMATS) do
  RED_DIPLOMATS[i].Status = "WAIT"
end

local function DIPLOMATSmokes()
  for i=1, tablelength(BLUE_DIPLOMATS) do
    if BLUE_DIPLOMATS[i].Status == "WAIT" then
      local zone = trigger.misc.getZone(BLUE_DIPLOMATS[i].Zone)
      zone.point.y = land.getHeight({x = zone.point.x, z = zone.point.z})
      trigger.action.smoke(zone.point, 4)
    end
  end
  for i=1, tablelength(RED_DIPLOMATS) do
    if RED_DIPLOMATS[i].Status == "WAIT" then
      local zone = trigger.misc.getZone(RED_DIPLOMATS[i].Zone)
      zone.point.y = land.getHeight({x = zone.point.x, z = zone.point.z})
      trigger.action.smoke(zone.point, 1)
    end
  end
end

mist.scheduleFunction(DIPLOMATSmokes, nil, timer.getTime() + 10, 300)