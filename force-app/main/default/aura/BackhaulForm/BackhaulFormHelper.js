({
    resetForm: function(component) {
        var action = component.get('c.getCaseInfo');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var caseInfo = response.getReturnValue();
                component.set('v.case', caseInfo.caseObject);
                component.set('v.account', caseInfo.accountObject);
                component.set('v.contact', caseInfo.contactObject);
                console.log('v.contact.PrimaryDealerCode is '+
                            component.get("v.contact.Primary_Dealer_Code__c"));
            } else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                alert('ERROR: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSubmitHelper : function(component){
        if(!this.validate(component)) {
            return;
        }
        component.find('submitBtn').set("v.label","Loading...");
        component.set("v.disableSubmitButton", true);
        var action = component.get("c.backhaulRequestSubmission");
        action.setParams({
            "dlrNum" : component.get("v.contact.Current_Dealer_Code__c"),
            "fromDlr" : component.get("v.fromAccount.Dealer_Code__c"),
            "VIN": component.get("v.VinNumber"),
            "frmDlrContact":component.get("v.case.From_Dealer_Contact__c"),
            "toDlrContact":component.get("v.case.To_Dealer_Contact__c"),
            "comments":component.get("v.case.DS_Comment__c"),
            "backhaulCase":component.get("v.case"),
            "cost":component.get("v.cost")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log('result is '+result);
                if(result.includes("COMPLETE") && result.includes("false")){
                    var successToast = $A.get("e.force:showToast");
                    successToast.setParams({
                        title : 'Success',
                        message: result.replace("false", " "),
                        duration:'5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'sticky'
                    });
                    successToast.fire();
                    component.set('v.backhaulConfirmMsg', result.replace("false", " "));
                }
                else{
                    var errorToast = $A.get("e.force:showToast");
                    errorToast.setParams({
                        title : 'Error',
                        message:result.replace("true", " "),
                        duration:'5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'sticky'
                    });
                    errorToast.fire();
                }
                component.find('submitBtn').set("v.label","Submit");
                component.set("v.disableSubmitButton", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    validate: function(component) {
        var allValid = component.find('inputField').reduce(function(valid, input) {
            input.showHelpMessageIfInvalid();
            return valid && !input.get('v.validity').valueMissing && input.checkValidity();
        }, true);
        if(allValid && component.get("v.fromAccount.Dealer_Code__c")){
            return true;
        }
        else{
            alert('Please update the invalid form entries like From Dealer, To Dealer Contact and From Dealer Contact and try again.');
        }
        return false;
    }
    
})