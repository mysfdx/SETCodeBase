({
    doInit : function(component, event, helper) {
        helper.resetForm(component);
        component.set("v.disableSubmitButton", false);
        const params = new URLSearchParams(window.location.search);
        if(params.has('vin')){
            console.log('vin is '+params.get('vin'));
            component.set("v.VinNumber", params.get('vin'));
        }
        
    },
    handleClear: function(component, event, helper){
        window.location.reload()
    },
    handleSubmit: function(component, event, helper){
        var subBtn=component.find('submitBtn').get("v.label");
        console.log('subBtn '+ subBtn);
        helper.handleSubmitHelper(component);
        //component.set("v.disableSubmitButton", false);
        //event.getSource().set("v.label","Submit");
    },
    
    handleBackhaulEvent:function(component, event, helper){
        console.log("Event Handling");
        component.set("v.cost", "");
        component.set("v.costAPIErrorText","");
        component.set("v.estimatedCostText", "Loading...");
        var action = component.get("c.returnBackhaulCost");
        action.setParams({
            "dlrNum" : component.get("v.contact.Primary_Dealer_Code__c"),
            "fromDlr" : component.get("v.fromAccount.Dealer_Code__c"),
            "VIN": component.get("v.VinNumber")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.estimatedCostText", "");
                
                var result=response.getReturnValue();
                if(result.includes("Backhaul Request Failed")){
                    console.log('Cost not found');
                    component.set("v.costAPIErrorText",result);
                    let toastEvent1 = $A.get("e.force:showToast");
                    toastEvent1.setParams({
                        title : 'Warning',
                        message: result,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'dismissible'
                    });
                    toastEvent1.fire();
                    component.set("v.disableSubmitButton", true);
                }
                else if(parseFloat(result) ){
                    console.log('Cost found');
                    component.set("v.cost",result);  
                }
                    else {
                        component.set("v.costAPIErrorText",result);
                        component.set("v.disableSubmitButton", true);
                        let toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            title : 'Warning',
                            message: result,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'warning',
                            mode: 'dismissible'
                        });
                        toastEvent2.fire();
                    }
              
                console.log('SUCCESS '+response.getReturnValue());
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
    }
})