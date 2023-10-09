({
	initForm: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.resetForm(component);
		this.initPicklistValues(component);
		console.log('INIT: ' + component.get('v.case.Shipment_Action__c'));
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

	initPicklistValues: function(component) {
		var shipmentActionsAction = component.get('c.getShipmentActions');
		shipmentActionsAction.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var shipmentActions = response.getReturnValue();
				for (var i=0; i<shipmentActions.length; i++) {
					if (shipmentActions[i].value == 'DELIVERY_INSTRUCTIONS') {
						shipmentActions[i].label = 'Change Delivery Instructions (Change delivery contact, delivery address, delivery days/times)';
						component.set('v.shipmentActionHeader', '');
					}
					if (shipmentActions[i].value == 'HOLD_STOP') {
						shipmentActions[i].label = 'Hold/Stop Shipments (Hold or Stop shipments for a period of time)';
						component.set('v.shipmentActionHeader', 'Hold/Stop');
					}
					if (shipmentActions[i].value == 'LIMITED_DELIVERY') {
						shipmentActions[i].label = 'Limited Delivery Instructions (Change number of trucks/loads delivered per day)';
						component.set('v.shipmentActionHeader', 'Limited');
					}
				}
				component.set('v.shipmentActions', shipmentActions);
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(shipmentActionsAction);
	},

	clearShipmentActionDetails: function(component) {
		component.set('v.case.Accepted_Trucks_Loads_Per_Day__c', null);
		component.set('v.case.Delivery_Contact_Alt_Phone__c', null);
		component.set('v.case.Delivery_Contact_Email__c', null);
		component.set('v.case.Delivery_Contact_Name__c', null);
		component.set('v.case.Delivery_Contact_Phone__c', null);
		component.set('v.case.Effective_End_Date__c', null);
		component.set('v.case.Effective_Start_Date__c', null);
		component.set('v.case.Dealer_Code_Update__c', null);
		component.set('v.case.Dealer_Name_Update__c', null);
		component.set('v.case.Updated_Delivery_Address__c', null);
		component.set('v.case.Updated_Delivery_Days_and_Timeframes__c', null);
		component.set('v.case.Special_Instructions__c', null);
	},

	handleShipmentActionHeading: function(component) {
		var shipmentAction = component.get('v.case.Shipment_Action__c');
		if (shipmentAction == 'DELIVERY_INSTRUCTIONS') {
			component.set('v.shipmentActionHeader', '');
		}
		if (shipmentAction == 'HOLD_STOP') {
			component.set('v.shipmentActionHeader', 'Hold/Stop');
		}
		if (shipmentAction == 'LIMITED_DELIVERY') {
			component.set('v.shipmentActionHeader', 'Limited');
		}
	},

	handleDeliveryChange: function(component) {
		var shipmentAction = component.get('v.case.Shipment_Action__c');
		if (shipmentAction == 'DELIVERY_INSTRUCTIONS') {
			component.set('v.case.Dealer_Name_Update__c', component.get('v.account.Name'));
			component.set('v.case.Dealer_Code_Update__c', component.get('v.contact.Current_Dealer_Code__c'));
		}
		if (shipmentAction == 'LIMITED_DELIVERY') {
			component.set('v.case.Accepted_Trucks_Loads_Per_Day__c', '1');
		}
	},

	fireSubmitEvent: function(component) {
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
		console.log('---------------------');
		var allValid = component.find('inputField').reduce(function(valid, input) {
			input.showHelpMessageIfInvalid();
			console.log(input.get('v.label') + ': [' + '' + valid + ', ' + !input.get('v.validity').valueMissing + ', ' + input.checkValidity() + '] = ' + input.get('v.value'));
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