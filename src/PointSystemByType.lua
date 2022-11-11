--[[
    Point System Script - Version: 1.00 - 10/11/2022 by Theodossis Papadopoulos 
       ]] --

-- ------------------ CODE DO NOT TOUCH ------------------
local POINTS_FOR = {};

-- ------------------POINT COSTS FOR OBJECTS------------------
local printScoreEvery = 150 -- How much time between its cycle to show message (in seconds)
local printScoreFor = 20 -- How much time will the message show up (in seconds)
local analyticScoreboard = true

POINTS_FOR["T-90"] = 1.5
POINTS_FOR["MiG-29A"] = 3
POINTS_FOR["BTR-80"] = 0.3
POINTS_FOR["BMP-3"] = 0.2
POINTS_FOR["Ka-50"] = 0.4

-- ------------------ CODE DO NOT TOUCH ------------------
extraBluePoints = 0
extraRedPoints = 0

local blueACPoints = 0
local blueHeliPoints = 0
local blueShipPoints = 0
local blueGroundPoints = 0

local redACPoints = 0
local redHeliPoints = 0
local redShipPoints = 0
local redGroundPoints = 0

-- -------------------------EVENT LISTENER-------------------------
local POINT_SYSTEM = {}
function POINT_SYSTEM:onEvent(event)
  if event.id == world.event.S_EVENT_UNIT_LOST then
    local who = event.initiator
    if who ~= nil then
      if POINTS_FOR[who:getTypeName()] ~= nil then
        local pointsToAdd = POINTS_FOR[who:getTypeName()]
        local whoCoalition = who:getCoalition()
        local whoCategory = who:getDesc()["category"]
        if whoCoalition == coalition.side.RED then
          if whoCategory == Unit.Category.AIRPLANE then
            blueACPoints = blueACPoints + pointsToAdd
          elseif whoCategory == Unit.Category.HELICOPTER then
            blueHeliPoints = blueHeliPoints + pointsToAdd
          elseif whoCategory == Unit.Category.GROUND_UNIT then
            blueGroundPoints = blueGroundPoints + pointsToAdd
          elseif whoCategory == Unit.Category.SHIP then
            blueShipPoints = blueShipPoints + pointsToAdd
          end
        elseif whoCoalition == coalition.side.BLUE then
          if whoCategory == Unit.Category.AIRPLANE then
            redACPoints = redACPoints + pointsToAdd
          elseif whoCategory == Unit.Category.HELICOPTER then
            redHeliPoints = redHeliPoints + pointsToAdd
          elseif whoCategory == Unit.Category.GROUND_UNIT then
            redGroundPoints = redGroundPoints + pointsToAdd
          elseif whoCategory == Unit.Category.SHIP then
            redShipPoints = redShipPoints + pointsToAdd
          end
        end
      end
    end
  end
end
world.addEventHandler(POINT_SYSTEM)
-- -----------------------------SCORE PRINTER----------------------------------------
function printPoints()
  local totalPointsForBlue = blueACPoints + blueHeliPoints + blueShipPoints + blueGroundPoints + extraBluePoints
  local totalPointsForRed = redACPoints + redHeliPoints + redShipPoints + redGroundPoints + extraRedPoints
  trigger.action.outText('###  TEAM SCORES  ###  Created by =GR= Theo for LoG' , printScoreFor)
  trigger.action.outText('POINTS:  BLUELAND TEAM: ' .. totalPointsForBlue .. '  / REDLAND TEAM: ' .. totalPointsForRed, printScoreFor)
  
  timer.scheduleFunction(printPoints, {}, timer.getTime() + printScoreEvery)
end

function printPointsAnalytic()
  local totalPointsForBlue = blueACPoints + blueHeliPoints + blueShipPoints + blueGroundPoints + extraBluePoints
  local totalPointsForRed = redACPoints + redHeliPoints + redShipPoints + redGroundPoints + extraRedPoints
  trigger.action.outText('###  TEAM SCORES  ###  Created by =GR= Theo for LoG' , printScoreFor)
  trigger.action.outText('POINTS:  BLUELAND TEAM: ' .. totalPointsForBlue .. '  / REDLAND TEAM: ' .. totalPointsForRed, printScoreFor)
  trigger.action.outText('BLUE TEAM: A/C:' .. blueACPoints .. ' HELO: ' .. blueHeliPoints .. ' SHIPS: ' .. blueShipPoints .. ' GROUND UNITS: ' .. blueGroundPoints .. '\nPoints from missions: ' .. extraBluePoints, printScoreFor)  
  trigger.action.outText('RED TEAM: A/C:' .. redACPoints .. ' HELO: ' .. redHeliPoints .. ' SHIPS: ' .. redShipPoints .. ' GROUND UNITS: ' .. redGroundPoints .. '\nPoints from missions: ' .. extraRedPoints, printScoreFor)  
  
  timer.scheduleFunction(printPointsAnalytic, {}, timer.getTime() + printScoreEvery)
end

if analyticScoreboard == false then
  timer.scheduleFunction(printPoints, {}, timer.getTime() + printScoreEvery)
else
  timer.scheduleFunction(printPointsAnalytic, {}, timer.getTime() + printScoreEvery)
end
