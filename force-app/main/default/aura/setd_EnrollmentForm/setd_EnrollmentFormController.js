({
	doInit: function(component, event, helper) {
		helper.initForm(component);
	},

	handleAuthorizedUser: function(component, event, helper) {
		var isAuthorized = (event.getParam('value') == 'YES');
		component.set('v.case.Dealer_Signature__c', isAuthorized);
	},

	handlePayeeEnable: function(component, event, helper) {
		helper.setPayeeTypes(component);
		helper.setPayeeEnable(component);
	},

	handleAdd: function(component, event, helper) {
		helper.addPayee(component);
	},

	handleRemove: function(component, event, helper) {
		helper.removePayee(component);
	},

	handleClear: function(component, event, helper) {
		helper.resetForm(component);
		helper.resetPayees(component);
		component.set('v.isAuthorizedUser', null);
		component.set('v.case.Dealer_Signature__c', null);
	},

	handlePrint: function(component, event, helper) {
		window.print();
	},

	handleSubmit: function(component, event, helper) {
		helper.fireSubmitEvent(component);
	},
});