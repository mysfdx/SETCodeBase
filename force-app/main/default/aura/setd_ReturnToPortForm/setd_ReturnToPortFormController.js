({
	doInit: function(component, event, helper) {
		helper.init(component);
	},

	handleRadioClick: function(component, event, helper) {
		helper.handleBackhaulPickup(component);
	},

	handleVINInput: function(component, event, helper) {
		var vinInput = event.getParam('value');
		component.set('v.case.SET_VIN__c', vinInput.toUpperCase());
	},

	resetForm: function(component, event, helper) {
		helper.resetForm(component);
	},

	handlePrint: function(component, event, helper) {
		window.print();
	},

	handleSubmit: function(component, event, helper) {
		helper.fireSubmitEvent(component);
	},

	handleDateValidation: function(component, event, helper) {
		if (helper.isBackhaulPickupScheduled(component)) {
			helper.backHaulDateValidity(component);
		}
	}
 });