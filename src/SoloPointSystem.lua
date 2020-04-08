--[[
    Point System Script - Version: 1.03 - 8/4/2020 by Theodossis Papadopoulos 
       ]]
-- Requires MIST script
-- ----------------------- VARIABLE INIT ------------------------------------
local STATIC_LIST = {}
local AIRBASES = {}
local MATCH_ENDED = false
local playersSettedUp = {}
local data = {}

-- ----------------------- CONFIGURATION ------------------------------------
local msgTimer = 10 -- In seconds
local scoreboardTimer = 120 -- In seconds
local scoreboardMessageTimer = 20 -- In seconds
local countdownTimer = 9000 -- In seconds

local airplanePoints = 50 -- In seconds
local bomberPoints = 30 -- In seconds
local helicopterPoints = 30 -- In seconds
local shipPoints = 150 -- In seconds
local samPoints = 15 -- In seconds
local unitPoints = 8 -- In seconds

STATIC_LIST[1] = {
  Name = {"BT_1A", "BT_1B", "BT_1C"},
  Points = 400,
}
STATIC_LIST[2] = {
  Name = {"BT_2"},
  Points = 200,
}

AIRBASES[1] = {
  Name = "Khasab",
  Points = 600,
}
-- ----------------------- MISC METHODS CODE ------------------------------------
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

local function round(x, n)
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return x / n
end

local function groupIsDead(inGroupName)
  local groupHealth = 0
  local groupDead = false
  for index, unitData in pairs(Group.getByName(inGroupName):getUnits()) do
    groupHealth = groupHealth + unitData:getLife()
  end
  if groupHealth < 1 then
    groupDead = true
  end
  return groupDead
end

local function otherCoalition(coalitionSide)
  if coalitionSide == coalition.side.RED then
    return coalition.side.BLUE
  elseif coalitionSide == coalition.side.BLUE then
    return coalition.side.RED
  end
end

-- -------------------- DATA MANAGER --------------------
local function setup(playerName)
  data[tablelength(data) + 1] = { ["PlayerName"] = playerName, ["Score"] = 0, ["Deaths"] =  0, ["Coalition"] = 0}
  playersSettedUp[tablelength(playersSettedUp) + 1] = playerName
end

local function setCoalition(playerName, coalitionSide)
  local earlyBreak = false
  for i=1, tablelength(data) do
    if data[i].PlayerName == playerName then
      earlyBreak = true
      data[i].Coalition = coalitionSide
    end
    if earlyBreak == true then
      break
    end
  end
end

local function addScore(playerName, howMany)
  if not MATCH_ENDED then 
    local earlyBreak = false
    for i=1, tablelength(data) do
      if(data[i].PlayerName == playerName) then -- FOUND HIM
        earlyBreak = true
        data[i].Score = data[i].Score + howMany
      end
      if earlyBreak == true then
        break
      end
    end
  end
end

local function removeScore(playerName, howMany)
  if not MATCH_ENDED then
    local earlyBreak = false
    for i=1, tablelength(data) do
      if data[i].PlayerName == playerName then
        earlyBreak = true
        data[i].Score = data[i].Score - howMany
      end
      if earlyBreak == true then
        break
      end
    end
  end
end

local function addScoreCoalition(coalitionSide, howMany)
  if not MATCH_ENDED then 
    local size = tablelength(data)
    if size > 0 then
      for i=1, size do
        if data[i].Coalition == coalitionSide then
          data[i].Score = data[i].Score + howMany
        end
      end
    end
  end
end

local function addDeath(playerName)
  if not MATCH_ENDED then 
    local earlyBreak = false
    for i=1, tablelength(data) do
      if(data[i].PlayerName == playerName) then
        earlyBreak = true
        data[i].Deaths = data[i].Deaths + 1
      end
      if earlyBreak == true then
        break
      end
    end
  end
end

local function targetPoints(name)
  for i=1, tablelength(STATIC_LIST) do
    if contains(STATIC_LIST[i].Name, name) then
      return STATIC_LIST[i].Points
    end
  end
  return 0
end

local function targetPointer(name)
  for i=1, tablelength(STATIC_LIST) do  
    if contains(STATIC_LIST[i].Name, name) then
      return i
    end
  end
  return 0
end

local function targetIsInList(name)
  for i=1, tablelength(STATIC_LIST) do
    if contains(STATIC_LIST[i].Name, name) then
      return true
    end
  end
  return false
end

local function airbaseIsInList(name)
  for i=1, tablelength(AIRBASES) do
    if AIRBASES[i].Name == name then
      return true
    end
  end
  return false
end

local function airbasePoints(name)
  for i=1, tablelength(AIRBASES) do
    if AIRBASES[i].Name == name then
      return AIRBASES[i].Points
    end
  end
  return 0
end
-- -------------------- PRINT MANAGER --------------------
local function printScore(gpid)
  local earlyBreak = false
  local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
  local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
  local allUnits = tableConcat(blueUnits, redUnits)
  for j=1, tablelength(allUnits) do
    local us = allUnits[j]
    if us:getGroup():getID() == gpid then -- Found him/them for two seat
      earlyBreak = true
      local playerName = us:getPlayerName()
      local secondearlyBreak = false
      for d=1, tablelength(data) do
        if data[d].PlayerName == playerName then
          secondearlyBreak = true
          local text = nil
          if data[d].Deaths == 0 then
            text = "Your score is " .. data[d].Score .. " / none = " .. round(data[d].Score, 2)
          else
            text = "Your score is " .. data[d].Score .. " / " .. data[d].Deaths .. " = " .. round(data[d].Score/data[d].Deaths, 2)
          end
          trigger.action.outTextForGroup(us:getGroup():getID(), text, msgTimer)
        end
        if secondearlyBreak == true then
          break
        end
      end
    end
    if earlyBreak == true then
      break
    end
  end
end

local function printScores(gpid)
  local earlyBreak = false
  local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
  local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
  local allUnits = tableConcat(blueUnits, redUnits)
  for j=1, tablelength(allUnits) do
    local us = allUnits[j]
    if us:getGroup():getID() == gpid then -- Found him/them for two seat
      earlyBreak = true
      local playerName = us:getPlayerName()
      local secondearlyBreak = false
      local text = "Scores:\n---------------------------------------------"
      for d=1, tablelength(data) do
        if data[d].Deaths == 0 then
          text = text .. "\n" .. data[d].PlayerName .. " : " .. data[d].Score .. " / none = " .. round(data[d].Score, 2)
        else
          text = text .. "\n" .. data[d].PlayerName .. " : " .. data[d].Score .. " / " .. data[d].Deaths  .." = " .. round(data[d].Score/data[d].Deaths, 2)
        end
      end
      trigger.action.outTextForGroup(us:getGroup():getID(), text, msgTimer*2)
    end
    if earlyBreak == true then
      break
    end
  end
end

local function calculatePoints(coalitionSide)
  local sum = 0
  if tablelength(data) > 0 then
    for i=1, tablelength(data) do
      if data[i].Coalition == coalitionSide then
        if data[i].Deaths == 0 then
          sum = sum + data[i].Score
        else
          sum = sum + (data[i].Score / data[i].Deaths)
        end
      end
    end
  end
  return sum
end

local function scoreboard()
  if countdownTimer <= 0 then
    trigger.action.outText("###  TEAM SCORES  ###  Created by =GR= Theodossis for LoG", scoreboardTimer)
    trigger.action.outText('POINTS: BLUE TEAM: ' .. round(calculatePoints(coalition.side.BLUE), 2) .. '  / RED TEAM: ' .. round(calculatePoints(coalition.side.RED), 2) , scoreboardTimer)
    trigger.action.outText("********** MATCH ENDED! **********", scoreboardTimer)
    MATCH_ENDED = true
  else
    trigger.action.outText('###  TEAM SCORES  ###  Created by =GR= Theodossis for LoG' , scoreboardMessageTimer)
    trigger.action.outText('POINTS: BLUE TEAM: ' .. round(calculatePoints(coalition.side.BLUE), 2) .. '  / RED TEAM: ' .. round(calculatePoints(coalition.side.RED), 2), scoreboardMessageTimer)
    local hoursLeft = math.floor(countdownTimer/3600)
    local minutesLeft = (countdownTimer/60)%60
    if hoursLeft == 0 then
      trigger.action.outText("TIME REMAINING: " .. minutesLeft .." MINUTES", scoreboardMessageTimer)
    else
      trigger.action.outText("TIME REMAINING: " .. hoursLeft .. " HOURS AND " .. minutesLeft .." MINUTES", scoreboardMessageTimer)
    end
    countdownTimer = countdownTimer - scoreboardTimer
  end
end
-- -------------------- EVENT MANAGER --------------------
local EV_MANAGER = {}
function EV_MANAGER:onEvent(event)
  if event.id == world.event.S_EVENT_BIRTH then
    if event.initiator:getCategory() == Object.Category.UNIT then
      if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE or event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
        local playerName = event.initiator:getPlayerName()
        if not contains(playersSettedUp, playerName) then
          setup(playerName)
        end
        local gpid = event.initiator:getGroup():getID()
        missionCommands.removeItemForGroup(gpid, {[1] = "Show my score"})
        missionCommands.removeItemForGroup(gpid, {[1] = "Show all scores"})
        missionCommands.addCommandForGroup(gpid, "Show my score", nil, printScore, gpid)
        missionCommands.addCommandForGroup(gpid, "Show all scores", nil, printScores, gpid)
        setCoalition(playerName, event.initiator:getCoalition())
      end
    end
  elseif event.id == world.event.S_EVENT_KILL then
    local killer = event.initiator
    local deadTarget = event.target
    if killer ~= nil then
      if killer:getCategory() == Object.Category.UNIT and deadTarget:getCategory() == Object.Category.UNIT then
        if killer:getGroup():getCategory() == Group.Category.AIRPLANE or event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
          if killer:getPlayerName() ~= nil then
            if killer:getCoalition() ~= deadTarget:getCoalition() then
              local killerName = killer:getPlayerName()
              if deadTarget:getGroup():getCategory() == Group.Category.AIRPLANE then
                if deadTarget:hasSensors(Unit.SensorType.RADAR, Unit.RadarType.AS) then
                  addScore(killerName, airplanePoints)
                else
                  addScore(killerName, bomberPoints)
                end
              elseif deadTarget:getGroup():getCategory() == Group.Category.HELICOPTER then
                addScore(killerName, helicopterPoints)
              elseif deadTarget:getGroup():getCategory() == Group.Category.SHIP then
                addScore(killerName, shipPoints)
              elseif deadTarget:getGroup():getCategory() == Group.Category.GROUND then
                if deadTarget:hasAttribute("SAM elements") then
                  addScore(killerName, samPoints)
                else
                  addScore(killerName, unitPoints)
                end
              end
            else 
              local killerName = killer:getPlayerName()
              if deadTarget:getGroup():getCategory() == Group.Category.AIRPLANE then
                if deadTarget:hasSensors(Unit.SensorType.RADAR, Unit.RadarType.AS) then
                  removeScore(killerName, airplanePoints)
                else
                  removeScore(killerName, bomberPoints)
                end
              elseif deadTarget:getGroup():getCategory() == Group.Category.HELICOPTER then
                removeScore(killerName, helicopterPoints)
              elseif deadTarget:getGroup():getCategory() == Group.Category.SHIP then
                removeScore(killerName, shipPoints)
              elseif deadTarget:getGroup():getCategory() == Group.Category.GROUND then
                if deadTarget:hasAttribute("SAM elements") then
                  removeScore(killerName, samPoints)
                else
                  removeScore(killerName, unitPoints)
                end
              end
            end
          end
        end
      end
    end
  elseif event.id == world.event.S_EVENT_DEAD then
    local deadTarget = event.initiator
    if deadTarget ~= nil then
      if deadTarget:getCategory() == Object.Category.UNIT or deadTarget:getCategory() == Object.Category.STATIC then
        local deadName = deadTarget:getName()
        if deadTarget:getCategory() == Object.Category.UNIT then deadName = deadTarget:getGroup():getName() end 
        if targetIsInList(deadName) then
          if deadTarget:getCategory() == Object.Category.UNIT then
            if groupIsDead(deadName) then
              STATIC_LIST[targetPointer(deadName)].Progression[tablelength(STATIC_LIST[targetPointer(deadName)].Progression) + 1] = deadName
            end
          elseif deadTarget:getCategory() == Object.Category.STATIC then
            STATIC_LIST[targetPointer(deadName)].Progression[tablelength(STATIC_LIST[targetPointer(deadName)].Progression) + 1] = deadName
          end
          if tablelength(STATIC_LIST[targetPointer(deadName)].Name) == tablelength(STATIC_LIST[targetPointer(deadName)].Progression) then
            addScoreCoalition(otherCoalition(deadTarget:getCoalition()), targetPoints(deadName))
          end
        end
      end
    end
  elseif event.id == world.event.S_EVENT_BASE_CAPTURED then
    local airbase = event.place
    local airbaseName = airbase:getName()
    if airbaseIsInList(airbaseName) then
      addScoreCoalition(airbase:getCoalition(), airbasePoints(airbaseName))
    end
  end
  if event.id == world.event.S_EVENT_CRASH or event.id == world.event.S_EVENT_DEAD then
    if event.initiator ~= nil then
      if event.initiator:getCategory() == Object.Category.UNIT then
        if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE or event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
          local name = event.initiator:getPlayerName()
          if name ~= nil then
            addDeath(name)
          end
        end
      end
    end
  end
end
world.addEventHandler(EV_MANAGER)

for i=1, tablelength(STATIC_LIST) do
  STATIC_LIST[i].Progression = {}
end

mist.scheduleFunction(scoreboard, nil, timer.getTime() + 10, scoreboardTimer)