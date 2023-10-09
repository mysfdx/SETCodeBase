({
	initForm: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.resetForm(component);
	},

	resetForm: function(component) {
		this.resetVehicles(component);
		this.resetVehicleInput(component);
		var action = component.get('c.getCaseInfo');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var caseInfo = response.getReturnValue();
				component.set('v.case', caseInfo.caseObject);
				component.set('v.account', caseInfo.accountObject);
				component.set('v.contact', caseInfo.contactObject);
				component.set('v.user', caseInfo.userObject);
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},

	resetVehicles: function(component) {
		var vehicles = [];
		component.set('v.vehicleCollection', vehicles);
	},

	resetVehicleInput: function(component) {
		var inputVehicle = new Object();
		inputVehicle.Model_Number__c = '';
		inputVehicle.Quantity__c = '';
		inputVehicle.Color__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_1__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_2__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_3__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_4__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_5__c = '';
		inputVehicle.Factory_Installed_Option_Accessory_6__c = '';
		inputVehicle.Port_Installed_Option_1__c = '';
		inputVehicle.Port_Installed_Option_2__c = '';
		inputVehicle.Port_Installed_Option_3__c = '';
		inputVehicle.Port_Installed_Option_4__c = '';
		component.set('v.inputVehicle', inputVehicle);
	},

	addNewVehicle: function(component, inputVehicle) {
		var vehicleCollection = component.get('v.vehicleCollection');
		vehicleCollection.push(inputVehicle);
		component.set('v.vehicleCollection', vehicleCollection);
	},

	removeVehicle: function(component, vehicleIndex) {
		var updatedVehicleCollection = [];
		var vehicleCollection = component.get('v.vehicleCollection');
		for(var i=0; i<vehicleCollection.length; i++) {
			if (i != vehicleIndex) {
				updatedVehicleCollection.push(vehicleCollection[i]);
			}
		}
		component.set('v.vehicleCollection', updatedVehicleCollection);
	},

	fireSubmitEvent : function(component) {
		if(!this.validate(component)) {
			return;
		}
		this.handleOnBehalfFlag(component);
		var event = component.getEvent('formSubmission');
		event.setParams({
			case : component.get('v.case'),
			vehicles : component.get('v.vehicleCollection')
		});
		event.fire();
	},

	validate: function(component) {
		var allValid = component.find('inputField').reduce(function(valid, input) {
			input.showHelpMessageIfInvalid();
			return valid && !input.get('v.validity').valueMissing && input.checkValidity();
		}, true);
		if (allValid) {
			if (!this.validateDeliveryDates(component)) {
				alert('Earliest Requested Date cannot be in the past');
				allValid = false;
			}
			if (!this.isValidDeliveryDateWindow(component)) {
				alert('Delivery Dates need to be a minimum 15 days apart');
				allValid = false;
			}
			if (component.get('v.vehicleCollection').length == 0) {
				alert('Please enter Vehicle information');
				allValid = false;
			}
		} else {
			alert('Please update the invalid form entries and try again.');
		}
		return allValid;
	},

	validateDeliveryDates: function(component) {
		var earliestDeliveryDate = new Date(component.get('v.case.Earliest_Requested_Delivery_Date__c'));
		return (earliestDeliveryDate >= new Date(component.get('v.today')));
	},

	isValidDeliveryDateWindow: function(component) {
		var earliestDate = new Date(component.get('v.case.Earliest_Requested_Delivery_Date__c'));
		var latestDate = new Date(component.get('v.case.Latest_Requested_Delivery_Date__c'));
		var timeDifference = latestDate.getTime() - earliestDate.getTime();
		var dayDifference = timeDifference / (1000 * 3600 * 24);
		return !(dayDifference < 15 && dayDifference > 0);
	},

	handleOnBehalfFlag: function (component) {
		var onBehalf = component.get('v.onBehalfFlag');
		var picklistValue = onBehalf ? 'Yes' : 'No';
		component.set('v.case.Submitted_On_Behalf_Of_Dealer__c', picklistValue);
	}
});