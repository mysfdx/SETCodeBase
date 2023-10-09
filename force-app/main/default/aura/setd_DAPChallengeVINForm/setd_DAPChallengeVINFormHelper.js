({
	init: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.resetForm(component);
	},

	resetForm: function(component) {
		this.resetVins(component);
		this.resetVinInput(component);
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

	resetVins: function(component) {
		var vins = [];
		component.set('v.vinCollection', vins);
	},

	resetVinInput: function(component) {
		var inputVin = new Object();
		inputVin.Name = null;
		inputVin.Process_Date__c = null;
		inputVin.Retail_Date__c = null;
		inputVin.Model_Number__c = null;
		inputVin.Customer_Name__c = null;
		inputVin.Lease_Co_Name__c = null;
		component.set('v.inputVin', inputVin);
	},

	addNewVin: function(component, inputVin) {
		var vinCollection = component.get('v.vinCollection');
		vinCollection.push(inputVin);
		component.set('v.vinCollection', vinCollection);
	},

	removeVin: function(component, vinIndex) {
		var updatedVinCollection = [];
		var vinCollection = component.get('v.vinCollection');
		for(var i=0; i<vinCollection.length; i++) {
			if (i != vinIndex) {
				updatedVinCollection.push(vinCollection[i]);
			}
		}
		component.set('v.vinCollection', updatedVinCollection);
	},

	fireSubmitEvent : function(component) {
		if(!this.validate(component)) {
			return;
		}
		var event = component.getEvent('formSubmission');
		event.setParams({
			case : component.get('v.case'),
			vins : component.get('v.vinCollection')
		});
		event.fire();
	},

	validate: function(component) {
		var allValid = component.find('inputField').reduce(function(valid, input) {
			input.showHelpMessageIfInvalid();
			return valid && !input.get('v.validity').valueMissing && input.checkValidity();
		}, true);
		if (allValid) {
			if (component.get('v.vinCollection') && component.get('v.vinCollection').length > 0) {
				return true;
			} else {
				alert('Please enter vehicle information');
			}
		} else {
			alert('Please update the invalid form entries and try again.');
		}
		return false;
	},
});