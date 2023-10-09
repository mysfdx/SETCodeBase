({
	initForm: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.resetForm(component);
		this.resetPayees(component);
		this.initPicklists(component);
		this.setEffectiveDates(component);
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

	initPicklists: function(component) {
		var action = component.get('c.getPicklists');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var picklists = response.getReturnValue();
				component.set('v.challengeNewCarPicklist', picklists.marketChallengeProgramsNewCar);
				component.set('v.challengeCertifiedPicklist', picklists.marketChallengeProgramsCertified);
				component.set('v.pullboardNewCarPicklist', picklists.pullboardProgramsNewCar);
				component.set('v.pullboardCertifiedpicklist', picklists.pullboardProgramsCertified);
				component.set('v.payeeTypeMap', picklists.payeeTypeWrapper);
				this.setPayeeTypes(component);
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},

	setEffectiveDates: function(component) {
		var currentYear = new Date().getFullYear();
		var minDate = $A.localizationService.formatDate(new Date(currentYear-1, 0, 1), 'YYYY-MM-DD');
		var maxDate = $A.localizationService.formatDate(new Date(currentYear, 11, 31), 'YYYY-MM-DD');
		component.set('v.minEffectiveDate', minDate);
		component.set('v.maxEffectiveDate', maxDate);
	},

	setPayeeTypes: function(component) {
		var payeeTypes = [];
		var payeeTypeMap = component.get('v.payeeTypeMap');
		for (var i=0; i<payeeTypeMap.length; i++) {
			var enrollmentEntry = payeeTypeMap[i];
			if (enrollmentEntry.enrollmentType.startsWith('Market_Challenge') && component.get('v.case.' + enrollmentEntry.enrollmentType) == 'Pay Individual') {
				payeeTypes.push(enrollmentEntry.picklistEntry);
			}
		}
		component.set('v.payeeTypes', payeeTypes);
	},

	resetPayees: function(component) {
		var payees = [];
		component.set('v.payees', payees);
	},

	addPayee: function(component) {
		var payees = component.get('v.payees');
		var newPayee = new Object();
		newPayee.SPIN_ID__c = '104';
		payees.push(newPayee);
		component.set('v.payees', payees);
	},

	removePayee: function(component) {
		var payees = component.get('v.payees');
		if(payees.length > 0) {
			payees.pop();
			component.set('v.payees', payees);
		}
	},

	setPayeeEnable: function(component) {
		var payeeTypes = component.get('v.payeeTypes');
		component.set('v.enablePayees', (payeeTypes.length > 0));
	},

	fireSubmitEvent : function(component) {
		if(!this.validate(component)) {
			return;
		}
		var event = component.getEvent('formSubmission');
		event.setParams({
			case : component.get('v.case'),
			payees : component.get('v.payees')
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