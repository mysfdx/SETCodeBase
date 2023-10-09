({
	init: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.resetForm(component);
		this.setPicklistValues(component);
	},

	resetForm: function(component) {
		component.find('signature').set('v.value', null);
		this.clearTitledVehicleOptions(component);
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

	clearTitledVehicleOptions: function(component) {
		var noOption = component.find('titledVehicleNo');
		noOption.set('v.value', null);
		var yesOption = component.find('titledVehicleYes');
		yesOption.set('v.value', null);
	},

	setPicklistValues: function(component) {
		this.setDupliateReasons(component);
		this.setTitledVehicleOptions(component);
		this.setModelYears(component);
	},

	setDupliateReasons: function(component) {
		var action = component.get('c.getReasonForDuplicates');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.reasonForDuplicates', response.getReturnValue());
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},

	setTitledVehicleOptions: function(component) {
		var action = component.get('c.getTitledVehicleOptions');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var options = response.getReturnValue();
				for (var i=0; i<options.length; i++) {
					if (options[i].value == 'Yes') {
						component.set('v.titledVehicleYesLabel', options[i].label + ' - Dealership affirms that the vehicle has been titled in error. Dealership acknowledges that it will retain proof of the cancelled title and that the vehicle must be sold as used if it was previously sold and driven off of the lot.');
					} else {
						component.set('v.titledVehicleNoLabel', options[i].label + ' - Dealership affirms that the motor vehicle has not been titled in any state.');
					}
				}
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},

	setModelYears: function(component) {
		var modelYears = [];
		var startYear = new Date().getFullYear() - 3;
		for(var i=0; i<5; i++) {
			modelYears.push(startYear + i);
		}
		component.set('v.modelYears', modelYears);
	},

	setTitledVehicle: function(component, value) {
		component.set('v.case.Vehicle_Titled__c', value);
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
		var validAffirmations = this.validateAffirmation(component);
		var validTitledVehicle = this.validateTitledVehicle(component);
		if (allValid && validAffirmations && validTitledVehicle) {
			var signatureValue = component.find('signature').get('v.value');
			var isAuthorizedUser = (signatureValue == null) ? false : signatureValue;
			component.set('v.case.Dealer_Signature__c', isAuthorizedUser);
			if (component.get('v.pendingPrint') && !isAuthorizedUser) {
				alert('Forms submitted by non-authorized personnel will not be accepted by Southeast Toyota.');
			} else {
				return true;
			}
		} else {
			alert('Please update the invalid form entries and try again.');
		}
		return false;
	},

	validateAffirmation: function(component) {
		var officerName = component.find('officerName').get('v.value');
		if (officerName) {
			$A.util.removeClass(component.find('officerNameError'), 'errorShow');
			return true;
		} else {
			$A.util.addClass(component.find('officerNameError'), 'errorShow');
		}

		var officerTitle = component.find('officerTitle').get('v.value');
		if (officerTitle) {
			$A.util.removeClass(component.find('officerTitleError'), 'errorShow');
			return true;
		} else {
			$A.util.addClass(component.find('officerTitleError'), 'errorShow');
		}

		return (officerName && officerTitle);
	},

	validateTitledVehicle: function(component) {
		var titledVehicle = component.get('v.case.Vehicle_Titled__c');
		if (titledVehicle) {
			$A.util.removeClass(component.find('titledVehicleError'), 'errorShow');
			return true;
		} else {
			$A.util.addClass(component.find('titledVehicleError'), 'errorShow');
			return false;
		}
	}
});