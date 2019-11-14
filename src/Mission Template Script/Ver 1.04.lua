--[[
    Template PvP Mission Script - Version: 1.03 - 13/11/2019 by Theodossis Papadopoulos 
       ]]

-- ************************************************************************
-- *********************  USER CONFIGURATION ******************************
-- ************************************************************************
-- CAUTION CAUTION: NEVER NAME A UNIT NAME (NOT A GROUP NAME) BY A STANDAR NUMBER LIKE 1, 2... JUST LET THE UNITS NAMED UNIT #001 ETC...
local BLUE_OPERATIONS = _G["BLUE_OPERATIONS"]
local GROUPS_BLUE = _G["GROUPS_BLUE"]
local RED_OPERATIONS = _G["RED_OPERATIONS"]
local GROUPS_RED = _G["GROUPS_RED"]
local randomGroups = _G["randomGroups"]

local msgTimer = _G["msgTimer"]				   -- We specify the time that the target's asignment message will remain visible. The current target's message can be always recall via the F10 menu by selecting Target Report option. 
local blueWinMsg = _G["blueWinMsg"]     -- Here we can Specify the Blue and Red Win messages.
local redWinMsg = _G["redWinMsg"]

local aircraftCost = _G["aircraftCost"]
local heliCost = _G["heliCost"]
local shipCost = _G["shipCost"]
local unitCost = _G["unitCost"]

-- ------------------INIT VARIABLES (DO NOT MODIFY) ----------------------
local GROUPS_BLUE_DONE = {}
local GROUPS_RED_DONE = {}

-- -----------------------MISC METHODS (DO NOT MODIFY) ------------------------------------
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
-- ----------------------BLUE METHODS (DO NOT MODIFY)------------------------------------
local currentBlueTarget = 1      -- It shows the Blue Team's current target's number 
local currentBlueGroupTarget = 0 -- It shows the Blue Team's current groups's number
local bluePoints = 0
local blueACCasualties = 0
local blueHeliCasualties = 0
local blueShipCasualties = 0
local blueGroundUnitCasualties = 0
local markCounterBlue = 1000

function getCurrentOperationGroupNameBlue()
  return BLUE_OPERATIONS[currentBlueTarget].Name
end

function isCurrentOperationMapObjBlue()
  if BLUE_OPERATIONS[currentBlueTarget].isMapObj == false then
    return false
  else
    return true
  end
end

function getCurrentOperationBriefingBlue()
  return BLUE_OPERATIONS[currentBlueTarget].Briefing
end

function getCurrentOperationExtrasBlue()
  return BLUE_OPERATIONS[currentBlueTarget].Extras
end

function blueDoneOperation(id)
  bluePoints = bluePoints + BLUE_OPERATIONS[currentBlueTarget].Points
  trigger.action.removeMark(markCounterBlue)
  markCounterBlue = markCounterBlue + 1
  GROUPS_BLUE_DONE[tablelength(GROUPS_BLUE_DONE) + 1] = id
end

function printDataBlue()
  trigger.action.outTextForCoalition(coalition.side.BLUE, 'Target Report: \n' .. getCurrentOperationBriefingBlue(), msgTimer)
end

function soundBlueThatIsOurTarget()
  trigger.action.outSoundForCoalition(coalition.side.BLUE, "That Is Our Target.ogg")
end

function activateNextTargetBlue()
  trigger.action.outSoundForCoalition(coalition.side.BLUE, 'tele.ogg')
  timer.scheduleFunction(soundBlueThatIsOurTarget, nil, timer.getTime() + 6)
  if randomGroups == true then
    local _random = math.random(1, tablelength(GROUPS_BLUE))
    while(contains(GROUPS_BLUE_DONE, _random)) do
      _random = math.random(1, tablelength(GROUPS_BLUE))
    end
    currentBlueGroupTarget = _random
  else
    currentBlueGroupTarget = currentBlueGroupTarget + 1
  end
  local _randomTarget = math.random(GROUPS_BLUE[currentBlueGroupTarget][1], GROUPS_BLUE[currentBlueGroupTarget][2])
  currentBlueTarget = _randomTarget
  local _grpNames = getCurrentOperationGroupNameBlue()
  if isCurrentOperationMapObjBlue() == false then
    for i=1, tablelength(_grpNames) do
      Group.getByName(_grpNames[i]):activate()
    end
    if BLUE_OPERATIONS[currentBlueTarget].showMark == true then
      trigger.action.markToCoalition(markCounterBlue, "---OBJECTIVE---", Group.getByName(_grpNames[1]):getUnit(1):getPosition().p, coalition.side.BLUE, true)
    end
  elseif isCurrentOperationMapObjBlue() == true then
    if BLUE_OPERATIONS[currentBlueTarget].showMark == true then
      trigger.action.markToCoalition(markCounterBlue, "---OBJECTIVE---", trigger.misc.getZone(_grpNames[1]).point, coalition.side.BLUE, true)
    end
    BLUE_OPERATIONS[currentBlueTarget].Progression = 0
  end
  for i=1, tablelength(getCurrentOperationExtrasBlue()) do
    Group.getByName(getCurrentOperationExtrasBlue()[i]):activate()
  end
  printDataBlue()
end
-- ------------------ RED METHODS (DO NOT MODIFY) -------------------------------
local currentRedTarget = 1      -- It shows the Red Team's current target's number 
local currentRedGroupTarget = 0 -- It shows the Blue Team's current group's number
local redPoints = 0
local redACCasualties = 0
local redHeliCasualties = 0
local redShipCasualties = 0
local redGroundUnitCasualties = 0
local markCounterRed = 2000

function getCurrentOperationGroupNameRed()
  return RED_OPERATIONS[currentRedTarget].Name
end

function isCurrentOperationMapObjRed()
  if RED_OPERATIONS[currentRedTarget].isMapObj == false then
    return false
  else
    return true
  end
end

function getCurrentOperationBriefingRed()
  return RED_OPERATIONS[currentRedTarget].Briefing
end

function getCurrentOperationExtrasRed()
  return RED_OPERATIONS[currentRedTarget].Extras
end

function getCurrentOperationPointsRed()
  return RED_OPERATIONS[currentRedTarget].Points
end

function redDoneOperation(id)
  redPoints = redPoints + RED_OPERATIONS[currentRedTarget].Points
  trigger.action.removeMark(markCounterRed)
  markCounterRed = markCounterRed + 1
  GROUPS_RED_DONE[tablelength(GROUPS_RED_DONE) + 1] = id
end

function printDataRed()
  trigger.action.outTextForCoalition(coalition.side.RED, 'Target Report: \n' .. getCurrentOperationBriefingRed(), msgTimer)
end

function soundRedThatIsOurTarget()
  trigger.action.outSoundForCoalition(coalition.side.RED, "That Is Our Target.ogg")
end

function activateNextTargetRed()
  trigger.action.outSoundForCoalition(coalition.side.RED, 'tele.ogg')
  timer.scheduleFunction(soundRedThatIsOurTarget, nil, timer.getTime() + 6)
  if randomGroups == true then
    local _random = math.random(1, tablelength(GROUPS_RED))
    while(contains(GROUPS_RED_DONE, _random)) do
      _random = math.random(1, tablelength(GROUPS_RED))
    end
    currentRedGroupTarget = _random
  else
    currentRedGroupTarget = currentRedGroupTarget + 1
  end
  local _randomTarget = math.random(GROUPS_RED[currentRedGroupTarget][1], GROUPS_RED[currentRedGroupTarget][2])
  currentRedTarget = _randomTarget
  local _grpNames = getCurrentOperationGroupNameRed()
  if isCurrentOperationMapObjRed() == false then
    for i=1, tablelength(_grpNames) do
      Group.getByName(_grpNames[i]):activate()
    end
    if RED_OPERATIONS[currentRedTarget].showMark == true then
      trigger.action.markToCoalition(markCounterRed, "---OBJECTIVE---", Group.getByName(_grpNames[1]):getUnit(1):getPosition().p, coalition.side.RED, true)
    end
  elseif isCurrentOperationMapObjRed() == true then
    if RED_OPERATIONS[currentRedTarget].showMark == true then
      trigger.action.markToCoalition(markCounterRed, "---OBJECTIVE---", trigger.misc.getZone(_grpNames[1]).point, coalition.side.RED, true)
    end
    RED_OPERATIONS[currentRedTarget].Progression = 0
  end
  for i=1, tablelength(getCurrentOperationExtrasRed()) do
    Group.getByName(getCurrentOperationExtrasRed()[i]):activate()
  end
  printDataRed()
end
-- -----------------------------------(DO NOT MODIFY) ------------------------------------
function groupIsDead(inGroupName)
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

GROUP_DEAD = {}
function GROUP_DEAD:onEvent(event)
  if(event.id == world.event.S_EVENT_DEAD) then
    local who = event.initiator
    if who:getCategory() == Object.Category.UNIT then
      if who:getCoalition() == coalition.side.RED then
        local _grp = Unit.getGroup(who)
        if(contains(getCurrentOperationGroupNameBlue(), _grp:getName())) and (groupIsDead(_grp:getName())) then
          local totalNames = tablelength(getCurrentOperationGroupNameBlue())
          local deathCounter = 0
          for i=1, totalNames do
            if groupIsDead(getCurrentOperationGroupNameBlue()[i]) then
              deathCounter = deathCounter + 1
          end
        end
        if totalNames - deathCounter == 0 then
          blueDoneOperation(currentBlueGroupTarget)
          if(tablelength(GROUPS_BLUE) - tablelength(GROUPS_BLUE_DONE) == 0) then -- BLUE WON
            trigger.action.outText(blueWinMsg, msgTimer)
          else
           activateNextTargetBlue()
           end
          end
        end 
      elseif who:getCoalition() == coalition.side.BLUE then
        local _grp = Unit.getGroup(who)
        if(contains(getCurrentOperationGroupNameRed(), _grp:getName())) and (groupIsDead(_grp:getName())) then
          local totalNames = tablelength(getCurrentOperationGroupNameRed())
          local deathCounter = 0
          for i=1, totalNames do
            if groupIsDead(getCurrentOperationGroupNameRed()[i]) then
              deathCounter = deathCounter + 1
            end
          end
          if totalNames - deathCounter == 0 then
            redDoneOperation(currentRedGroupTarget)
            if(tablelength(GROUPS_RED) - tablelength(GROUPS_RED_DONE) == 0) then -- RED WON
              trigger.action.outText(redWinMsg, msgTimer)
            else
              activateNextTargetRed()
            end
          end
        end
      end
    elseif who:getCategory() == Object.Category.SCENERY then
      if isCurrentOperationMapObjBlue() == true then
        local totalNames = tablelength(getCurrentOperationGroupNameBlue())
        local deathCounter = 0
        for i=1, totalNames do
          if(tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameBlue()[i]}))) > 0 then
            deathCounter = deathCounter + 1
          end
        end
        if totalNames - deathCounter == 0 then
          blueDoneOperation(currentBlueGroupTarget)
          if(tablelength(GROUPS_BLUE) - tablelength(GROUPS_BLUE_DONE) == 0) then -- BLUE WON
            trigger.action.outText(blueWinMsg, msgTimer)
          else
            activateNextTargetBlue()
          end
        end
      end
      if isCurrentOperationMapObjRed() == true then
        local totalNames = tablelength(getCurrentOperationGroupNameRed())
        local deathCounter = 0
        for i=1, totalNames do
          if(tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameRed()[i]}))) > 0 then
            deathCounter = deathCounter + 1
          end
        end
        if totalNames - deathCounter == 0 then
          redDoneOperation(currentRedGroupTarget)
          if(tablelength(GROUPS_RED) - tablelength(GROUPS_RED_DONE) == 0) then -- RED WON
             trigger.action.outText(redWinMsg, msgTimer)
          else
            activateNextTargetRed()
          end
        end
      end
    end
  end
end
world.addEventHandler(GROUP_DEAD)

POINT_SYSTEM = {}
function POINT_SYSTEM:onEvent(event)
  local who = event.initiator
  if event.id == world.event.S_EVENT_PILOT_DEAD or event.id == world.event.S_EVENT_EJECTION then
    if who:getGroup():getCategory() == Group.Category.AIRPLANE then
      if who:getCoalition() == coalition.side.BLUE then
        blueACCasualties = blueACCasualties + 1
      elseif who:getCoalition() == coalition.side.RED then
        redACCasualties = redACCasualties + 1
      end
    elseif who:getGroup():getCategory() == Group.Category.HELICOPTER then
      if who:getCoalition() == coalition.side.BLUE then
        blueHeliCasualties = blueHeliCasualties + 1
      elseif who:getCoalition() == coalition.side.RED then
        redHeliCasualties = redHeliCasualties + 1
      end
    end
  end
  if event.id == world.event.S_EVENT_DEAD then
    if who:getCategory() == Object.Category.UNIT then
      if who:getGroup():getCategory() == Group.Category.SHIP then
        if who:getCoalition() == coalition.side.BLUE then
          blueShipCasualties = blueShipCasualties + 1
        elseif who:getCoalition() == coalition.side.RED then
          redShipCasualties = redShipCasualties + 1
        end
      elseif who:getGroup():getCategory() == Group.Category.GROUND then
        if who:getCoalition() == coalition.side.BLUE then
          blueGroundUnitCasualties = blueGroundUnitCasualties + 1
        elseif who:getCoalition() == coalition.side.RED then
          redGroundUnitCasualties = redGroundUnitCasualties + 1
        end
      end
    end
  end
end
world.addEventHandler(POINT_SYSTEM)

-- -----------------------------SCORE PRINTER----------------------------------------
function printPoints()
  local totalPointsForBlue = bluePoints + redACCasualties*aircraftCost + redHeliCasualties*heliCost + redShipCasualties*shipCost + redGroundUnitCasualties*unitCost
  local totalPointsForRed = redPoints + blueACCasualties*aircraftCost + blueHeliCasualties*heliCost + blueShipCasualties*shipCost + blueGroundUnitCasualties*unitCost
  trigger.action.outText('###  TEAM SCORES ###  Created by =GR= Theodossis for LoG' , 30)
  trigger.action.outText('POINTS:  BLUELAND TEAM: ' .. totalPointsForBlue .. '  / REDLAND TEAM: ' .. totalPointsForRed, 30)
  trigger.action.outText('BLUE TEAM CASUALTIES: A/C:' .. blueACCasualties .. ' HELO: ' .. blueHeliCasualties .. ' SHIPS: ' .. blueShipCasualties .. ' GROUND UNITS: ' .. blueGroundUnitCasualties .. ' \nPOINTS FROM OPERATIONS: '.. bluePoints, 30)  
  trigger.action.outText('RED TEAM CASUALTIES: A/C:' .. redACCasualties .. ' HELO: ' .. redHeliCasualties .. ' SHIPS: ' .. redShipCasualties .. ' GROUND UNITS: ' .. redGroundUnitCasualties .. ' \nPOINTS FROM OPERATIONS: '.. redPoints, 30)  
end

mist.scheduleFunction(printPoints, nil, timer.getTime() + 10, 300)

missionCommands.addCommandForCoalition(coalition.side.BLUE, 'Target report', nil, printDataBlue, nil)
missionCommands.addCommandForCoalition(coalition.side.RED, 'Target report', nil, printDataRed, nil)

activateNextTargetBlue()
activateNextTargetRed()