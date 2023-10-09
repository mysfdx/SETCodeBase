({
	doInit: function(component, event, helper) {
		helper.init(component);
	},

	validateVIN: function(component, event, helper) {
		var vinInput = event.getParam('value');
		component.find('vinInput').set('v.value', vinInput.toUpperCase());
		var validVIN = component.find('vinInput').get('v.validity').valid;
		component.set('v.isValidVin', validVIN);
	},

	resetShippingInfo: function(component, event, helper) {
		component.set('v.case.ContactFax', '');
		component.set('v.case.FedEx_Number__c', '');
	},

	updateVinTable: function(component, event, helper) {
		var vinTableEntries = [];
		var vins = component.get('v.vins');
		for (var i = 0; i < vins.length; i++) {
			var vinObject = new Object();
			vinObject.index = i;
			vinObject.value = vins[i];
			vinTableEntries.push(vinObject);
		}
		component.set('v.vinDataEntries', vinTableEntries);
	},

	addVin: function(component, event, helper) {
		helper.addValidVin(component, true);
		component.set('v.inputVIN', '');
        component.set('v.isValidVin', false);
	},

	removeVIN: function(component, event, helper) {
		var index = event.getParam('row').index;
		helper.removeVinByIndex(component, index);
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