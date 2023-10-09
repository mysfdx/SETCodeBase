({
	fireRemoveVin: function(component, indexRemoved) {
		var event = component.getEvent('removeVinEvent');
		event.setParams({
			vehicleIndex : indexRemoved
		});
		event.fire();
	}
});