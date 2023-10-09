({
	initForm: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.resetForm(component);
		this.setPicklistOptions(component);
		this.setValidMonths(component);
	},

	resetForm: function(component) {
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

	setPicklistOptions: function(component) {
		var reasonRequestAction = component.get('c.getReasonAppeals');
		reasonRequestAction.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.reasonAppeals', response.getReturnValue());
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(reasonRequestAction);

		var districtsRequestAction = component.get('c.getAccountDistricts');
		districtsRequestAction.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.districts', response.getReturnValue());
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(districtsRequestAction);
	},

	setValidMonths: function(component) {
		var monthsDisplayed = [];
		var currentMonth = new Date().getMonth();
		if (currentMonth == 0) {
			var months = component.get('v.months');
			monthsDisplayed.push(months[11]);
			monthsDisplayed.push(months[0]);
		} else {
			var previousMonth = (currentMonth - 1);
			monthsDisplayed = component.get('v.months').slice(previousMonth, (currentMonth + 1));
		}
		component.set('v.months', monthsDisplayed);
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
			return true;
		} else {
			alert('Please update the invalid form entries and try again.');
		}
		return false;
	}
});