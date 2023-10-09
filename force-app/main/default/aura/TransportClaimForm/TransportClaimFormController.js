({
    init : function (component,event,helper) {
        helper.toggleTwoAndThreeSteps(component);
        helper.getTransportClaimInfo(component);
        helper.getDealerCodeOptions(component);
        helper.setRadioGroupOptions(component);    
        console.log("Transport claim id is ", component.get("v.tranportClaimId"));
    },
    goToStepTwo : function(component, event, helper) {
        console.log('Selected Dealer Code id is ',component.get("v.transportclaim.Dealer__c") );
        helper.toggleOneAndTwoSteps(component);
    },
    
    goToStepThree : function(component, event, helper) {
        helper.toggleTwoAndThreeSteps(component);
    },
    goBackToStepOne : function(component, event, helper) {
        helper.toggleOneAndTwoSteps(component);
    },
    goBackToStepTwo : function(component, event, helper) {
        helper.toggleTwoAndThreeSteps(component);
    },
    handleLookupEvent:function(component, event, helper){
        var selectedRecordId = event.getParam("recordId");
        var selecteddealerName = event.getParam("recordName");
        console.log("in primary component Selected Dealer Code is", selecteddealerName);
        component.set("v.selectedRecordId", selectedRecordId);
        component.set("v.selecteddealerName", selecteddealerName);
    },
    handleSubmit:function(component, event, helper){
        
        helper.insertClaim(component);
    },
    
    handleBOLUploadFinished: function (component, event) {
        // Get the list of uploaded files
        component.set("v.bolUploadCheck", true);
    },
    handleImageUploadFinished: function (component, event) {
        // Get the list of uploaded files
        component.set("v.imageUploadCheck", true);
    },
    /*handleROUploadFinished: function (component, event) {
        // Get the list of uploaded files
        component.set("v.roUploadCheck", true);
    },*/
    handleFinalSubmit:function(component, event, helper){
        if(!component.get("v.bolUploadCheck"))
        {
            alert("Please provide the signed BOL.");
        }
        else if (!component.get("v.imageUploadCheck")){
            alert("Please provide at least one picture.");
        }
           else{
                    location.assign('transportation-claim/' + component.get('v.tranportClaimId'));
                    helper.sendEmail(component);
                }
        
    }
    
})