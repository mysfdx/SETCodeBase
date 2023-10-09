({
	init: function(component) {
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		this.resetForm(component);
		this.setVinDatatable(component);
		this.setPicklistOptions(component);
	},

	setVinDatatable: function(component) {
		var columns = [
			{label: 'VIN Number', fieldName: 'value', type: 'text', cellAttributes: { alignment: 'left' }},
			{type: 'button', initialWidth: 100, cellAttributes: { alignment: 'center' },
				typeAttributes: {
					label: 'Remove',
					variant: 'destructive'
			}}
		];
		component.set('v.vinDatatableColumns', columns);
	},

	setPicklistOptions: function(component) {
		var reasonRequestAction = component.get('c.getReasonRequests');
		reasonRequestAction.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.reasonRequests', response.getReturnValue());
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(reasonRequestAction);

		var shippingOptionsAction = component.get('c.getShippingOptions');
		shippingOptionsAction.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.shippingOptions', response.getReturnValue());
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(shippingOptionsAction);
	},

	resetForm: function(component) {
		this.resetVinCollection(component);
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

	resetVinCollection: function(component) {
		var vinEntries = [];
		component.set('v.vins', vinEntries);
	},

	addValidVin: function(component, isValidVin) {
		if (isValidVin) {
			this.addEntryToVins(component);
		}
	},

	addEntryToVins: function(component) {
		var inputVin = component.get('v.inputVIN');
		var vins = component.get('v.vins');
		vins.push(inputVin);
		component.set('v.vins', vins);
	},

	removeVinByIndex: function(component, index) {
		var updatedVins = [];
		var vins = component.get('v.vins');
		for (var i = 0; i < vins.length; i++) {
			if (i != index) {
				updatedVins.push(vins[i]);
			}
		}
		component.set('v.vins', updatedVins);
	},

	fireSubmitEvent : function(component) {
		if(!this.validate(component)) {
			return;
		}
		var event = component.getEvent('formSubmission');
		event.setParams({
			case : component.get('v.case'),
			vinEntries : component.get('v.vins')
		});
		event.fire();
	},

	validate: function(component) {
		var allValid = component.find('inputField').reduce(function(valid, input) {
			input.showHelpMessageIfInvalid();
			return valid && !input.get('v.validity').valueMissing && input.checkValidity();
		}, true);
		if (allValid) {
			if (component.get('v.vins').length > 0) {
				return true;
			} else {
				alert('Enter Vehicle Information before submitting');
			}
		} else {
			alert('Please update the invalid form entries and try again.');
		}
		return false;
	}
});