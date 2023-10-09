({
	doInit: function(component, event, helper) {
		helper.initForm(component);
	},

	handleRequestDate: function(component, event, helper) {
		var earliestDate = component.get('v.case.Earliest_Requested_Delivery_Date__c');
		if (earliestDate) {
			var startDate = new Date(earliestDate);
			var latestDate = $A.localizationService.formatDate(new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + 16), 'YYYY-MM-DD');
			component.set('v.case.Latest_Requested_Delivery_Date__c', latestDate);
			component.set('v.latestDeliveryDate', latestDate);
		}
	},

	handleNewVehicle: function(component, event, helper) {
		var inputVehicle = event.getParam('inputVehicle');
		helper.addNewVehicle(component, inputVehicle);
	},

	handleRemoveVehicle: function(component, event, helper) {
		var vehicleIndex = event.getParam('vehicleIndex');
		helper.removeVehicle(component, vehicleIndex);
	},

	handleClear: function(component, event, helper) {
		helper.resetForm(component);
	},

	handlePrint: function(component, event, helper) {
		window.print();
	},

	handleSubmit: function(component, event, helper) {
		helper.fireSubmitEvent(component);
	}
});