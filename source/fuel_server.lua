RegisterNetEvent("LegacyFuel-SetEntityFuelState", function(vehicleNetId, fuelLevel)
	local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
	
	Entity(vehicle).state.fuel = fuelLevel
end)