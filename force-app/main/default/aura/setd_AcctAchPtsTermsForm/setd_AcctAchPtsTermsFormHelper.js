({
	initForm: function(component) {
		this.resetForm(component);
	},

	resetForm: function(component) {
		var action = component.get('c.getCaseInfo');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var caseInfo = response.getReturnValue();
				component.set('v.case', caseInfo.caseObject);
				component.set('v.account', caseInfo.accountObject);
				component.set('v.contact', caseInfo.contactObject);
			}
		});
		$A.enqueueAction(action);
	},

	fireSubmitEvent : function(component) {
		if(!this.validate(component)) {
			return;
		}
		var event = component.getEvent('formSubmission');
		event.setParams({
			case : component.get('v.case')
		});
		event.fire();
	},

	validate: function(component) {
		var allValid = component.find('inputField').reduce(function(valid, input) {
			input.showHelpMessageIfInvalid();
			return valid && !input.get('v.validity').valueMissing && input.checkValidity();
		}, true);
		if (allValid) {
			if (component.get('v.pendingPrint') && !component.get('v.case.Dealer_Signature__c')) {
				alert('Form must be printed before submitting.');
			} else {
				return true;
			}
		} else {
			alert('Please update the invalid form entries and try again.');
		}
		return false;
	}
});