({
	init: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.resetForm(component);
		this.initRadioButtons(component);
		this.initReturnToPorts(component);
		this.initVehicleDeliveryStatuses(component);
	},

	resetForm: function(component) {
		var action = component.get('c.getCaseInfo');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var caseInfo = response.getReturnValue();
				component.set('v.user', caseInfo.communityUser);
				component.set('v.account', caseInfo.accountObject);
				component.set('v.contact', caseInfo.contactObject);
				component.set('v.case', caseInfo.caseObject);
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},

	initRadioButtons: function(component) {
		var noBackhaulRequired = 'Someone from the dealership will take the vehicle back to the port. Please schedule an appointment and notify me as to when I should bring the vehicle to port.';
		var backhaulRequired = 'Please set up a backhaul.';
		var radioOptions = [ {'label': noBackhaulRequired, 'value': noBackhaulRequired}, {'label': backhaulRequired, 'value': backhaulRequired} ];
		component.set('v.radioOptions', radioOptions);
	},

	initReturnToPorts: function(component) {
		var action = component.get('c.getReturnToPorts');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.returnToPorts', response.getReturnValue());
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},

	initVehicleDeliveryStatuses: function(component) {
		var action = component.get('c.getVehicleDeliveryStatuses');
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				component.set('v.vehicleDeliveryStatuses', response.getReturnValue());
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},

	isBackhaulPickupScheduled: function(component) {
		var backhaulPickupScheduled = component.get('v.case.How_will_the_vehicle_get_back_to_port__c');
		if(backhaulPickupScheduled == 'Please set up a backhaul.') {
			return true;
		} else {
			return false;
		}
	},

	handleBackhaulPickup: function(component) {
		if (this.isBackhaulPickupScheduled(component)) {
			component.set('v.scheduledBackhaulPickup', true);
			var bufferDate = new Date();
			bufferDate.setDate(bufferDate.getDate() + 3);
			var minBackHaulDate = $A.localizationService.formatDate(bufferDate, 'YYYY-MM-DD');
			component.set('v.minBackhaulDate', minBackHaulDate);
			this.setBackhaulDateRequested(component, minBackHaulDate);
		} else {
			component.set('v.scheduledBackhaulPickup', false);
			this.setBackhaulDateRequested(component, null);
			var caseObject = component.get('v.case');
			caseObject.Backhaul_Confirmation_Number__c = null;
		}
	},

	setBackhaulDateRequested: function(component, dateScheduled) {
		var caseObject = component.get('v.case');
		caseObject.Backhaul_Date_Requested__c = dateScheduled;
		component.set('v.case', caseObject);
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

		if(allValid && this.backHaulDateValidity(component)) {
			return true;
		} else {
			alert('Please update the invalid form entries and try again.');
		}
		return false;
	},

	backHaulDateValidity: function(component) {
		var inputCmp = component.find('inputFieldDate');
		if (inputCmp) {
			return inputCmp.checkValidity();
		}
		return true;
	}
});