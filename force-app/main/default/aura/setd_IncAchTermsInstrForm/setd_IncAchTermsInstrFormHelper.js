({
	initForm: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.resetForm(component);
		this.initAuthorizeVerbiage(component);
		this.setCommunityDomain(component);
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

	initAuthorizeVerbiage: function(component) {
		var authorizeVerbiage = 'I hereby authorize Southeast Toyota Distributors, LLC., hereafter referred to as "SET", ' +
			'to affect payment in the form of electronic depository transfers or depository transfer checks, to my Bank account indicated below, ' +
			'herinafter called "Bank". I authorize my Bank to accept entries initiated by SET to my account and to credit or debit my account ' +
			'without responsibility for the correctness thereof.';
		component.set('v.authorizeVerbiage', authorizeVerbiage);
	},

	setCommunityDomain: function(component) {
		var action = component.get('c.getCommunityDomain');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var communityDomain = response.getReturnValue();
				component.set('v.communityDomain', communityDomain);
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