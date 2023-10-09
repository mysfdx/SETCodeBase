({
	doInit: function(component, event, helper) {
		helper.resetVin(component);
	},

	handleInputChange: function(component, event, helper) {
		helper.validateInput(component);
	},

	handleVinInput: function(component, event, helper) {
		var vinInput = component.find('vin');
		vinInput.checkValidity();
	},

	handleModelInput: function(component, event, helper) {
		var modelInput = component.find('modelNumber');
		modelInput.checkValidity();
	},

	handleAddVin: function(component, event, helper) {
		helper.fireNewInputVin(component);
		helper.resetVin(component);
		component.set('v.validVin', false);
	}
});