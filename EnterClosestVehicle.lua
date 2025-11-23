--[[
Author: Fetty42
Date: 08.12.2024
Version: 1.0.1.0
]]

local dbPrintfOn = false
local dbInfoPrintfOn = false

local function dbInfoPrintf(...)
	if dbInfoPrintfOn then
    	print(string.format(...))
	end
end

local function dbPrintf(...)
	if dbPrintfOn then
    	print(string.format(...))
	end
end

local function dbPrint(...)
	if dbPrintfOn then
    	print(...)
	end
end

local function dbPrintHeader(funcName)
	if dbPrintfOn then
		if g_currentMission ~=nil and g_currentMission.missionDynamicInfo ~=nil then
			print(string.format("Call %s: isDedicatedServer=%s | isServer()=%s | isMasterUser=%s | isMultiplayer=%s | isClient()=%s | farmId=%s", 
							funcName, tostring(g_dedicatedServer~=nil), tostring(g_currentMission:getIsServer()), tostring(g_currentMission.isMasterUser), tostring(g_currentMission.missionDynamicInfo.isMultiplayer), tostring(g_currentMission:getIsClient()), tostring(g_currentMission:getFarmId())))
		else
			print(string.format("Call %s: isDedicatedServer=%s | g_currentMission=%s",
							funcName, tostring(g_dedicatedServer~=nil), tostring(g_currentMission)))
		end
	end
end


EnterClosestVehicle = {}
-- EnterClosestVehicle.events = {}


function EnterClosestVehicle:loadMap(name)
	dbPrintHeader("EnterClosestVehicle:loadMap")

end

function EnterClosestVehicle:registerActionEvents()
	dbPrintHeader("EnterClosestVehicle:registerActionEventsPlayer")
end

-- Wechsel in das am nächsten stehende Fahrzeug
function EnterClosestVehicle:enterClosestVehicle()
	dbPrintHeader("EnterClosestVehicle:enterClosestVehicle")
	local closestVehicle = EnterClosestVehicle:getClosestVehicle()
	if closestVehicle ~= nil then
		g_localPlayer:requestToEnterVehicle(closestVehicle)
	end
end


function EnterClosestVehicle:getClosestVehicle()
	dbPrintHeader("EnterClosestVehicle:getClosestVehicle")

    if g_localPlayer == nil then
		dbPrintf("  No player or controlled vehicle!")
		return nil
	end

    local function getPlayerOrVehiclePosition()
        if g_localPlayer.getCurrentVehicle() ~= nil then
            if g_localPlayer.getCurrentVehicle().steeringAxleNode ~= nil then
				return getWorldTranslation(g_localPlayer.getCurrentVehicle().steeringAxleNode)
			end
		else
			return g_localPlayer:getPosition()
		end
	end

    local x_pos_player, y_pos_player, z_pos_player = getPlayerOrVehiclePosition()
    if x_pos_player == nil or z_pos_player == nil then
		dbPrintf("  No player or controlled vehicle position!")
		return nil
    end
	
	-- Fahrzeuge durchlaufen
	local curVehicle = g_localPlayer.getCurrentVehicle()
	local allVehicles = g_currentMission.vehicleSystem.vehicles
	local closestVehicle =  nil
	local closestVehicleDistance = math.huge
	for key, vehicle in ipairs(allVehicles) do
		dbPrintf("  key=" .. key .. " | FullName=" .. vehicle:getFullName())

		if not vehicle.isDeleted and vehicle.spec_aiVehicle ~= nil --[[and vehicle.spec_locomotive == nil]]  and not vehicle.isBroken and vehicle ~= curVehicle and vehicle.getIsTabbable~=nil and vehicle:getIsTabbable() and vehicle:getOwnerFarmId() == g_currentMission:getFarmId() then
			dbPrintf("  key=" .. key .. " | FullName=" .. vehicle:getFullName())
            if vehicle.steeringAxleNode ~= nil then
				local x_pos_vehicle, y_pos_vehicle, z_pos_vehicle = getWorldTranslation(vehicle.steeringAxleNode)
				local distanceBetweenPlayerAndVehicle = math.sqrt((x_pos_player - x_pos_vehicle)^2 + (z_pos_player - z_pos_vehicle)^2) -- Algoritm from AnimalsHUD
				dbPrintf("  Distance=" .. tostring(distanceBetweenPlayerAndVehicle))

				if distanceBetweenPlayerAndVehicle < closestVehicleDistance then
					dbPrintf("  new closest vehicle found!")
					closestVehicle = vehicle
					closestVehicleDistance = distanceBetweenPlayerAndVehicle
				end
			end
		end
	end
	-- Return the closest vehicle found
	return closestVehicle
end


-- function EnterClosestVehicle:update(dt) end;
-- function EnterClosestVehicle:onLoad(savegame)end;
-- function EnterClosestVehicle:onUpdate(dt)end;
-- function EnterClosestVehicle:deleteMap()end;
-- function EnterClosestVehicle:keyEvent(unicode, sym, modifier, isDown)end;
-- function EnterClosestVehicle:mouseEvent(posX, posY, isDown, isUp, button)end;
-- function EnterClosestVehicle:draw()end;


addModEventListener(EnterClosestVehicle);