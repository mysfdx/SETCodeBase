({
	handleFirstNameInput: function(component, event, helper) {
		var value = helper.formatName(component.find('firstName').get('v.value'), component);
		component.set('v.payee.First_Name__c', value);
	},

	handleLastNameInput: function(component, event, helper) {
		var value = helper.formatName(component.find('lastName').get('v.value'), component);
		component.set('v.payee.Last_Name__c', value);
	}
});