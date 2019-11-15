--[[
    Template PvP Mission Script - Version: 1.07 - 15/11/2019 by Theodossis Papadopoulos 
       ]]
local BLUE_OPERATIONS = _G["BLUE_OPERATIONS"]
local GROUPS_BLUE = _G["GROUPS_BLUE"]
local RED_OPERATIONS = _G["RED_OPERATIONS"]
local GROUPS_RED = _G["GROUPS_RED"]
local randomGroups = _G["randomGroups"]

local msgTimer = _G["msgTimer"]
local blueWinMsg = _G["blueWinMsg"]
local redWinMsg = _G["redWinMsg"]

local aircraftCost = _G["aircraftCost"]
local heliCost = _G["heliCost"]
local shipCost = _G["shipCost"]
local unitCost = _G["unitCost"]
local printScoreEvery = _G["printScoreEvery"] -- How much time between its cycle to show message
local printScoreFor = _G["printScoreFor"] -- How much time will the message show up

-- ------------------INIT VARIABLES (DO NOT MODIFY) ----------------------
local GROUPS_BLUE_DONE = {}
local GROUPS_RED_DONE = {}

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
-- ---------------------- BLUE METHODS CODE ------------------------------------
local currentBlueTarget = 0
local currentBlueGroupTarget = 0
local bluePoints = 0
local blueACCasualties = 0
local blueHeliCasualties = 0
local blueShipCasualties = 0
local blueGroundUnitCasualties = 0
local markCounterBlue = 1000
local markUsingBlue = {}

function getCurrentOperationGroupNameBlue()
  return BLUE_OPERATIONS[currentBlueTarget].Name
end

function isCurrentOperationMapObjBlue()
  return BLUE_OPERATIONS[currentBlueTarget].isMapObj
end

function getCurrentOperationBriefingBlue()
  return BLUE_OPERATIONS[currentBlueTarget].Briefing
end

function getCurrentOperationExtrasBlue()
  return BLUE_OPERATIONS[currentBlueTarget].Extras
end

function blueDoneOperation(id)
  bluePoints = bluePoints + BLUE_OPERATIONS[currentBlueTarget].Points
  for i=1, tablelength(markUsingBlue) do
    trigger.action.removeMark(markUsingBlue[i])
  end
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
  for i=1, tablelength(_grpNames) do
    if isCurrentOperationMapObjBlue()[i] == false then
      Group.getByName(_grpNames[i]):activate()
      if BLUE_OPERATIONS[currentBlueTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterBlue, "---OBJECTIVE---", Group.getByName(_grpNames[i]):getUnit(1):getPosition().p, coalition.side.BLUE, true)
        markUsingBlue[tablelength(markUsingBlue) + 1] = markCounterBlue
        markCounterBlue = markCounterBlue + 1
      end
    elseif isCurrentOperationMapObjBlue()[i] == true then
      if BLUE_OPERATIONS[currentBlueTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterBlue, "---OBJECTIVE---", trigger.misc.getZone(_grpNames[i]).point, coalition.side.BLUE, true)
        markUsingBlue[tablelength(markUsingBlue) + 1] = markCounterBlue
        markCounterBlue = markCounterBlue + 1
      end
    end
    for i=1, tablelength(getCurrentOperationExtrasBlue()) do
      Group.getByName(getCurrentOperationExtrasBlue()[i]):activate()
    end
    BLUE_OPERATIONS[currentBlueTarget].Done = {}
  end
  printDataBlue()
end
-- ------------------ RED METHODS CODE -------------------------------
local currentRedTarget = 0
local currentRedGroupTarget = 0
local redPoints = 0
local redACCasualties = 0
local redHeliCasualties = 0
local redShipCasualties = 0
local redGroundUnitCasualties = 0
local markCounterRed = 2000
local markUsingRed = {}

function getCurrentOperationGroupNameRed()
  return RED_OPERATIONS[currentRedTarget].Name
end

function isCurrentOperationMapObjRed()
  return RED_OPERATIONS[currentRedTarget].isMapObj
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
  for i=1, tablelength(markUsingRed) do
    trigger.action.removeMark(markUsingRed[i])
  end
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
  for i=1, tablelength(_grpNames) do
    if isCurrentOperationMapObjRed()[i] == false then
      Group.getByName(_grpNames[i]):activate()
      if RED_OPERATIONS[currentRedTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterRed, "---OBJECTIVE---", Group.getByName(_grpNames[i]):getUnit(1):getPosition().p, coalition.side.RED, true)
        markUsingRed[tablelength(markUsingRed) + 1] = markCounterRed
        markCounterRed = markCounterRed + 1
      end
    elseif isCurrentOperationMapObjRed()[i] == true then
      if RED_OPERATIONS[currentRedTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterRed, "---OBJECTIVE---", trigger.misc.getZone(_grpNames[i]).point, coalition.side.RED, true)
        markUsingRed[tablelength(markUsingRed) + 1] = markCounterRed
        markCounterRed = markCounterRed + 1
      end
    end
    for i=1, tablelength(getCurrentOperationExtrasRed()) do
      Group.getByName(getCurrentOperationExtrasRed()[i]):activate()
    end
    RED_OPERATIONS[currentRedTarget].Done = {}
  end
  printDataRed()
end

-- ----------------------------------- EVENT CODE ------------------------------------
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
    -- ----------------------------------------------------------------------------- --
    --                               TARGET IS UNIT                                  --
    -- ----------------------------------------------------------------------------- --
    if who:getCategory() == Object.Category.UNIT then
      if who:getCoalition() == coalition.side.RED then
        local _grp = Unit.getGroup(who)
        if(contains(getCurrentOperationGroupNameBlue(), _grp:getName())) and (groupIsDead(_grp:getName())) then
          local totalNames = tablelength(getCurrentOperationGroupNameBlue())
          for i=1, totalNames do
            if isCurrentOperationMapObjBlue()[i] == false then
              if groupIsDead(getCurrentOperationGroupNameBlue()[i]) and not contains(BLUE_OPERATIONS[currentBlueTarget].Done, getCurrentOperationGroupNameBlue()[i]) then
                BLUE_OPERATIONS[currentBlueTarget].Done[tablelength(BLUE_OPERATIONS[currentBlueTarget].Done) + 1] = getCurrentOperationGroupNameBlue()[i]
              end
            end
          end
          if totalNames - tablelength(BLUE_OPERATIONS[currentBlueTarget].Done) == 0 then
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
          for i=1, totalNames do
            if isCurrentOperationMapObjRed()[i] == false then
              if groupIsDead(getCurrentOperationGroupNameRed()[i]) and not contains(RED_OPERATIONS[currentRedTarget].Done, getCurrentOperationGroupNameRed()[i]) then
                RED_OPERATIONS[currentRedTarget].Done[tablelength(RED_OPERATIONS[currentRedTarget].Done) + 1] = getCurrentOperationGroupNameRed()[i]
              end
            end
          end
          if totalNames - tablelength(RED_OPERATIONS[currentRedTarget].Done) == 0 then
            redDoneOperation(currentRedGroupTarget)
            if(tablelength(GROUPS_RED) - tablelength(GROUPS_RED_DONE) == 0) then -- RED WON
              trigger.action.outText(redWinMsg, msgTimer)
            else
              activateNextTargetRed()
            end
          end
        end
      end
    -- ----------------------------------------------------------------------------- --
    --                               TARGET IS MAP OBJECT                            --
    -- ----------------------------------------------------------------------------- --
    elseif who:getCategory() == Object.Category.SCENERY then
      if contains(BLUE_OPERATIONS[currentBlueTarget].isMapObj, true) then
        local totalNames = tablelength(getCurrentOperationGroupNameBlue())
        for i=1, totalNames do
          if BLUE_OPERATIONS[currentBlueTarget].isMapObj[i] == true then
            if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameBlue()[i]})) > 0 and not contains(BLUE_OPERATIONS[currentBlueTarget].Done, getCurrentOperationGroupNameBlue()[i]) then
              BLUE_OPERATIONS[currentBlueTarget].Done[tablelength(BLUE_OPERATIONS[currentBlueTarget].Done) + 1] = getCurrentOperationGroupNameBlue()[i]
            end
          end
        end
        if totalNames - tablelength(BLUE_OPERATIONS[currentBlueTarget].Done) == 0 then
          blueDoneOperation(currentBlueGroupTarget)
          if(tablelength(GROUPS_BLUE) - tablelength(GROUPS_BLUE_DONE) == 0) then -- BLUE WON
            trigger.action.outText(blueWinMsg, msgTimer)
          else
            activateNextTargetBlue()
          end
        end
      end
      if contains(RED_OPERATIONS[currentRedTarget].isMapObj, true) then
        local totalNames = tablelength(getCurrentOperationGroupNameRed())
        for i=1, totalNames do
          if RED_OPERATIONS[currentRedTarget].isMapObj[i] == true then
            if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameRed()[i]})) > 0 and not contains(RED_OPERATIONS[currentRedTarget].Done, getCurrentOperationGroupNameRed()[i]) then
              RED_OPERATIONS[currentRedTarget].Done[tablelength(RED_OPERATIONS[currentRedTarget].Done) + 1] = getCurrentOperationGroupNameRed()[i]
            end
          end
        end
        if totalNames - tablelength(RED_OPERATIONS[currentRedTarget].Done) == 0 then
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
  trigger.action.outText('###  TEAM SCORES  ###  Created by =GR= Theodossis for LoG' , printScoreFor)
  trigger.action.outText('POINTS:  BLUELAND TEAM: ' .. totalPointsForBlue .. '  / REDLAND TEAM: ' .. totalPointsForRed, printScoreFor)
  trigger.action.outText('BLUE TEAM CASUALTIES: A/C:' .. blueACCasualties .. ' HELO: ' .. blueHeliCasualties .. ' SHIPS: ' .. blueShipCasualties .. ' GROUND UNITS: ' .. blueGroundUnitCasualties .. ' \nPOINTS FROM OPERATIONS: '.. bluePoints, printScoreFor)  
  trigger.action.outText('RED TEAM CASUALTIES: A/C:' .. redACCasualties .. ' HELO: ' .. redHeliCasualties .. ' SHIPS: ' .. redShipCasualties .. ' GROUND UNITS: ' .. redGroundUnitCasualties .. ' \nPOINTS FROM OPERATIONS: '.. redPoints, printScoreFor)  
end

mist.scheduleFunction(printPoints, nil, timer.getTime() + 10, printScoreEvery)

-- -----------------------------MISSION RESCUER-----------------------------------------
-- Sometimes map objs get destroyed but don't call Unit dead event.
-- Happens mostly when a lot of bombs are dropped around the map object, reducing its life
-- That causes problems, while next target is not activated
-- The next part of code checks every 3 mins for destroyed targets like that
function missionRescue()
  if contains(BLUE_OPERATIONS[currentBlueTarget].isMapObj, true) then
    local totalNames = tablelength(getCurrentOperationGroupNameBlue())
    for i=1, totalNames do
      if BLUE_OPERATIONS[currentBlueTarget].isMapObj[i] == true then
        if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameBlue()[i]})) > 0 and not contains(BLUE_OPERATIONS[currentBlueTarget].Done, getCurrentOperationGroupNameBlue()[i]) then
          BLUE_OPERATIONS[currentBlueTarget].Done[tablelength(BLUE_OPERATIONS[currentBlueTarget].Done) + 1] = getCurrentOperationGroupNameBlue()[i]
        end
      end
    end
    if totalNames - tablelength(BLUE_OPERATIONS[currentBlueTarget].Done) == 0 then
      blueDoneOperation(currentBlueGroupTarget)
      if(tablelength(GROUPS_BLUE) - tablelength(GROUPS_BLUE_DONE) == 0) then -- BLUE WON
        trigger.action.outText(blueWinMsg, msgTimer)
      else
        activateNextTargetBlue()
      end
    end
  end
  if contains(RED_OPERATIONS[currentRedTarget].isMapObj, true) then
    local totalNames = tablelength(getCurrentOperationGroupNameRed())
    for i=1, totalNames do
      if RED_OPERATIONS[currentRedTarget].isMapObj[i] == true then
        if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameRed()[i]})) > 0 and not contains(RED_OPERATIONS[currentRedTarget].Done, getCurrentOperationGroupNameRed()[i]) then
          RED_OPERATIONS[currentRedTarget].Done[tablelength(RED_OPERATIONS[currentRedTarget].Done) + 1] = getCurrentOperationGroupNameRed()[i]
        end
      end
    end
    if totalNames - tablelength(RED_OPERATIONS[currentRedTarget].Done) == 0 then
      redDoneOperation(currentRedGroupTarget)
      if(tablelength(GROUPS_RED) - tablelength(GROUPS_RED_DONE) == 0) then -- RED WON
        trigger.action.outText(redWinMsg, msgTimer)
      else
        activateNextTargetRed()
      end
    end
  end
end
mist.scheduleFunction(missionRescue, nil, timer.getTime() + 10, 180)

missionCommands.addCommandForCoalition(coalition.side.BLUE, 'Target report', nil, printDataBlue, nil)
missionCommands.addCommandForCoalition(coalition.side.RED, 'Target report', nil, printDataRed, nil)

activateNextTargetBlue()
activateNextTargetRed()