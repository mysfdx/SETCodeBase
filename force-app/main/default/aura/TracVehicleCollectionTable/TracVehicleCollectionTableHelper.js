({
	fireRemoveVehicle: function(component, indexRemoved) {
		var event = component.getEvent('removeVehicleEvent');
		event.setParams({
			vehicleIndex : indexRemoved
		});
		event.fire();
	}
});