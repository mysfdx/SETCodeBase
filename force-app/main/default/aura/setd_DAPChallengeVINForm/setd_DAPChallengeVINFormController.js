({
	doInit: function(component, event, helper) {
		helper.init(component);
	},

	handleNewVin: function(component, event, helper) {
		var inputVin = event.getParam('inputVin');
		helper.addNewVin(component, inputVin);
	},

	handleRemoveVin: function(component, event, helper) {
		var vehicleIndex = event.getParam('vehicleIndex');
		helper.removeVin(component, vehicleIndex);
	},

	handleClear: function(component, event, helper) {
		helper.resetForm(component);
	},

	handlePrint: function(component, event, helper) {
		window.print();
	},

	handleSubmit: function(component, event, helper) {
		helper.fireSubmitEvent(component);
	}
});