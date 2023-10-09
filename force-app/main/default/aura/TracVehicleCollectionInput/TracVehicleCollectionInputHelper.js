({
	resetVehicleInput: function(component) {
		var inputVehicle = new Object();
		inputVehicle.Model_Number__c = '';
		inputVehicle.Quantity__c = '';
		inputVehicle.Color__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_1__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_2__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_3__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_4__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_5__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_6__c = '';
		inputVehicle.Port_Installed_Option_1__c = '';
		inputVehicle.Port_Installed_Option_2__c = '';
		inputVehicle.Port_Installed_Option_3__c = '';
		inputVehicle.Port_Installed_Option_4__c = '';
		component.set('v.inputVehicle', inputVehicle);
	},

	validateInput: function(component) {
		var isValid = (this.validateModelNumber(component) && this.validateQuantity(component));
		component.set('v.validVehicle', isValid);
	},

	validateModelNumber: function(component) {
		var modelNumberInput = component.find('modelNumber');
		return modelNumberInput.checkValidity();
	},

	validateQuantity: function(component) {
		var quantityInput = component.find('quantity');
		return (quantityInput.checkValidity() && (quantityInput.get('v.value') > 0));
	},

	fireNewInputVehicle: function(component) {
		var event = component.getEvent('vehicleInputEvent');
		event.setParams({
			inputVehicle : component.get('v.inputVehicle')
		});
		event.fire();
	}
});