({
	doInit: function(component, event, helper) {
		helper.resetVehicleInput(component);
	},

	handleInputChange: function(component, event, helper) {
		helper.validateInput(component);
	},

	handleAddVehicle: function(component, event, helper) {
		helper.fireNewInputVehicle(component);
		helper.resetVehicleInput(component);
		component.set('v.validVehicle', false);
	}
});