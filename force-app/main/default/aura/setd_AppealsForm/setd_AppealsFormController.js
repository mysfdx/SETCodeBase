({
	doInit: function(component, event, helper) {
		helper.initForm(component);
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