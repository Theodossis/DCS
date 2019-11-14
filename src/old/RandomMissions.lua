totalOperations = 4
msgTimer = 60
blueWinMsg = 'BLUE WON'
redWinMsg = 'RED WON'

-- ------------------------------------INIT VARIABLES DEN AGGIZOYME ------------------------------------
BLUE_OPERATIONS = {}
BLUE_OPERATIONS_DONE = {}
RED_OPERATIONS = {}
RED_OPERATIONS_DONE = {}

-- ------------------------------------ MISSION SETUP AGGIZOYME ------------------------------------
function setupMissions() 
  -- Format gia mesa: Group h Zone name, isMapObj True/False, Briefing
  BLUE_OPERATIONS[1] = {
    Name = 'BT_1',
    isMapObj = false,
    Briefing = "BLUE TARGET 1",
    Extras = {}
  }
  BLUE_OPERATIONS[2] = {
    Name = 'BT_2',
    isMapObj = true,
    Briefing = "BLUE TARGET 2",
    Extras = {'AD', 'DEC'}
  }
  BLUE_OPERATIONS[3] = {
    Name = 'BT_3',
    isMapObj = false,
    Briefing = "BLUE TARGET 3",
    Extras = {}
  }
  BLUE_OPERATIONS[4] = {
    Name = 'BT_4',
    isMapObj = false,
    Briefing = "BLUE TARGET 4",
    Extras = {}
  }
  RED_OPERATIONS[1] = {
    Name = 'RT_1',
    isMapObj = false,
    Briefing = "RED TARGET 1",
    Extras = {}
  }
  RED_OPERATIONS[2] = {
    Name = 'RT_2',
    isMapObj = false,
    Briefing = "RED TARGET 2",
    Extras = {}
  }
  RED_OPERATIONS[3] = {
    Name = 'RT_3',
    isMapObj = false,
    Briefing = "RED TARGET 3",
    Extras = {}
  }
  RED_OPERATIONS[4] = {
    Name = 'RT_4',
    isMapObj = false,
    Briefing = "RED TARGET 4",
    Extras = {}
  }
end

-- ------------------------------------ MISC METHODS DEN AGGIZOYME ------------------------------------
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

-- ------------------------------------ BLUE METHODS DEN AGGIZOYME------------------------------------
currentBlueTarget = 1 -- AKERAIOS POY DIXNEI PIO TARGET EXEI TORA H BLUE OMADA

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
  BLUE_OPERATIONS_DONE[tablelength(BLUE_OPERATIONS_DONE) + 1] = id
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
  local _random = math.random(1, tablelength(BLUE_OPERATIONS))
  while(contains(BLUE_OPERATIONS_DONE, _random)) do
    _random = math.random(1, tablelength(BLUE_OPERATIONS))
  end
  currentBlueTarget = _random
  local _grpName = getCurrentOperationGroupNameBlue()
  if isCurrentOperationMapObjBlue() == false then
    Group.getByName(_grpName):activate()
  end
  for i=1, tablelength(getCurrentOperationExtrasBlue()) do
    Group.getByName(_grpName .. "_" .. getCurrentOperationExtrasBlue()[i]):activate()
  end
  printDataBlue()
end
-- ------------------------------------ RED METHODS DEN AGGIZOYME ------------------------------------
currentRedTarget = 1 -- AKERAIOS POY DIXNEI PIO TARGET EXEI TORA H RED OMADA

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

function redDoneOperation(id)
  RED_OPERATIONS_DONE[tablelength(RED_OPERATIONS_DONE) + 1] = id
end

function getCurrentOperationExtrasRed()
  return RED_OPERATIONS[currentRedTarget].Extras
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
  local _random = math.random(1, tablelength(RED_OPERATIONS) - 1)
  while(contains(RED_OPERATIONS_DONE, _random)) do
    _random = math.random(1, tablelength(RED_OPERATIONS))
  end
  currentRedTarget = _random
  local _grpName = getCurrentOperationGroupNameRed()
  if isCurrentOperationMapObjRed() == false then
    Group.getByName(_grpName):activate()
  end
  for i=1, tablelength(getCurrentOperationExtrasRed()) do
    Group.getByName(_grpName .. "_" .. getCurrentOperationExtrasRed()[i]):activate()
  end
  printDataRed()
end
-- ------------------------------------KODIKAS DEN AGGIZOYME ------------------------------------
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
    if isCurrentOperationMapObjBlue() == false then
      local _grp = Unit.getGroup(event.initiator)
      if(_grp:getName() == getCurrentOperationGroupNameBlue()) and (groupIsDead(getCurrentOperationGroupNameBlue())) then
        blueDoneOperation(currentBlueTarget)
        if(totalOperations - tablelength(BLUE_OPERATIONS_DONE) == 0) then -- BLUE WON
          trigger.action.outText(blueWinMsg, msgTimer)
        else
          activateNextTargetBlue()
        end
        isDone = true;
      end 
    else
      if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameBlue()})) > 0 then
        blueDoneOperation(currentBlueTarget)
        if(totalOperations - tablelength(BLUE_OPERATIONS_DONE) == 0) then -- BLUE WON
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
        redDoneOperation(currentRedTarget)
        if(totalOperations - tablelength(RED_OPERATIONS_DONE) == 0) then -- RED WON
          trigger.action.outText(redWinMsg, msgTimer)
        else
          activateNextTargetRed()
        end
        isDone = true;
      end
    else
      if tablelength(mist.getDeadMapObjsInZones({getCurrentOperationGroupNameRed()})) > 0 then
        redDoneOperation(currentBlueTarget)
        if(totalOperations - tablelength(RED_OPERATIONS_DONE) == 0) then -- RED WON
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
missionCommands.addCommandForCoalition(coalition.side.RED, 'Target report', nil, printDataRed, nil)

setupMissions()

activateNextTargetBlue()
activateNextTargetRed()