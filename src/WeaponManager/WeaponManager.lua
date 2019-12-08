--[[
    Weapon Manager Script - Version: 1.00 - 8/12/2019 by Theodossis Papadopoulos 
       ]]
local msgTimer = 15
local players = {"=GR= Theodossis", "=GR= Panthir"}
local limitations = {}

limitations[1] = {
  WP_NAME = "AIM_120C",
  QTY = 1,
}
limitations[2] = {
  WP_NAME = "AIM_120B",
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

function makeMore(playerName, wpn, howMany)
  for i=1, tablelength(data) do
    if(data[i].PlayerName == playerName) then -- FOUND HIM
      for j=1, tablelength(data[i].Limitations) do
        if(data[i].Limitations[j].WP_NAME == wpn) then -- FOUND WEAPON
          data[i].Limitations[j].QTY = data[i].Limitations[j].QTY + howMany
        end
      end
    end
  end
end

function destroyAfter5MINS(unitName)
  if(contains(tobedestroyed, unitName)) then
    trigger.action.explosion(Unit.getByName(unitName):getPosition().p, 100)
  end
end

function makeLess(playerName, wpn, howMany, unit)
  for i=1, tablelength(data) do
    if(data[i].PlayerName == playerName) then -- FOUND HIM
      for j=1, tablelength(data[i].Limitations) do
        if(data[i].Limitations[j].WP_NAME == wpn) then -- FOUND WEAPON
          if(data[i].Limitations[j].QTY - howMany < 0) then
            trigger.action.outTextForGroup(unit:getGroup():getID(), "LOADOUT NOT VALID, RETURN TO BASE FOR REARMING NOW OR YOU WILL BE DESTROYED IN 5 MINS", 300)
            if not contains(tobedestroyed, unit:getName()) then -- IF HE IS NOT ALREADY IN THE LIST
              tobedestroyed[tablelength(tobedestroyed) + 1] = unit:getName()
              mist.scheduleFunction(destroyAfter5MINS, {unit:getName()}, timer.getTime() + 300)
            end
          end
          data[i].Limitations[j].QTY = data[i].Limitations[j].QTY - howMany
        end
      end
    end
  end
end
-- --------------------DATA PRINTER--------------------
function printHowManyLeft(playerName)
  for i, gp in pairs(coalition.getGroups(coalition.side.BLUE, Group.Category.AIRPLANE)) do -- Blue checker
    for j, us in pairs(gp:getUnits()) do
      if(us:getPlayerName() == playerName) then -- Found him!
        trigger.action.outTextForGroup(gp:getID(), "Weapons left for " .. playerName .. " :", msgTimer)
        local text = ""
        for d=1, tablelength(data) do
          if data[d].PlayerName == playerName then
            for e=1, tablelength(data[d].Limitations) do
              text = text .. data[d].Limitations[e].WP_NAME .. " : " .. data[d].Limitations[e].QTY .. "\n"
            end
            trigger.action.outTextForGroup(gp:getID(), text, msgTimer)
          end
        end
      end
    end
  end
  for i, gp in pairs(coalition.getGroups(coalition.side.RED, Group.Category.AIRPLANE)) do -- Red checker
    for j, us in pairs(gp:getUnits()) do
      if(us:getPlayerName() == playerName) then -- Found him!
        trigger.action.outTextForGroup(gp:getID(), "Weapons left for " .. playerName .. " :", msgTimer)
        local text = ""
        for d=1, tablelength(data) do
          if data[d].PlayerName == playerName then
            for e=1, tablelength(data[d].Limitations) do
              text = text + data[d].Limitations[e].WP_NAME + " : " + data[d].Limitations[e].QTY + "\n"
            end
            trigger.action.outTextForGroup(gp:getID(), text, msgTimer)
          end
        end
      end
    end
  end
end

EV_MANAGER = {}
function EV_MANAGER:onEvent(event)
  if event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
    local playerName = event.initiator:getPlayerName()
    missionCommands.removeItemForGroup(event.initiator:getGroup():getID(), {[1] = "Show weapons left"})
    if not contains(playersSettedUp, playerName) and contains(players, playerName) then
      setup(playerName)
    end
    missionCommands.addCommandForGroup(event.initiator:getGroup():getID(), "Show weapons left", nil, printHowManyLeft, playerName)
    for i, ammo in pairs(event.initiator:getAmmo()) do
      trigger.action.outText(ammo.desc.typeName, msgTimer)
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
    if(contains(tobedestroyed, event.initiator:getName())) then
      for i=1, tablelength(tobedestroyed) do
        if(tobedestroyed[i] == event.initiator:getName()) then -- FOUND HIM
          table.remove(tobedestroyed, i)
        end
      end
    end
  end
end
world.addEventHandler(EV_MANAGER)