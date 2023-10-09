({
	init: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.setRetailMonths(component);
		this.resetForm(component);
	},

	setRetailMonths: function(component) {
		var monthList = [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ];
		var retailMonths = [];
		var indexDate = new Date();
		indexDate.setMonth(indexDate.getMonth() - 12);
		for (var i=0; i<11; i++) {
			indexDate.setMonth(indexDate.getMonth() + 1);
			retailMonths.push(monthList[indexDate.getMonth()] + ' ' + indexDate.getFullYear());
		}
		component.set('v.retailMonths', retailMonths);
	},

	resetForm: function(component) {
		component.find('monthMissing').set('v.value', null);
		var action = component.get('c.getCaseInfo');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var caseInfo = response.getReturnValue();
				component.set('v.case', caseInfo.caseObject);
				component.set('v.account', caseInfo.accountObject);
				component.set('v.contact', caseInfo.contactObject);
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
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
		if (allValid && this.validateReasonForChallenge(component)) {
			return true;
		} else {
			alert('Please update the invalid form entries and try again.');
		}
		return false;
	},

	validateReasonForChallenge: function(component) {
		var isCompliant = component.find('monthMissing');
		if (isCompliant.get('v.value')) {
			component.set('v.case.Reason_For_Challenge__c', 'Entire month missing. Process DAP for every VIN.');
			return true;
		} else {
			component.set('v.case.Reason_For_Challenge__c', null);
		}
		return isCompliant.get('v.validity');
	}
});