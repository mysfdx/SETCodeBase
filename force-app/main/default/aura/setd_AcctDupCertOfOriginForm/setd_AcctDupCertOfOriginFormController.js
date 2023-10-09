({
	doInit: function(component, event, helper) {
		helper.init(component);
	},

	handleVINInput: function(component, event, helper) {
		var vinInput = event.getParam('value');
		component.set('v.case.SET_VIN__c', vinInput.toUpperCase());
	},

	handleNoTitledVehicle: function(component, event, helper) {
		helper.setTitledVehicle(component, 'No');
	},

	handleYesTitledVehicle: function(component, event, helper) {
		helper.setTitledVehicle(component, 'Yes');
	},

	handleDuplicateReason: function(component, event, helper) {
		var duplicateReason = component.get('v.case.Reason_for_Duplicate__c');
		console.log(duplicateReason);
		component.set('v.selectedOther', duplicateReason == 'OTHER');
	},

	handleClear: function(component, event, helper) {
		helper.resetForm(component);
		helper.setTitledVehicle(component, null);
	},

	handlePrint: function(component, event, helper) {
		component.set('v.pendingPrint', false);
		window.print();
	},

	handleSubmit: function(component, event, helper) {
		helper.fireSubmitEvent(component);
	}
});