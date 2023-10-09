({
    init: function(component, event, helper) {
        helper.initForm(component);
        
    },
    
    handleAuthorizedUser: function(component, event, helper) {
		var isAuthorized = (event.getParam('value') == 'YES');
		component.set('v.case.Dealer_Signature__c', isAuthorized);
	},

	handleClear: function(component, event, helper) {
		helper.resetForm(component);
        component.set('v.proceedBtnDisabled',false);
        component.set('v.fileUploadDisabled', true);
		component.set('v.isAuthorizedUser', null);
		component.set('v.case.Dealer_Signature__c', null);
	},

	handlePrint: function(component, event, helper) {
		component.set('v.pendingPrint', false);
		window.print();
	},

	handleSubmit: function(component, event, helper) {
		helper.fireSubmitEvent(component);
	},
    handleVoidCheck: function (component, event) {
        // Get the list of uploaded files
        component.set("v.voidCheckUpload", true);
    },
    handleSignForm: function (component, event) {
        // Get the list of uploaded files
        component.set("v.signFormUpload", true);
    },
    handleActualSubmit:function (component, event) {
       if(!component.get("v.voidCheckUpload"))
        {
            alert("Please upload voided check.");
        }
        else if(!component.get("v.signFormUpload") && 
           component.get("v.isAuthorizedUser") === 'NO'){
            alert("Please upload signed form.");
        }
        else {
             location.assign('/Forms/s/thank-you?id=' + component.get("v.caseId") + '&object_label=Case%20Number&object_value=' + component.get("v.caseNumber"));
       }
    }
});