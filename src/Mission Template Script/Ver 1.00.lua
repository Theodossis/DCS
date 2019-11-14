--[[
    Template PvP Mission Script - Version: 1.00 - 09/11/2019 by Theodossis Papadopoulos 
       ]]

-- ************************************************************************
-- *********************  USER CONFIGURATION ******************************
-- ************************************************************************

totalOperations = 2 -- Groups size ???????or Number of Target Groups????????
GROUPS_BLUE = {{1, 2}, {3, 4}} -- For a given example of GROUPS_BLUE = {{1, 5}, {6, 8}, {9, 15}},the 1BLUE mission is consisted of three targets. The 1st target will be randomly choosen among the first target's Group, in specific five tragets, BLUE_OPERATIONS[1] up to [5], the 2nd target will be choosen among a Group of three targets, in specific BLUE_OPERATIONS[6] up to [8] and the 3rd target among a group of seven targets, BLUE_OPERATIONS[9] up to [15].
GROUPS_RED = {{1, 2}, {3, 4}}  -- Both GROUPS_BLUE and GROUPS_RED must have the same number of target groups e.g GROUPS_BLUE = {{1, 4}, {5, 6}, {7, 10}} and GROUPS_RED = {{1, 1}, {3, 8}, {9, 15}}. If we wish to define a specific target for a Group of targets we have to write is as it can be seen in 1st GROUPS_RED {1,1}. 
randomGroups = false       -- If the randomGroups variable is set to false then the aforementioned procedure will be executed starting from the left to the right, otherwise if is set to false the groups will be choosen randomly.  
msgTimer = 60          -- We specify the time that the target's asignment message will remain visible. The current target's message can be always recall via the F10 menu by selecting Target Report option. 
blueWinMsg = 'BLUE WON'        -- Here we can Specify the Blue and Red Win messages.
redWinMsg = 'RED WON'

-- ------------------INIT VARIABLES (DO NOT MODIFY) ----------------------
BLUE_OPERATIONS = {}
RED_OPERATIONS = {}

GROUPS_BLUE_DONE = {}
GROUPS_RED_DONE = {}

-- ************************************************************************
-- ************************** TARGET SETUP ********************************
-- ************************************************************************

-- Each Target should be setup as follows:

function setupMissions()   

  -- ************************** BLUE TARGET LIST **************************
  
    BLUE_OPERATIONS[1] = {       -- It's the 1st BLUE Target.
    Name = 'BT_1',               -- Here we specify the exact name of the Group to be destroyed. This group can be consisted of more than one ground Units or Ships.
    isMapObj = false,      -- Here we specify if the current target is a Map Object. If true the relevant trigger zone or polygon must be named as e.g BT_1.
    showMark = false,
    Briefing = "BLUE TARGET 1",  -- Here we specify the target's briefing e.g Briefing = "1st Objective: Destroy 4 MBT M1A2 ABRAMS units guarding a small village (BR51) N27 15.38' E054 34.10', 1486 feet. Expected AD medium.", 
    Extras = {},     -- In the Extra Brackets we can specify extra groups, such as Ground Based Air Defense 'AD' or Decoration Groups 'DEC', that we wished to be late activated with the target. The name of the Groups in mission must match with the names in the extra's brackets. In case we don't wish to have extra groups we leave the bracket blank e.g Extras = {}. 
    Points = 2
  }
  BLUE_OPERATIONS[2] = {
    Name = 'BT_2',
    isMapObj = true,
    showMark = false,
    Briefing = "BLUE TARGET 2",
    Extras = {'BT_2_AD', 'BT_2_DEC'},
    Points = 2
  }
  BLUE_OPERATIONS[3] = {
    Name = 'BT_3',
    isMapObj = false,
    showMark = true,
    Briefing = "BLUE TARGET 3",
    Extras = {},
    Points = 2
  }
  BLUE_OPERATIONS[4] = {
    Name = 'BT_4',
    isMapObj = false,
    showMark = true,
    Briefing = "BLUE TARGET 4",
    Extras = {},
    Points = 2
  }
  
  -- ************************** RED TARGET LIST **************************
  
  RED_OPERATIONS[1] = {
    Name = 'RT_1',
    isMapObj = false,
    showMark = true,
    Briefing = "RED TARGET 1",
    Extras = {},
    Points = 2
  }
  RED_OPERATIONS[2] = {
    Name = 'RT_2',
    isMapObj = false,
    showMark = true,
    Briefing = "RED TARGET 2",
    Extras = {},
    Points = 2
  }
  RED_OPERATIONS[3] = {
    Name = 'RT_3',
    isMapObj = false,
    showMark = true,
    Briefing = "RED TARGET 3",
    Extras = {},
    Points = 2
  }
  RED_OPERATIONS[4] = {
    Name = 'RT_4',
    isMapObj = false,
    showMark = true,
    Briefing = "RED TARGET 4",
    Extras = {},
    Points = 2
  }
end

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
currentBlueTarget = 1      -- It shows the Blue Team's current target's number 
currentBlueGroupTarget = 0 -- It shows the Blue Team's current groups's number
bluePoints = 0
markCounterBlue = 0

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

function printPointsBlue()
  trigger.action.outTextForCoalition(coalition.side.BLUE, 'Current blue points: ' .. bluePoints, 10)
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
  local _grpName = getCurrentOperationGroupNameBlue()
  if isCurrentOperationMapObjBlue() == false then
    Group.getByName(_grpName):activate()
    if BLUE_OPERATIONS[currentBlueTarget].showMark == true then
      trigger.action.markToCoalition(markCounterBlue, "---OBJECTIVE---", Group.getByName(_grpName):getUnit(1):getPosition().p, coalition.side.BLUE, true)
    end
  elseif isCurrentOperationMapObjBlue() == true then
    if BLUE_OPERATIONS[currentBlueTarget].showMark == true then
      trigger.action.markToCoalition(markCounterBlue, "---OBJECTIVE---", trigger.misc.getZone(getCurrentOperationGroupNameBlue()).point, coalition.side.BLUE, true)
    end
  end
  for i=1, tablelength(getCurrentOperationExtrasBlue()) do
    Group.getByName(getCurrentOperationExtrasBlue()[i]):activate()
  end
  printDataBlue()
end
-- ------------------ RED METHODS (DO NOT MODIFY) -------------------------------
currentRedTarget = 1      -- It shows the Red Team's current target's number 
currentRedGroupTarget = 0 -- It shows the Blue Team's current group's number
redPoints = 0
markCounterRed = 1000

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

function printPointsRed()
  trigger.action.outTextForCoalition(coalition.side.RED, 'Current red points: ' .. redPoints, 10)
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
  local _grpName = getCurrentOperationGroupNameRed()
  if isCurrentOperationMapObjRed() == false then
    Group.getByName(_grpName):activate()
    if RED_OPERATIONS[currentRedTarget].showMark == true then
      trigger.action.markToCoalition(markCounterRed, "---OBJECTIVE---", Group.getByName(_grpName):getUnit(1):getPosition().p, coalition.side.RED, true)
    end
  elseif isCurrentOperationMapObjRed() == true then
    if RED_OPERATIONS[currentRedTarget].showMark == true then
      trigger.action.markToCoalition(markCounterRed, "---OBJECTIVE---", trigger.misc.getZone(getCurrentOperationGroupNameRed()).point, coalition.side.RED, true)
    end
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
  local isDone = false;
  if(event.id == world.event.S_EVENT_DEAD) then
    if isCurrentOperationMapObjBlue() == false and isDone == false then
      local _grp = Unit.getGroup(event.initiator)
      if(_grp:getName() == getCurrentOperationGroupNameBlue()) and (groupIsDead(getCurrentOperationGroupNameBlue())) then
        blueDoneOperation(currentBlueGroupTarget)
        if(totalOperations - tablelength(GROUPS_BLUE_DONE) == 0) then -- BLUE WON
          trigger.action.outText(blueWinMsg, msgTimer)
        else
          activateNextTargetBlue()
        end
        isDone = true;
      end 
    elseif isCurrentOperationMapObjBlue() == true and isDone == false then
      if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameBlue()})) > 0 then
        blueDoneOperation(currentBlueGroupTarget)
        if(totalOperations - tablelength(GROUPS_BLUE_DONE) == 0) then -- BLUE WON
          trigger.action.outText(blueWinMsg, msgTimer)
        else
          activateNextTargetBlue()
        end
        isDone = true;
      end
    end
    if isCurrentOperationMapObjRed() == false and isDone == false then
      local _grp = Unit.getGroup(event.initiator)
      if(_grp:getName() == getCurrentOperationGroupNameRed()) and (groupIsDead(getCurrentOperationGroupNameRed())) then
        redDoneOperation(currentRedGroupTarget)
        if(totalOperations - tablelength(GROUPS_RED_DONE) == 0) then -- RED WON
          trigger.action.outText(redWinMsg, msgTimer)
        else
          activateNextTargetRed()
        end
        isDone = true;
      end 
    elseif isCurrentOperationMapObjRed() == true and isDone == false then
      if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameRed()})) > 0 then
        redDoneOperation(currentRedGroupTarget)
        if(totalOperations - tablelength(GROUPS_RED_DONE) == 0) then -- RED WON
          trigger.action.outText(redWinMsg, msgTimer)
        else
          activateNextTargetRed()
        end
        isDone = true;
      end
    end
  end
end
world.addEventHandler(GROUP_DEAD)

missionCommands.addCommandForCoalition(coalition.side.BLUE, 'Target report', nil, printDataBlue, nil)
missionCommands.addCommandForCoalition(coalition.side.BLUE, 'Show target points', nil, printPointsBlue, nil)
missionCommands.addCommandForCoalition(coalition.side.RED, 'Target report', nil, printDataRed, nil)
missionCommands.addCommandForCoalition(coalition.side.RED, 'Show target points', nil, printPointsRed, nil)

setupMissions()

activateNextTargetBlue()
activateNextTargetRed()