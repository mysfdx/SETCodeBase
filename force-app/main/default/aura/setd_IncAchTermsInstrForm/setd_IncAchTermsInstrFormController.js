({
	init: function(component, event, helper) {
		helper.initForm(component);
	},

	handleAuthorizedUser: function(component, event, helper) {
		var isAuthorized = (event.getParam('value') == 'YES');
		component.set('v.case.Dealer_Signature__c', isAuthorized);
	},

	handleClear: function(component, event, helper) {
		helper.resetForm(component);
		component.set('v.isAuthorizedUser', null);
		component.set('v.case.Dealer_Signature__c', null);
	},

	handlePrint: function(component, event, helper) {
		component.set('v.pendingPrint', false);
		window.print();
	},

	handleSubmit: function(component, event, helper) {
		helper.fireSubmitEvent(component);
	}
});