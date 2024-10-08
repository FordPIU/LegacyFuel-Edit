SetFuelConsumptionState(true)
SetFuelConsumptionRateMultiplier(200.0)
--SetFuelConsumptionRateMultiplier(200.0)

local isFueling = false
local ShutOffPump = false
local lastFuel = {}

AddEventHandler('fuel:startFuelUpTick', function(pumpObject, ped, vehicle)
	local maxFuel = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fPetrolTankVolume")

	while isFueling do
		Citizen.Wait(1000)

		local currentFuel = GetVehicleFuelLevel(vehicle)
		local fuelToAdd = 0.75

		if not pumpObject then
			if GetAmmoInPedWeapon(ped, 883325847) - fuelToAdd * 100 >= 0 then
				currentFuel = currentFuel + fuelToAdd

				SetPedAmmo(ped, 883325847, math.floor(GetAmmoInPedWeapon(ped, 883325847) - fuelToAdd * 100))
			else
				isFueling = false
			end
		else
			currentFuel = currentFuel + fuelToAdd
		end

		if currentFuel > maxFuel then
			currentFuel = maxFuel
			ShutOffPump = true
		end

		if ShutOffPump then
			ShutOffPump = false
			Citizen.Wait(Config.WaitTimeAfterRefuel)
			isFueling = false
		end

		SetVehicleFuelLevel(vehicle, currentFuel)
	end
end)

AddEventHandler('fuel:stopRefuelFromPump', function()
	if isFueling then
		ShutOffPump = true
	end
end)

AddEventHandler('fuel:refuelFromPump', function(ped, vehicle)
	isFueling = true
	TriggerEvent('fuel:startFuelUpTick', true, ped, vehicle)
	while isFueling do
		local vehicleCoords = GetEntityCoords(vehicle)
		local extraString = ""

		if Config.UseESX then
			extraString = "\n" .. Config.Strings.TotalCost .. ": ~g~$" .. Round(currentCost, 1)
		end
		DrawText3Ds(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5,
			Round(GetFuelAsPercent(vehicle), 1) .. "%" .. extraString)
		Citizen.Wait(0)
	end
end)

AddEventHandler('fuel:refuelFromJerryCan', function(ped, vehicle)
	TaskTurnPedToFaceEntity(ped, vehicle, 1000)
	Citizen.Wait(1000)
	SetCurrentPedWeapon(ped, -1569615261, true)
	isFueling = true
	LoadAnimDict("timetable@gardener@filling_can")
	TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)

	TriggerEvent('fuel:startFuelUpTick', false, ped, vehicle)

	while isFueling do
		for _, controlIndex in pairs(Config.DisableKeys) do
			DisableControlAction(0, controlIndex)
		end

		local vehicleCoords = GetEntityCoords(vehicle)
		DrawText3Ds(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5,
			Config.Strings.CancelFuelingJerryCan ..
			"\nGas can: ~g~" ..
			Round(GetAmmoInPedWeapon(ped, 883325847) / 4500 * 100, 1) ..
			"% | Vehicle: " .. Round(GetFuelAsPercent(vehicle), 1) .. "%")

		if not IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
			TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
		end

		if IsControlJustReleased(0, 38) or DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) then
			isFueling = false
		end

		Citizen.Wait(0)
	end

	ClearPedTasks(ped)
	RemoveAnimDict("timetable@gardener@filling_can")
end)

AddEventHandler('fuel:requestJerryCanPurchase', function()
	local ped = PlayerPedId()
	if not HasPedGotWeapon(ped, 883325847, false) then
		ShowNotification(Config.Strings.PurchaseJerryCan)
		GiveWeaponToPed(ped, 883325847, 4500, false, true)
	else
		ShowNotification(Config.Strings.RefillJerryCan)
		SetPedAmmo(ped, 883325847, 4500)
	end
end)

--[[
	Create gas station blips
]]
Citizen.CreateThread(function()
	for _, gasStationCoords in pairs(Config.GasStations) do
		CreateBlip(gasStationCoords)
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		local v = GetVehiclePedIsIn(PlayerPedId(), true)

		if DoesEntityExist(v) then
			--[[print(
				GetVehicleFuelLevel(v),
				GetVehicleHandlingFloat(v, "CHandlingData", "fPetrolTankVolume"),
				GetFuelAsPercent(v),
				GetVehicleHandlingFloat(v, "CHandlingData", "fPetrolConsumptionRate")
			)]]

			if lastFuel[v] ~= nil then
				if GetVehicleFuelLevel(v) - lastFuel[v] > 5 then
					SetVehicleFuelLevel(v, lastFuel[v])
					print("Fuel reset detected")
				end
			end

			lastFuel[v] = GetVehicleFuelLevel(v)
		end
	end
end)

local modifiedConsumptions = {}
Citizen.CreateThread(function()
	while true do
		Wait(2500)

		local v = GetVehiclePedIsIn(PlayerPedId(), false)

		if DoesEntityExist(v) then
			local vModel = GetEntityModel(v)

			if IsToggleModOn(v, 18) == 1 and modifiedConsumptions[vModel] == nil then
				local oldConsumptionRate = GetVehicleHandlingFloat(v, "CHandlingData", "fPetrolConsumptionRate")
				local newConsumptionRate = oldConsumptionRate * 1.5
				modifiedConsumptions[vModel] = oldConsumptionRate

				SetVehicleHandlingFloat(v, "CHandlingData", "fPetrolConsumptionRate", newConsumptionRate)
			elseif IsToggleModOn(v, 18) == false and modifiedConsumptions[vModel] ~= nil then
				SetVehicleHandlingFloat(v, "CHandlingData", "fPetrolConsumptionRate", modifiedConsumptions[vModel])

				modifiedConsumptions[vModel] = nil
			end
		end
	end
end)
