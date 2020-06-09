--[[
    Countdown Script - Version: 1.00 - 6/6/2020 by Theodossis Papadopoulos 
       ]]
       
local updatecountdownEvery = 1 -- In seconds
local countdownTimer = 70 -- In seconds

local function printCountdown() 
  if countdownTimer <= 0 then
    trigger.action.outText("********** COUNTDOWN ENDED! **********", updatecountdownEvery, true)
  else
    local minutesLeft = math.floor(countdownTimer/60)
    local secondsLeft = countdownTimer%60
    trigger.action.outText("COUNTDOWN: " .. minutesLeft.. ":" .. secondsLeft, updatecountdownEvery, true)
    countdownTimer = countdownTimer - updatecountdownEvery
  end
  timer.scheduleFunction(printCountdown, nil, timer.getTime() + updatecountdownEvery)
end

timer.scheduleFunction(printCountdown, nil, timer.getTime() + updatecountdownEvery)