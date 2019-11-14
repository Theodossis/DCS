maxTargets = 3

TARGET_1B_RANDOMVALUES = 1
TARGET_1B_1_TEXT = "TO 1 1"
TARGET_1B_1_isMapObj = "ZONE 10"
TARGET_2B_RANDOMVALUES = 3
TARGET_2B_1_TEXT = "TO 2 1"
TARGET_2B_2_TEXT = "TO 2 2"
TARGET_2B_3_TEXT = "TO 2 3"
TARGET_3B_RANDOMVALUES = 2
TARGET_3B_1_TEXT = "TO 3 1"
TARGET_3B_2_TEXT = "TO 3 2"

TARGET_1R_RANDOMVALUES = 1
TARGET_1R_1_TEXT = "TO 1 1"
TARGET_1R_1_isMapObj = "ZONE 20"
TARGET_2R_RANDOMVALUES = 4
TARGET_2R_1_TEXT = "TO 2 1"
TARGET_2R_2_TEXT = "TO 2 2"
TARGET_2R_3_TEXT = "TO 2 3"
TARGET_2R_4_TEXT = "TO 2 4"
TARGET_3R_RANDOMVALUES = 1
TARGET_3R_1_TEXT = "TO 3 1"

counterBlue = 1
currentBlueTarget = ''
counterRed = 1
currentRedTarget = ''

function printDataBlue()
  trigger.action.outTextForCoalition(coalition.side.BLUE, 'Target Report: \n' .. _G[currentBlueTarget .. "_TEXT"], 80)
end

function printDataRed()
  trigger.action.outTextForCoalition(coalition.side.RED, 'Target Report: \n' .. _G[currentRedTarget .. "_TEXT"], 80)
end

GROUP_DEAD = {}

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

function activateNextTargetBlue()
  random = math.random(1, _G['TARGET_' .. counterBlue .. 'B_RANDOMVALUES'])
  local _grpNext = 'TARGET_' .. counterBlue .. 'B_' .. random
  if(_G[_grpNext .. '_isMapObj'] == nil) then
    Group.getByName(_grpNext):activate()
  end
  currentBlueTarget = _grpNext
  printDataBlue()
end

function activateNextTargetRed()
  random = math.random(1, _G['TARGET_' .. counterRed .. 'R_RANDOMVALUES'])
  local _grpNext = 'TARGET_' .. counterRed .. 'R_' .. random
  if(_G[_grpNext .. '_isMapObj'] == nil) then
    Group.getByName(_grpNext):activate()
  end
  currentRedTarget = _grpNext
  printDataRed()
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function GROUP_DEAD:onEvent(event)
  if(event.id == world.event.S_EVENT_DEAD) then
    if (_G[currentBlueTarget .. '_isMapObj'] == nil) then -- IS BLUE MAP OBJ?
      local _grp = Unit.getGroup(event.initiator)
      if _grp:getName() == currentBlueTarget and groupIsDead(currentBlueTarget) then
        counterBlue = counterBlue + 1
        if counterBlue <= maxTargets then
          activateNextTargetBlue()
        else
          trigger.action.outText('BLUE WON', 50)
        end
      end
    else -- ITS FOR SURE BLUE MAP OBJ
      if tablelength(mist.getDeadMapObjsInZones({_G[currentBlueTarget .. '_isMapObj']})) > 0 then 
        counterBlue = counterBlue + 1
        activateNextTargetBlue()      
      end
    end
    if (_G[currentRedTarget .. '_isMapObj'] == nil) then -- IS RED MAP OBJ?
      local _grp = Unit.getGroup(event.initiator)
      if _grp:getName() == currentRedTarget and groupIsDead(currentRedTarget) then
        counterRed = counterRed + 1
        if counterRed <= maxTargets then
          activateNextTargetRed()
        else
          trigger.action.outText('RED WON', 50)
        end
      end
    else -- ITS FOR SURE RED MAP OBJ
      if tablelength(mist.getDeadMapObjsInZones({_G[currentRedTarget .. '_isMapObj']})) > 0 then 
        counterRed = counterRed + 1
        activateNextTargetRed()      
      end
    end
  end
end

world.addEventHandler(GROUP_DEAD)

missionCommands.addCommandForCoalition(coalition.side.BLUE, 'Target report', nil, printDataBlue, nil)
missionCommands.addCommandForCoalition(coalition.side.RED, 'Target report', nil, printDataRed, nil)

activateNextTargetBlue()
activateNextTargetRed()