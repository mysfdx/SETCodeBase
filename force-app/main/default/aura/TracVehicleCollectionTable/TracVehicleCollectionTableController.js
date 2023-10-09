({
	handleRemoveVehicle: function(component, event, helper) {
		var indexRemoved = event.getSource().get('v.value');
		helper.fireRemoveVehicle(component, indexRemoved);
	}
});