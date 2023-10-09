({
	doInit: function(component, event, helper) {
		helper.init(component);
	},

	handleRequiredDocuments: function(component, event, helper) {
		helper.setRequiredDocuments(component);
	},

	handleClear: function (component, event, helper) {
		helper.resetForm(component);
	},

	handlePrint: function (component, event, helper) {
		window.print();
	},

	handleSubmit: function (component, event, helper) {
         helper.showSpinner(component);
        if(component.get('v.dupNoMatchFound')){
            $A.get('e.force:refreshView').fire();
        }
        else{
           helper.fireSubmitEvent(component); 
        }
		 helper.hideSpinner(component);
	}
});