--[[
    Point System Script - Version: 1.03 - 18/1/2020 by Theodossis Papadopoulos 
       ]]
-- Mission Template Script already contains it
-- Requires MIST script

-- ------------------POINT COSTS FOR OBJECTS------------------
local aircraftPoints = 1 -- How many points will be rewarded to the team which shoot down the aircraft
local aircraftCost = 2 -- How many points will be removed from the team who lost the aircraft
local heliPoints = 1 -- How many points will be rewarded to the team which shoot down the helicopter
local heliCost = 1 -- How many points will be removed from the team who lost the helicopter
local shipPoints = 5 -- How many points will be rewarded to the team which sank the ship
local unitPoints = 0.3 -- How many points will be rewarded to the team which destroyed a ground unit

local printScoreEvery = 150 -- How much time between its cycle to show message (in seconds)
local printScoreFor = 20 -- How much time will the message show up (in seconds)

-- ------------------ CODE DO NOT TOUCH ------------------
extraBluePoints = 0
extraRedPoints = 0

local blueACCasualties = 0
local blueHeliCasualties = 0
local blueShipCasualties = 0
local blueGroundUnitCasualties = 0

local redACCasualties = 0
local redHeliCasualties = 0
local redShipCasualties = 0
local redGroundUnitCasualties = 0

-- -------------------------EVENT LISTENER-------------------------
local POINT_SYSTEM = {}
function POINT_SYSTEM:onEvent(event)
  local who = event.initiator
  if event.id == world.event.S_EVENT_DEAD then
    if who:getCategory() == Object.Category.UNIT then
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
      elseif who:getGroup():getCategory() == Group.Category.SHIP then
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
local function printPoints()
  local totalPointsForBlue = redACCasualties*aircraftPoints + redHeliCasualties*heliPoints + redShipCasualties*shipPoints + redGroundUnitCasualties*unitPoints - blueACCasualties*aircraftCost - blueHeliCasualties*heliCost + extraBluePoints
  local totalPointsForRed = blueACCasualties*aircraftPoints + blueHeliCasualties*heliPoints + blueShipCasualties*shipPoints + blueGroundUnitCasualties*unitPoints - redACCasualties*aircraftCost - redHeliCasualties*heliCost + extraRedPoints
  trigger.action.outText('###  TEAM SCORES  ###  Created by =GR= Theodossis for LoG' , printScoreFor)
  trigger.action.outText('POINTS:  BLUELAND TEAM: ' .. totalPointsForBlue .. '  / REDLAND TEAM: ' .. totalPointsForRed, printScoreFor)
  trigger.action.outText('BLUE TEAM CASUALTIES: A/C:' .. blueACCasualties .. ' HELO: ' .. blueHeliCasualties .. ' SHIPS: ' .. blueShipCasualties .. ' GROUND UNITS: ' .. blueGroundUnitCasualties .. '\nPoints from missions: ' .. extraBluePoints, printScoreFor)  
  trigger.action.outText('RED TEAM CASUALTIES: A/C:' .. redACCasualties .. ' HELO: ' .. redHeliCasualties .. ' SHIPS: ' .. redShipCasualties .. ' GROUND UNITS: ' .. redGroundUnitCasualties .. '\nPoints from missions: ' .. extraRedPoints, printScoreFor)  
end

mist.scheduleFunction(printPoints, nil, timer.getTime() + 10, printScoreEvery)