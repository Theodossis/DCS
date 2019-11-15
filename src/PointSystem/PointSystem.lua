-- Mission Template Script already contains it

local blueACCasualties = 0
local blueHeliCasualties = 0
local blueShipCasualties = 0
local blueGroundUnitCasualties = 0

local redACCasualties = 0
local redHeliCasualties = 0
local redShipCasualties = 0
local redGroundUnitCasualties = 0

-- -------------------------EVENT LISTENER-------------------------
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
  trigger.action.outText('###  TEAM SCORES  ###  Created by =GR= Theodossis for LoG' , 30)
  trigger.action.outText('POINTS:  BLUELAND TEAM: ' .. totalPointsForBlue .. '  / REDLAND TEAM: ' .. totalPointsForRed, 30)
  trigger.action.outText('BLUE TEAM CASUALTIES: A/C:' .. blueACCasualties .. ' HELO: ' .. blueHeliCasualties .. ' SHIPS: ' .. blueShipCasualties .. ' GROUND UNITS: ' .. blueGroundUnitCasualties, 30)  
  trigger.action.outText('RED TEAM CASUALTIES: A/C:' .. redACCasualties .. ' HELO: ' .. redHeliCasualties .. ' SHIPS: ' .. redShipCasualties .. ' GROUND UNITS: ' .. redGroundUnitCasualties, 30)  
end

mist.scheduleFunction(printPoints, nil, timer.getTime() + 10, 300)