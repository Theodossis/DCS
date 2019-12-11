--[[
    Weapon Manager Script - Version: 1.1 - 11/12/2019 by Theodossis Papadopoulos 
       ]]
local msgTimer = 15
local limitations = {}

limitations[1] = {
  WP_NAME = "AIM_120C",
  QTY = 1,
}
limitations[2] = {
  WP_NAME = "AIM_120",
  QTY = 15,
}
limitations[3] = {
  WP_NAME = "AIM_9X",
  QTY = 30,
}

local playersSettedUp = {}
local data = {}
local tobedestroyed = {}

-- ----------------------- MISC METHODS CODE ------------------------------------
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
-- --------------------DATA MANAGER--------------------
function setup(playerName)
  data[tablelength(data) + 1] = { PlayerName = playerName, Limitations = limitations}
  playersSettedUp[tablelength(playersSettedUp) + 1] = playerName
end

function destroyerContains(unitName)
  for i=1, tablelength(tobedestroyed) do
    if(tobedestroyed[i].Unitname == unitName) then
      return true
    end
  end
  return false
end

function makeMore(playerName, wpn, howMany)
  local earlyBreak = false
  for i=1, tablelength(data) do
    if(data[i].PlayerName == playerName) then -- FOUND HIM
      earlyBreak = true
      for j=1, tablelength(data[i].Limitations) do
        if(data[i].Limitations[j].WP_NAME == wpn) then -- FOUND WEAPON
          data[i].Limitations[j].QTY = data[i].Limitations[j].QTY + howMany
        end
      end
    end
    if earlyBreak == true then
      break
    end
  end
end

function destroyAfter5MINS(unitName)
  for i=1, tablelength(tobedestroyed) do
    if tobedestroyed[i].Unitname == unitName then -- FOUND HIM
      trigger.action.explosion(Unit.getByName(unitName):getPosition().p, 100)
      mist.removeFunction(tobedestroyed[i].Funcid)
      table.remove(tobedestroyed, i)
      break
    end
  end
end

function makeLess(playerName, wpn, howMany, unit)
  local earlyBreak = false
  for i=1, tablelength(data) do
    if(data[i].PlayerName == playerName) then -- FOUND HIM
      earlyBreak = true
      for j=1, tablelength(data[i].Limitations) do
        if(data[i].Limitations[j].WP_NAME == wpn) then -- FOUND WEAPON
          if(data[i].Limitations[j].QTY - howMany < 0) then
            trigger.action.outTextForGroup(unit:getGroup():getID(), "LOADOUT NOT VALID, RETURN TO BASE FOR REARMING NOW OR YOU WILL BE DESTROYED IN 5 MINS", 300)
            if not destroyerContains(unit:getName()) then
              local id = mist.scheduleFunction(destroyAfter5MINS, {unit:getName()}, timer.getTime() + 300)
              tobedestroyed[tablelength(tobedestroyed) + 1] = { Unitname = unit:getName(), Funcid = id}
            end
          end
          data[i].Limitations[j].QTY = data[i].Limitations[j].QTY - howMany
        end
      end
    end
    if earlyBreak == true then
      break
    end
  end
end
-- --------------------DATA PRINTER--------------------
function printHowManyLeft(playerName)
  local earlyBreak = false
  for i, gp in pairs(coalition.getGroups(coalition.side.BLUE, Group.Category.AIRPLANE)) do -- Blue checker
    for j, us in pairs(gp:getUnits()) do
      if(us:getPlayerName() == playerName) then -- Found him!
        earlyBreak = true
        trigger.action.outTextForGroup(gp:getID(), "Weapons left for " .. playerName .. " :", msgTimer)
        local text = ""
        local secondearlyBreak = false
        for d=1, tablelength(data) do
          if data[d].PlayerName == playerName then
            secondearlyBreak = true
            for e=1, tablelength(data[d].Limitations) do
              text = text .. data[d].Limitations[e].WP_NAME .. " : " .. data[d].Limitations[e].QTY .. "\n"
            end
            trigger.action.outTextForGroup(gp:getID(), text, msgTimer)
          end
          if secondearlyBreak == true then
            break
          end
        end
      end
    end
    if earlyBreak == true then
      break
    end
  end
  for i, gp in pairs(coalition.getGroups(coalition.side.RED, Group.Category.AIRPLANE)) do -- Red checker
    for j, us in pairs(gp:getUnits()) do
      if(us:getPlayerName() == playerName) then -- Found him!
        earlyBreak = true
        trigger.action.outTextForGroup(gp:getID(), "Weapons left for " .. playerName .. " :", msgTimer)
        local text = ""
        local secondearlyBreak = false
        for d=1, tablelength(data) do
          if data[d].PlayerName == playerName then
            secondearlyBreak = true
            for e=1, tablelength(data[d].Limitations) do
              text = text + data[d].Limitations[e].WP_NAME + " : " + data[d].Limitations[e].QTY + "\n"
            end
            trigger.action.outTextForGroup(gp:getID(), text, msgTimer)
          end
          if secondearlyBreak == true then
            break
          end
        end
      end
    end
    if earlyBreak == true then
      break
    end
  end
end

EV_MANAGER = {}
function EV_MANAGER:onEvent(event)
  if event.id == world.event.S_EVENT_BIRTH then
    if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE then
      local playerName = event.initiator:getPlayerName()
      missionCommands.removeItemForGroup(event.initiator:getGroup():getID(), {[1] = "Show weapons left"})
      if not contains(playersSettedUp, playerName) then
        setup(playerName)
      end
      missionCommands.addCommandForGroup(event.initiator:getGroup():getID(), "Show weapons left", nil, printHowManyLeft, playerName)
      --FOR DEBUGGING
      --for i, ammo in pairs(event.initiator:getAmmo()) do
      --  trigger.action.outText(ammo.desc.typeName, msgTimer)
      --end
    end
  elseif event.id == world.event.S_EVENT_TAKEOFF then
    for i, ammo in pairs(event.initiator:getAmmo()) do
      for j=1, tablelength(limitations) do
        if(limitations[j].WP_NAME == ammo.desc.typeName) then
          makeLess(event.initiator:getPlayerName(), ammo.desc.typeName, ammo.count, event.initiator)
        end
      end
    end
  elseif event.id == world.event.S_EVENT_LAND then
    for i, ammo in pairs(event.initiator:getAmmo()) do
      for j=1, tablelength(limitations) do
        if(limitations[j].WP_NAME == ammo.desc.typeName) then
          makeMore(event.initiator:getPlayerName(), ammo.desc.typeName, ammo.count)
        end
      end
    end
    for i=1, tablelength(tobedestroyed) do
      if(tobedestroyed[i].Unitname == event.initiator:getName()) then -- FOUND HIM
        mist.removeFunction(tobedestroyed[i].Funcid)
        table.remove(tobedestroyed, i)
        trigger.action.outTextForGroup(event.initiator:getGroup():getID(), "Successfully returned back to base. You will not be destroyed", 300)
        break
      end
    end
  elseif event.id == world.event.S_EVENT_SHOT then
    for i=1, tablelength(tobedestroyed) do
      if(tobedestroyed[i].Unitname == event.initiator:getName()) then -- FOUND HIM
        mist.removeFunction(tobedestroyed[i].Funcid)
        table.remove(tobedestroyed, i)
        trigger.action.outTextForGroup(event.initiator:getGroup():getID(), "You have been destroyed because you fired a limited weapon", msgTimer, true)
        trigger.action.explosion(event.initiator:getPosition().p, 100)
        trigger.action.explosion(event.weapon:getPosition().p, 100)
        break
      end
    end
  end
end
world.addEventHandler(EV_MANAGER)