--[[
    MoveCargo Script - Version: 1.1 - 21/2/2020 by Theodossis Papadopoulos
    -- Requires MIST
    -- With love for =GR= Spanker
    -- DON'T FORGET TO CREATE A SPAWN_ZONE
       ]]

local CARGO_SCRIPT = {}
-- ---------------------------CONFIGURATION---------------------------
local NOT_IN_ZONE_MESSAGE = "You must be inside the spawn zone to spawn a crate!"
local CRATE_MASS = 300
local SHAPE_NAME = "ab-212_cargo" -- MIKRO DYXTIOTO
local TYPE = "uh1h_cargo"

--[[ Placeholder for different crates 

local SHAPE_NAME = "bw_container_cargo" -- MEGALO PRASINO
local TYPE = "container_cargo"

local SHAPE_NAME = "ab-212_cargo" -- MIKRO DYXTIOTO
local TYPE = "uh1h_cargo"

local SHAPE_NAME = "bw_container_cargo"
local TYPE = "container_cargo"

local SHAPE_NAME = "f_bar_cargo"
local TYPE = "f_bar_cargo"

local SHAPE_NAME = "fueltank_cargo"
local TYPE = "fueltank_cargo"

]]

CARGO_SCRIPT[1] = {
  ZONE_NAME = "ZONE_1",
  HOW_MANY = 2,
  FLAG_NAME = 1,
  SET_TO = 10,
}
CARGO_SCRIPT[2] = {
  ZONE_NAME = "ZONE_2",
  HOW_MANY = 1,
  FLAG_NAME = 2,
  SET_TO = 5,
}
-- ---------------------------CODE DO NOT TOUCH---------------------------

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function tableConcat(t1, t2)
  for i=1, #t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

local function tableConcatNew(t1, t2)
  local tfinal = {}
  for i=1, #t1 do
    tfinal[#tfinal + 1] = t1[i]
  end
  for i=1, #t2 do
    tfinal[#tfinal + 1] = t2[i]
  end
  return tfinal
end

local function isInZone(vec3, zone)
  return ((vec3.x - zone.point.x)^2 + (vec3.z - zone.point.z)^2)^0.5 < zone.radius
end

local function checker()
  for i=1, tablelength(CARGO_SCRIPT) do
    local cnt = 0
    local script = CARGO_SCRIPT[i]
    local zone = trigger.misc.getZone(script.ZONE_NAME)
    local blue_cargos = coalition.getStaticObjects(coalition.side.BLUE)
    local red_cargos = coalition.getStaticObjects(coalition.side.RED)
    local all_cargos = tableConcatNew(blue_cargos, red_cargos)
    for j=1, tablelength(all_cargos) do
      local cargo = all_cargos[j]
      if (isInZone(cargo:getPosition().p, zone)) and (cargo:inAir() == false) and (cargo:getLife() >= 1) and (cargo:getTypeName() == TYPE) then
        cnt = cnt + 1
      end
    end
    if cnt == script.HOW_MANY then
      -- trigger.action.outText("SUCCESS " .. script.ZONE_NAME, 10) -- DEBUG
      trigger.action.setUserFlag(script.FLAG_NAME, script.SET_TO)
      table.remove(CARGO_SCRIPT, i)
      break
    end
  end
end

local function showProgress(gpid)
  local finalText = "Crate Transfer Progression: "
  local textEmpty = true
  for i=1, tablelength(CARGO_SCRIPT) do
    local cnt = 0
    local script = CARGO_SCRIPT[i]
    local zone = trigger.misc.getZone(script.ZONE_NAME)
    local blue_cargos = coalition.getStaticObjects(coalition.side.BLUE)
    local red_cargos = coalition.getStaticObjects(coalition.side.RED)
    local all_cargos = tableConcatNew(blue_cargos, red_cargos)
    for j=1, tablelength(all_cargos) do
      local cargo = all_cargos[j]
      if (isInZone(cargo:getPosition().p, zone)) and (cargo:inAir() == false) and (cargo:getLife() >= 1) and (cargo:getTypeName() == TYPE) then
        cnt = cnt + 1
      end
    end
    textEmpty = false
    finalText = finalText .. "\n- " .. script.ZONE_NAME .. " " .. cnt .. "/" .. script.HOW_MANY
  end
  if textEmpty == true then
    finalText = finalText .. "COMPLETE"
  end
  trigger.action.outTextForGroup(gpid, finalText, 15)
end

local function getFront(position, offset)
  local angle = math.atan2(position.x.z, position.x.x)
  local xOffset = math.cos(angle) * offset
  local yOffset = math.sin(angle) * offset
  local point = position.p
  return { x = point.x + xOffset, z = point.z + yOffset, y = point.y }
end

local function spawnCrate(gpid)
  local earlyBreak = false
  local blueUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.BLUE))
  local redUnits = mist.utils.deepCopy(coalition.getPlayers(coalition.side.RED))
  local allUnits = tableConcat(blueUnits, redUnits)
  for j=1, tablelength(allUnits) do
    local us = allUnits[j]
    if us:getGroup():getID() == gpid then -- Found him/them for two seat
      if isInZone(us:getPosition().p, trigger.misc.getZone("SPAWN_ZONE")) then 
        earlyBreak = true
        local position = us:getPosition()
        local front = getFront(position, 20)
        local crate = {
          ["category"] = "Cargos",
          ["shape_name"] = SHAPE_NAME, 
          ["type"] = TYPE,
          ["y"] = front.z,
          ["x"] = front.x,
          ["mass"] = CRATE_MASS,
          ["canCargo"] = true,
          ["heading"] = 0,
          ["country"] = us:getCountry(),
         }
         mist.dynAddStatic(crate)
         trigger.action.outTextForGroup(gpid, "Crate spawned!", 5)
      else 
        trigger.action.outTextForGroup(gpid, NOT_IN_ZONE_MESSAGE, 15)
      end
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
      if event.initiator:getGroup():getCategory() == Group.Category.HELICOPTER then
        local gpid = event.initiator:getGroup():getID()
        missionCommands.removeItemForGroup(gpid, {[1] = "Spawn crate"})
        missionCommands.removeItemForGroup(gpid, {[1] = "Show crate progress"})
        missionCommands.addCommandForGroup(gpid, "Spawn crate", nil, spawnCrate, gpid)
        missionCommands.addCommandForGroup(gpid, "Show crate progress", nil, showProgress, gpid)
      end
    end
  end
end
world.addEventHandler(EV_MANAGER)

mist.scheduleFunction(checker, nil, timer.getTime() + 10, 10)