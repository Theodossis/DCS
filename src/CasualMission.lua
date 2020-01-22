--[[
    Casual Mission script - Version: 1.0 - 18/1/2020 by Theodossis Papadopoulos
    -- Requires MIST
    
    -- Points only work with my other script: PointSystem ELSE use variables: 
       ]]

-- -----------------------------------CODE DO NOT TOUCH-----------------------------------
local TARGETS_FOR_BLUE = {}
local TARGETS_FOR_RED = {}

-- -----------------------------------CONFIGURATION---------------------------------------
TARGETS_FOR_BLUE[1] = {
  Targets = {"BT_1A", "BT_1B"},
  DisplayName = "mobiles/sat",
  Briefing = "Just destroy them",
  Points = 2
}
TARGETS_FOR_BLUE[2] = {
  Targets = {"BT_2"},
  DisplayName = "something 2",
  Briefing = "some briefing",
  Points = 2
}
TARGETS_FOR_BLUE[3] = {
  Targets = {"BT_3"},
  DisplayName = "something 3",
  Briefing = "some briefing",
  Points = 2
}

TARGETS_FOR_RED[1] = {
  Targets = {"RT_1", "RT_2"},
  DisplayName = "something",
  Briefing = "Just destroy them",
  Points = 2
}

-- -----------------------------------CODE DO NOT TOUCH-----------------------------------
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

local function tableConcat(t1, t2)
  for i=1, #t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

local function showTargets(gpid)
  local earlyBreak = false
  local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
  local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
  local allUnits = tableConcat(blueUnits, redUnits)
  for j=1, tablelength(allUnits) do
    local us = allUnits[j]
    if us:getGroup():getID() == gpid then -- Found him/them for two seat
      earlyBreak = true
      local finalMsg = nil
      if us:getCoalition() == coalition.side.BLUE then
        finalMsg = "Target report:"
        for i=1, tablelength(TARGETS_FOR_BLUE) do
          if tablelength(TARGETS_FOR_BLUE[i].Progression) ~= tablelength(TARGETS_FOR_BLUE[i].Targets) then -- Check if it is already done
            finalMsg = finalMsg .. "\n#" .. i .. ": " .. TARGETS_FOR_BLUE[i].Briefing
          end
        end
      elseif us:getCoalition() == coalition.side.RED then
        finalMsg = "Target report:"
        for i=1, tablelength(TARGETS_FOR_RED) do
          if tablelength(TARGETS_FOR_RED[i].Progression) ~= tablelength(TARGETS_FOR_RED[i].Targets) then -- Check if it is already done
            finalMsg = finalMsg .. "\n#" .. i .. ": " .. TARGETS_FOR_RED[i].Briefing
          end
        end
      end
      trigger.action.outTextForGroup(gpid, finalMsg, 45)
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
      if event.initiator:getGroup():getCategory() == Group.Category.AIRPLANE or event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
        local gpid = event.initiator:getGroup():getID()
        missionCommands.removeItemForGroup(event.initiator:getGroup():getID(), {[1] = "Show targets"})
        missionCommands.addCommandForGroup(gpid, "Show targets", nil, showTargets, gpid)
      end
    end
  elseif event.id == world.event.S_EVENT_DEAD then
    -- FOR BLUE TEAM
    local un = event.initiator
    if un:getCoalition() == coalition.side.RED then -- Red target destroyed
      local earlyBreak = false
      for i=1, tablelength(TARGETS_FOR_BLUE) do
        if tablelength(TARGETS_FOR_BLUE[i].Progression) ~= tablelength(TARGETS_FOR_BLUE[i].Targets) then -- Check if it is already done
          if un:getCategory() == Object.Category.UNIT then
            if groupIsDead(un:getGroup():getName()) then
              if contains(TARGETS_FOR_BLUE[i].Targets, un:getGroup():getName()) then
                TARGETS_FOR_BLUE[i].Progression[tablelength(TARGETS_FOR_BLUE[i].Progression) + 1] = un:getGroup():getName()
                earlyBreak = true
              end
            end
          elseif un:getCategory() == Object.Category.STATIC then
            if contains(TARGETS_FOR_BLUE[i].Targets, un:getName()) then
              TARGETS_FOR_BLUE[i].Progression[tablelength(TARGETS_FOR_BLUE[i].Progression) + 1] = un:getName()
              earlyBreak = true
            end
          end
          if tablelength(TARGETS_FOR_BLUE[i].Progression) == tablelength(TARGETS_FOR_BLUE[i].Targets) then -- TARGET DESTRUCTION COMPLETED
            trigger.action.outTextForCoalition(coalition.side.BLUE, "We have successfully destroyed RED's team " .. TARGETS_FOR_BLUE[i].DisplayName, 20)
            trigger.action.outTextForCoalition(coalition.side.RED, "Our " .. TARGETS_FOR_BLUE[i].DisplayName .. " have just been destroyed by BLUE team", 20)
            if extraBluePoints ~= nil then
              extraBluePoints = extraBluePoints + TARGETS_FOR_BLUE[i].Points
            end
          end
          if earlyBreak == true then
            break
          end
        end
      end
    end
    -- FOR RED TEAM
    if un:getCoalition() == coalition.side.BLUE then -- Blue target destroyed
      local earlyBreak = false
      for i=1, tablelength(TARGETS_FOR_RED) do
        if tablelength(TARGETS_FOR_RED[i].Progression) ~= tablelength(TARGETS_FOR_RED[i].Targets) then -- Check if it is already done
          if un:getCategory() == Object.Category.UNIT then
            if groupIsDead(un:getGroup():getName()) then
              if contains(TARGETS_FOR_RED[i].Targets, un:getGroup():getName()) then
                TARGETS_FOR_RED[i].Progression[tablelength(TARGETS_FOR_RED[i].Progression) + 1] = un:getGroup():getName()
                earlyBreak = true
              end
            end
          elseif un:getCategory() == Object.Category.STATIC then
            if contains(TARGETS_FOR_RED[i].Targets, un:getName()) then
              TARGETS_FOR_RED[i].Progression[tablelength(TARGETS_FOR_RED[i].Progression) + 1] = un:getName()
              earlyBreak = true
            end
          end
          if tablelength(TARGETS_FOR_RED[i].Progression) == tablelength(TARGETS_FOR_RED[i].Targets) then -- TARGET DESTRUCTION COMPLETED
            trigger.action.outTextForCoalition(coalition.side.RED, "We have successfully destroyed BLUE's team " .. TARGETS_FOR_RED[i].DisplayName , 20)
            trigger.action.outTextForCoalition(coalition.side.BLUE, "Our " .. TARGETS_FOR_RED[i].DisplayName .. " have just been destroyed by RED team", 20)
            if extraRedPoints ~= nil then
              extraRedPoints = extraRedPoints + TARGETS_FOR_RED[i].Points
            end
          end
          if earlyBreak == true then
            break
          end
        end
      end
    end
  end
end
world.addEventHandler(EV_MANAGER)

-- Setup progression
for i=1, tablelength(TARGETS_FOR_BLUE) do
  TARGETS_FOR_BLUE[i].Progression = {}
end
for i=1, tablelength(TARGETS_FOR_RED) do
  TARGETS_FOR_RED[i].Progression = {}
end