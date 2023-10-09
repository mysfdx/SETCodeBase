({
	doInit: function(component, event, helper) {
		helper.initForm(component);
	},

	handleShipmentAction: function(component, event, helper) {
		helper.clearShipmentActionDetails(component);
		helper.handleShipmentActionHeading(component);
		helper.handleDeliveryChange(component);
	},

	handleClear: function(component, event, helper) {
		$A.get('e.force:refreshView').fire();
	},

	handlePrint: function(component, event, helper) {
		window.print();
	},

	handleSubmit: function(component, event, helper) {
		helper.fireSubmitEvent(component);
	}
});