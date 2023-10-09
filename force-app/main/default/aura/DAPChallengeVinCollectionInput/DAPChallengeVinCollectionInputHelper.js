({
	resetVin: function(component) {
		var inputVin = new Object();
		inputVin.Name = null;
		inputVin.Process_Date__c = null;
		inputVin.Retail_Date__c = null;
		inputVin.Model_Number__c = null;
		inputVin.Customer_Name__c = null;
		inputVin.Lease_Co_Name__c = null;
		component.set('v.inputVin', inputVin);
	},

	validateInput: function(component) {
		var isValid = (this.validateVin(component) && this.validateModelNumber(component));
		component.set('v.validVin', isValid);
	},

	validateVin: function(component) {
		var vinInput = component.find('vin');
		if (vinInput.get('v.value')) {
			return vinInput.checkValidity();
		}
		return false;
	},

	validateModelNumber: function(component) {
		var modelNumberInput = component.find('modelNumber');
		if (modelNumberInput.get('v.value')) {
			return modelNumberInput.checkValidity();
		}
		return false;
	},

	fireNewInputVin: function(component) {
		var event = component.getEvent('vinInputEvent');
		var inputVin = component.get('v.inputVin');
		inputVin.Name = inputVin.Name.toUpperCase();
		event.setParams({
			inputVin : inputVin
		});
		event.fire();
	}
});