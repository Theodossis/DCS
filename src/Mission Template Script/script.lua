--[[
    Template PvP Mission Script - Version: 1.11 - 19/11/2019 by Theodossis Papadopoulos 
       ]]
local BLUE_OPERATIONS = _G["BLUE_OPERATIONS"]
local GROUPS_BLUE = _G["GROUPS_BLUE"]
local RED_OPERATIONS = _G["RED_OPERATIONS"]
local GROUPS_RED = _G["GROUPS_RED"]
local randomGroups = _G["randomGroups"]

local msgTimer = _G["msgTimer"]
local blueWinMsg = _G["blueWinMsg"]
local redWinMsg = _G["redWinMsg"]

local aircraftPoints = _G["aircraftPoints"]
local aircraftCost = _G["aircraftCost"]
local heliPoints = _G["heliPoints"]
local heliCost = _G["heliCost"]
local shipPoints = _G["shipPoints"]
local unitPoints = _G["unitPoints"]
local printScoreFor = _G["printScoreFor"]

local missionLength = _G["missionLength"]

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
local currentBlueTarget = {}
local currentBlueGroupTarget = {}
local bluePoints = 0
local blueACCasualties = 0
local blueHeliCasualties = 0
local blueShipCasualties = 0
local blueGroundUnitCasualties = 0
local markCounterBlue = 1000
local markUsingBlue = {}

function getCurrentOperationGroupNameBlue(i)
  return BLUE_OPERATIONS[currentBlueTarget[i]].Name
end

function isCurrentOperationMapObjBlue(i)
  return BLUE_OPERATIONS[currentBlueTarget[i]].isMapObj
end

function getCurrentOperationBriefingBlue(i)
  return BLUE_OPERATIONS[currentBlueTarget[i]].Briefing
end

function getCurrentOperationExtrasBlue(i)
  return BLUE_OPERATIONS[currentBlueTarget[i]].Extras
end

function blueDoneOperation(id)
  bluePoints = bluePoints + BLUE_OPERATIONS[currentBlueTarget[id]].Points
  for i=1, tablelength(markUsingBlue) do
    trigger.action.removeMark(markUsingBlue[i])
  end
  GROUPS_BLUE_DONE[tablelength(GROUPS_BLUE_DONE) + 1] = currentBlueGroupTarget[id]
  table.remove(currentBlueTarget, id)
  table.remove(currentBlueGroupTarget, id)
end

function printDataBlue(lastOnly) -- lastOnly boolean that only shows the last activated group briefing
  if lastOnly == false then
    local finalStr = "Target Report: \n"
    for i=1, tablelength(currentBlueTarget) do
      finalStr = finalStr .. currentBlueGroupTarget[i] .. "#: " .. getCurrentOperationBriefingBlue(i) .. "\n"
    end
    trigger.action.outTextForCoalition(coalition.side.BLUE, finalStr, msgTimer)
  else
    trigger.action.outTextForCoalition(coalition.side.BLUE, 'Target Report: \n' .. getCurrentOperationBriefingBlue(tablelength(currentBlueTarget)), msgTimer)
  end
end

function soundBlueThatIsOurTarget()
  trigger.action.outSoundForCoalition(coalition.side.BLUE, "That Is Our Target.ogg")
end

function activateMoreBlue(showMsg)
  if tablelength(GROUPS_BLUE) - (tablelength(GROUPS_BLUE_DONE) + tablelength(currentBlueGroupTarget)) == 0 then
    if showMsg == true then
      trigger.action.outTextForCoalition(coalition.side.BLUE, "There are not any more targets left to activate! Destroy the remaining targets to win!", 15)
    end
  else
    activateNextTargetBlue()
  end
end

function activateNextTargetBlue()
  trigger.action.outSoundForCoalition(coalition.side.BLUE, 'tele.ogg')
  timer.scheduleFunction(soundBlueThatIsOurTarget, nil, timer.getTime() + 6)
  local latestGroup = 1
  if randomGroups == true then
    local _random = math.random(1, tablelength(GROUPS_BLUE))
    while(contains(GROUPS_BLUE_DONE, _random) or contains(currentBlueGroupTarget, _random)) do
      _random = math.random(1, tablelength(GROUPS_BLUE))
    end
    currentBlueGroupTarget[tablelength(currentBlueGroupTarget) + 1] = _random
    latestGroup = _random
  else
    while(contains(GROUPS_BLUE_DONE, latestGroup) or contains(currentBlueGroupTarget, latestGroup)) do -- METRAEI KATA SEIRA, AFOY EINAI SEIRIAKO, VRISKEI I TETOIO OSTE NA MHN EXEI PAIKSEI (I GROUP)
      latestGroup = latestGroup + 1
    end
    currentBlueGroupTarget[tablelength(currentBlueGroupTarget) + 1] = latestGroup
  end
  local _randomTarget = math.random(GROUPS_BLUE[latestGroup][1], GROUPS_BLUE[latestGroup][2])
  currentBlueTarget[tablelength(currentBlueTarget) + 1] = _randomTarget
  local latestTarget = tablelength(currentBlueTarget)
  local _grpNames = getCurrentOperationGroupNameBlue(latestTarget)
  for i=1, tablelength(_grpNames) do
    if isCurrentOperationMapObjBlue(latestTarget)[i] == false then
      Group.getByName(_grpNames[i]):activate()
      if BLUE_OPERATIONS[_randomTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterBlue, "---OBJECTIVE---", Group.getByName(_grpNames[i]):getUnit(1):getPosition().p, coalition.side.BLUE, true)
        markUsingBlue[tablelength(markUsingBlue) + 1] = markCounterBlue
        markCounterBlue = markCounterBlue + 1
      end
    elseif isCurrentOperationMapObjBlue(latestTarget)[i] == true then
      if BLUE_OPERATIONS[_randomTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterBlue, "---OBJECTIVE---", trigger.misc.getZone(_grpNames[i]).point, coalition.side.BLUE, true)
        markUsingBlue[tablelength(markUsingBlue) + 1] = markCounterBlue
        markCounterBlue = markCounterBlue + 1
      end
    elseif isCurrentOperationMapObjBlue(latestTarget)[i] == "polygon" then
      if BLUE_OPERATIONS[_randomTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterBlue, "---OBJECTIVE---", Group.getByName(_grpNames[i]):getUnit(1):getPosition().p, coalition.side.BLUE, true)
        markUsingBlue[tablelength(markUsingBlue) + 1] = markCounterBlue
        markCounterBlue = markCounterBlue + 1
      end
    end
    for i=1, tablelength(getCurrentOperationExtrasBlue(latestTarget)) do
      Group.getByName(getCurrentOperationExtrasBlue(latestTarget)[i]):activate()
    end
    BLUE_OPERATIONS[_randomTarget].Done = {}
  end
  printDataBlue(true)
end
-- ------------------ RED METHODS CODE -------------------------------
local currentRedTarget = {}
local currentRedGroupTarget = {}
local redPoints = 0
local redACCasualties = 0
local redHeliCasualties = 0
local redShipCasualties = 0
local redGroundUnitCasualties = 0
local markCounterRed = 2000
local markUsingRed = {}

function getCurrentOperationGroupNameRed(i)
  return RED_OPERATIONS[currentRedTarget[i]].Name
end

function isCurrentOperationMapObjRed(i)
  return RED_OPERATIONS[currentRedTarget[i]].isMapObj
end

function getCurrentOperationBriefingRed(i)
  return RED_OPERATIONS[currentRedTarget[i]].Briefing
end

function getCurrentOperationExtrasRed(i)
  return RED_OPERATIONS[currentRedTarget[i]].Extras
end

function redDoneOperation(id)
  redPoints = redPoints + RED_OPERATIONS[currentRedTarget[id]].Points
  for i=1, tablelength(markUsingRed) do
    trigger.action.removeMark(markUsingRed[i])
  end
  GROUPS_RED_DONE[tablelength(GROUPS_RED_DONE) + 1] = currentRedGroupTarget[id]
  table.remove(currentRedTarget, id)
  table.remove(currentRedGroupTarget, id)
end

function printDataRed(lastOnly) -- lastOnly boolean that only shows the last activated group briefing
  if lastOnly == false then
    local finalStr = "Target Report: \n"
    for i=1, tablelength(currentRedTarget) do
      finalStr = finalStr .. currentRedGroupTarget[i] .. "#: " .. getCurrentOperationBriefingRed(i) .. "\n"
    end
    trigger.action.outTextForCoalition(coalition.side.RED, finalStr, msgTimer)
  else
    trigger.action.outTextForCoalition(coalition.side.RED, 'Target Report: \n' .. getCurrentOperationBriefingRed(tablelength(currentRedTarget)), msgTimer)
  end
end

function soundRedThatIsOurTarget()
  trigger.action.outSoundForCoalition(coalition.side.RED, "That Is Our Target.ogg")
end

function activateMoreRed(showMsg)
  if tablelength(GROUPS_RED) - (tablelength(GROUPS_RED_DONE) + tablelength(currentRedGroupTarget)) == 0 then
    if showMsg == true then
      trigger.action.outTextForCoalition(coalition.side.RED, "There are not any more targets left to activate! Destroy the remaining targets to win!", 15)
    end
  else
    activateNextTargetRed()
  end
end

function activateNextTargetRed()
  trigger.action.outSoundForCoalition(coalition.side.RED, 'tele.ogg')
  timer.scheduleFunction(soundRedThatIsOurTarget, nil, timer.getTime() + 6)
  local latestGroup = 1
  if randomGroups == true then
    local _random = math.random(1, tablelength(GROUPS_RED))
    while(contains(GROUPS_RED_DONE, _random) or contains(currentRedGroupTarget, _random)) do
      _random = math.random(1, tablelength(GROUPS_RED))
    end
    currentRedGroupTarget[tablelength(currentRedGroupTarget) + 1] = _random
    currentRedGroupTarget = _random
  else
    while(contains(GROUPS_RED_DONE, latestGroup) or contains(currentRedGroupTarget, latestGroup)) do -- METRAEI KATA SEIRA, AFOY EINAI SEIRIAKO, VRISKEI I TETOIO OSTE NA MHN EXEI PAIKSEI (I GROUP)
      latestGroup = latestGroup + 1
    end
    currentRedGroupTarget[tablelength(currentRedGroupTarget) + 1] = latestGroup
  end
  local _randomTarget = math.random(GROUPS_RED[latestGroup][1], GROUPS_RED[latestGroup][2])
  currentRedTarget[tablelength(currentRedTarget) + 1] = _randomTarget
  local latestTarget = tablelength(currentRedTarget)
  local _grpNames = getCurrentOperationGroupNameRed(latestTarget)
  for i=1, tablelength(_grpNames) do
    if isCurrentOperationMapObjRed(latestTarget)[i] == false then
      Group.getByName(_grpNames[i]):activate()
      if RED_OPERATIONS[_randomTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterRed, "---OBJECTIVE---", Group.getByName(_grpNames[i]):getUnit(1):getPosition().p, coalition.side.RED, true)
        markUsingRed[tablelength(markUsingRed) + 1] = markCounterRed
        markCounterRed = markCounterRed + 1
      end
    elseif isCurrentOperationMapObjRed(latestTarget)[i] == true then
      if RED_OPERATIONS[_randomTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterRed, "---OBJECTIVE---", trigger.misc.getZone(_grpNames[i]).point, coalition.side.RED, true)
        markUsingRed[tablelength(markUsingRed) + 1] = markCounterRed
        markCounterRed = markCounterRed + 1
      end
    elseif isCurrentOperationMapObjRed(latestTarget)[i] == "polygon" then
      if RED_OPERATIONS[_randomTarget].showMark[i] == true then
        trigger.action.markToCoalition(markCounterRed, "---OBJECTIVE---", Group.getByName(_grpNames[i]):getUnit(1):getPosition().p, coalition.side.RED, true)
        markUsingRed[tablelength(markUsingRed) + 1] = markCounterRed
        markCounterRed = markCounterRed + 1
      end
    end
    for i=1, tablelength(getCurrentOperationExtrasRed(latestTarget)) do
      Group.getByName(getCurrentOperationExtrasRed(latestTarget)[i]):activate()
    end
    RED_OPERATIONS[_randomTarget].Done = {}
  end
  printDataRed(true)
end

-- -----------------------------SCORE PRINTER----------------------------------------
function printPoints()
  local totalPointsForBlue = bluePoints + redACCasualties*aircraftPoints + redHeliCasualties*heliPoints + redShipCasualties*shipPoints + redGroundUnitCasualties*unitPoints - blueACCasualties*aircraftCost - blueHeliCasualties*heliCost
  local totalPointsForRed = redPoints + blueACCasualties*aircraftPoints + blueHeliCasualties*heliPoints + blueShipCasualties*shipPoints + blueGroundUnitCasualties*unitPoints - redACCasualties*aircraftCost - redHeliCasualties*heliCost
  trigger.action.outText('###  TEAM SCORES  ###  Created by =GR= Theodossis for LoG' , printScoreFor)
  trigger.action.outText('POINTS:  BLUELAND TEAM: ' .. totalPointsForBlue .. '  / REDLAND TEAM: ' .. totalPointsForRed, printScoreFor)
  trigger.action.outText('BLUE TEAM CASUALTIES: A/C:' .. blueACCasualties .. ' HELO: ' .. blueHeliCasualties .. ' SHIPS: ' .. blueShipCasualties .. ' GROUND UNITS: ' .. blueGroundUnitCasualties .. ' \nPOINTS FROM OPERATIONS: '.. bluePoints, printScoreFor)  
  trigger.action.outText('RED TEAM CASUALTIES: A/C:' .. redACCasualties .. ' HELO: ' .. redHeliCasualties .. ' SHIPS: ' .. redShipCasualties .. ' GROUND UNITS: ' .. redGroundUnitCasualties .. ' \nPOINTS FROM OPERATIONS: '.. redPoints, printScoreFor)  
end
mist.scheduleFunction(printPoints, nil, timer.getTime() + 60*missionLength)

-- -----------------------------------MISSION ENDING COUNTER--------------------------
function fifteenMoreMinutes()
  trigger.action.outText("15 more minutes for mission end!", msgTimer)
end
mist.scheduleFunction(fifteenMoreMinutes, nil, timer.getTime() + 60*(missionLength - 15))
function oneMoreHour()
  trigger.action.outText("1 more hour for mission end!", msgTimer)
end
mist.scheduleFunction(oneMoreHour, nil, timer.getTime() + 60*(missionLength - 60))

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

function detectAndActivateNext(category, who) -- COALITION OPTIONAL, CATEGORY IS NEEDED, GROUP OPTIONAL 
  -- ----------------------------------------------------------------------------- --
  --                               TARGET IS UNIT                                  --
  -- ----------------------------------------------------------------------------- --
  if category == Object.Category.UNIT then
    if who:getCoalition() == coalition.side.RED then
      local _grp = Unit.getGroup(who)
      for counter=1, tablelength(currentBlueTarget) do
        if contains(getCurrentOperationGroupNameBlue(counter), _grp:getName()) and groupIsDead(_grp:getName()) then
          local totalNames = tablelength(getCurrentOperationGroupNameBlue(counter))
          for i=1, totalNames do
            if isCurrentOperationMapObjBlue(counter)[i] == false then
              if groupIsDead(getCurrentOperationGroupNameBlue(counter)[i]) and not contains(BLUE_OPERATIONS[currentBlueTarget[counter]].Done, getCurrentOperationGroupNameBlue(counter)[i]) then
                BLUE_OPERATIONS[currentBlueTarget[counter]].Done[tablelength(BLUE_OPERATIONS[currentBlueTarget[counter]].Done) + 1] = getCurrentOperationGroupNameBlue(counter)[i]
              end
            end
          end
          if totalNames - tablelength(BLUE_OPERATIONS[currentBlueTarget[counter]].Done) == 0 then
            trigger.action.outTextForCoalition(coalition.side.BLUE, "Target " .. currentBlueGroupTarget[counter] .. " destroyed!", msgTimer)
            blueDoneOperation(counter)
            if(tablelength(GROUPS_BLUE) - tablelength(GROUPS_BLUE_DONE) == 0) then -- BLUE WON
              trigger.action.outText(blueWinMsg, msgTimer)
              printPoints()
              break
            else
              activateMoreBlue(false)
              break
            end
          end
        end
      end
    elseif who:getCoalition() == coalition.side.BLUE then
      local _grp = Unit.getGroup(who)
      for counter=1, tablelength(currentRedTarget) do
        if(contains(getCurrentOperationGroupNameRed(counter), _grp:getName())) and (groupIsDead(_grp:getName())) then
          local totalNames = tablelength(getCurrentOperationGroupNameRed(counter))
          for i=1, totalNames do
            if isCurrentOperationMapObjRed(counter)[i] == false then
              if groupIsDead(getCurrentOperationGroupNameRed(counter)[i]) and not contains(RED_OPERATIONS[currentRedTarget[counter]].Done, getCurrentOperationGroupNameRed(counter)[i]) then
                RED_OPERATIONS[currentRedTarget[counter]].Done[tablelength(RED_OPERATIONS[currentRedTarget[counter]].Done) + 1] = getCurrentOperationGroupNameRed(counter)[i]
              end
            end
          end
          if totalNames - tablelength(RED_OPERATIONS[currentRedTarget[counter]].Done) == 0 then
            trigger.action.outTextForCoalition(coalition.side.RED, "Target " .. currentRedGroupTarget[counter] .. " destroyed!", msgTimer)
            redDoneOperation(counter)
            if(tablelength(GROUPS_RED) - tablelength(GROUPS_RED_DONE) == 0) then -- RED WON
              trigger.action.outText(redWinMsg, msgTimer)
              printPoints()
              break
            else
              activateMoreRed(false)
              break
            end
          end
        end
      end
    end
  -- ----------------------------------------------------------------------------- --
  --                               TARGET IS MAP OBJECT                            --
  -- ----------------------------------------------------------------------------- --
  elseif category == Object.Category.SCENERY then
    for counter=1, tablelength(currentBlueTarget) do -- CHECK FOR BLUE
      if contains(BLUE_OPERATIONS[currentBlueTarget[counter]].isMapObj, true) then
        local totalNames = tablelength(getCurrentOperationGroupNameBlue(counter))
        for i=1, totalNames do
          if BLUE_OPERATIONS[currentBlueTarget[counter]].isMapObj[i] == true then
            if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameBlue(counter)[i]})) > 0 and not contains(BLUE_OPERATIONS[currentBlueTarget[counter]].Done, getCurrentOperationGroupNameBlue(counter)[i]) then
              BLUE_OPERATIONS[currentBlueTarget[counter]].Done[tablelength(BLUE_OPERATIONS[currentBlueTarget[counter]].Done) + 1] = getCurrentOperationGroupNameBlue(counter)[i]
            end
          end
        end
        if totalNames - tablelength(BLUE_OPERATIONS[currentBlueTarget[counter]].Done) == 0 then
          trigger.action.outTextForCoalition(coalition.side.BLUE, "Target " .. currentBlueGroupTarget[counter] .. " destroyed!", msgTimer)
          blueDoneOperation(counter)
          if(tablelength(GROUPS_BLUE) - tablelength(GROUPS_BLUE_DONE) == 0) then -- BLUE WON
            trigger.action.outText(blueWinMsg, msgTimer)
            printPoints()
            break
          else
            activateMoreBlue(false)
            break
          end
        end
      elseif contains(BLUE_OPERATIONS[currentBlueTarget[counter]].isMapObj, "polygon") then
        local totalNames = tablelength(getCurrentOperationGroupNameBlue(counter))
        for i=1, totalNames do
          if BLUE_OPERATIONS[currentBlueTarget[counter]].isMapObj[i] == "polygon" then
            if tablelength(mist.getDeadMapObjsInPolygonZone(mist.getGroupPoints(getCurrentOperationGroupNameBlue(counter)[i]))) > 0 and not contains(BLUE_OPERATIONS[currentBlueTarget[counter]].Done, getCurrentOperationGroupNameBlue(counter)[i]) then
              BLUE_OPERATIONS[currentBlueTarget[counter]].Done[tablelength(BLUE_OPERATIONS[currentBlueTarget[counter]].Done) + 1] = getCurrentOperationGroupNameBlue(counter)[i]
            end
          end
        end
        if totalNames - tablelength(BLUE_OPERATIONS[currentBlueTarget[counter]].Done) == 0 then
          trigger.action.outTextForCoalition(coalition.side.BLUE, "Target " .. currentBlueGroupTarget[counter] .. " destroyed!", msgTimer)
          blueDoneOperation(counter)
          if(tablelength(GROUPS_BLUE) - tablelength(GROUPS_BLUE_DONE) == 0) then -- BLUE WON
            trigger.action.outText(blueWinMsg, msgTimer)
            printPoints()
            break
          else
            activateMoreBlue(false)
            break
          end
        end
      end
    end
    for counter=1, tablelength(currentRedTarget) do -- CHECK FOR RED
      if contains(RED_OPERATIONS[currentRedTarget[counter]].isMapObj, true) then
        local totalNames = tablelength(getCurrentOperationGroupNameRed(counter))
        for i=1, totalNames do
          if RED_OPERATIONS[currentRedTarget[counter]].isMapObj[i] == true then
            if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameRed(counter)[i]})) > 0 and not contains(RED_OPERATIONS[currentRedTarget[counter]].Done, getCurrentOperationGroupNameRed(counter)[i]) then
              RED_OPERATIONS[currentRedTarget[counter]].Done[tablelength(RED_OPERATIONS[currentRedTarget[counter]].Done) + 1] = getCurrentOperationGroupNameRed(counter)[i]
            end
          end
        end
        if totalNames - tablelength(RED_OPERATIONS[currentRedTarget[counter]].Done) == 0 then
          trigger.action.outTextForCoalition(coalition.side.RED, "Target " .. currentRedGroupTarget[counter] .. " destroyed!", msgTimer)
          redDoneOperation(counter)
          if(tablelength(GROUPS_RED) - tablelength(GROUPS_RED_DONE) == 0) then -- RED WON
            trigger.action.outText(redWinMsg, msgTimer)
            printPoints()
            break
          else
            activateMoreRed(false)
            break
          end
        end
      elseif contains(RED_OPERATIONS[currentRedTarget[counter]].isMapObj, "polygon") then
        local totalNames = tablelength(getCurrentOperationGroupNameRed(counter))
        for i=1, totalNames do
          if RED_OPERATIONS[currentRedTarget[counter]].isMapObj[i] == "polygon" then
            if tablelength(mist.getDeadMapObjsInPolygonZone(mist.getGroupPoints(getCurrentOperationGroupNameRed(counter)[i]))) > 0 and not contains(RED_OPERATIONS[currentRedTarget[counter]].Done, getCurrentOperationGroupNameRed(counter)[i]) then
              RED_OPERATIONS[currentRedTarget[counter]].Done[tablelength(RED_OPERATIONS[currentRedTarget[counter]].Done) + 1] = getCurrentOperationGroupNameRed(counter)[i]
            end
          end
        end
        if totalNames - tablelength(RED_OPERATIONS[currentRedTarget[counter]].Done) == 0 then
          trigger.action.outTextForCoalition(coalition.side.RED, "Target " .. currentRedGroupTarget[counter] .. " destroyed!", msgTimer)
          redDoneOperation(counter)
          if(tablelength(GROUPS_RED) - tablelength(GROUPS_RED_DONE) == 0) then -- RED WON
            trigger.action.outText(redWinMsg, msgTimer)
            printPoints()
            break
          else
            activateMoreRed(false)
            break
          end
        end
      end
    end
  end
end

GROUP_DEAD = {}
function GROUP_DEAD:onEvent(event)
  if(event.id == world.event.S_EVENT_DEAD) then
    local who = event.initiator
    detectAndActivateNext(who:getCategory(), who)
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

-- -----------------------------MISSION RESCUER-----------------------------------------
-- Sometimes map objs get destroyed but don't call Unit dead event.
-- Happens mostly when a lot of bombs are dropped around the map object, reducing its life
-- That causes problems, while next target is not activated
-- The next part of code checks every 1.5 mins for destroyed targets like that
function missionRescue()
  detectAndActivateNext(Object.Category.SCENERY, nil)
end
mist.scheduleFunction(missionRescue, nil, timer.getTime() + 10, 90)
-- --------------------------------------------------------------------------------------

missionCommands.addCommandForCoalition(coalition.side.BLUE, 'Target report', nil, printDataBlue, false)
missionCommands.addCommandForCoalition(coalition.side.BLUE, 'Activate another target', nil, activateMoreBlue, true)
missionCommands.addCommandForCoalition(coalition.side.RED, 'Target report', nil, printDataRed, false)
missionCommands.addCommandForCoalition(coalition.side.RED, 'Activate another target', nil, activateMoreRed, true)

activateNextTargetBlue()
activateNextTargetRed()