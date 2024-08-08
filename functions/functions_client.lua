function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end
	end
end

function Round(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0)

	return math.floor(num * mult + 0.5) / mult
end

function CreateBlip(coords)
	local blip = AddBlipForCoord(coords)

	SetBlipSprite(blip, 361)
	SetBlipScale(blip, 0.9)
	SetBlipColour(blip, 4)
	SetBlipDisplay(blip, 4)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Gas Station")
	EndTextCommandSetBlipName(blip)

	return blip
end

function DrawText3Ds(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)

	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x, _y)
	end
end

function ShowNotification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0, 1)
end

function GetFuelAsPercent(v)
	local fuelLevel = GetVehicleFuelLevel(v)
	local tankVolume = GetVehicleHandlingFloat(v, "CHandlingData", "fPetrolTankVolume")

	-- Calculate the fuel percentage
	local fuelPercentage = (fuelLevel / tankVolume) * 100

	-- Convert the fuel percentage to an integer (0-100)
	local fuelPercentageInt = math.floor(fuelPercentage + 0.5)

	return fuelPercentageInt
end

exports("GetFuelAsPercent", GetFuelAsPercent)
