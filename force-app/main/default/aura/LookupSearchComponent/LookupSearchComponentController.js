({
    handleFocus : function(component, event, helper) { 
        var searchText="";
        var resultBox = component.find('resultBox');
        console.log('Result Box ix '+resultBox);
        component.set("v.LoadingText", true);
         $A.util.addClass(resultBox, 'slds-is-open');
        var action = component.get("c.getResults");
        action.setParams({
            "ObjectName" : component.get("v.objectName"),
            "fieldName" : component.get("v.fieldName"),
            "value" : searchText
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.searchRecords", response.getReturnValue());
                if(component.get("v.searchRecords").length == 0) {
                    console.log('000000');
                }
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
            component.set("v.LoadingText", false);
        });
        
        $A.enqueueAction(action);

        
    },
    
    searchField : function(component, event, helper) {
        var currentText = event.getSource().get("v.value");
        var resultBox = component.find('resultBox');
        component.set("v.LoadingText", true);
        //if(currentText.length > 0) {
            $A.util.addClass(resultBox, 'slds-is-open');
        /*}
        else {
            $A.util.removeClass(resultBox, 'slds-is-open');
        }*/
        var action = component.get("c.getResults");
        action.setParams({
            "ObjectName" : component.get("v.objectName"),
            "fieldName" : component.get("v.fieldName"),
            "value" : currentText
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.searchRecords", response.getReturnValue());
                if(component.get("v.searchRecords").length == 0) {
                    console.log('000000');
                }
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
            component.set("v.LoadingText", false);
        });
        
        $A.enqueueAction(action);
    },
    
    setSelectedRecord : function(component, event, helper) {
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        $A.util.removeClass(resultBox, 'slds-is-open');
        //component.set("v.selectRecordName", currentText);
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.selectRecordId", currentText);
        var result=component.get("v.searchRecords");
       result.map(function (p) {
                    if(currentText == p.recId){
                        component.set("v.selectedRecord", p.rec);
						}
                    
                }); 
        component.find('userinput').set("v.readonly", true);
        var backhaulEvent = component.getEvent("backhaulDealerSelectEvent");
         backhaulEvent.setParams({"message" : "From Dealer Selected" });
         backhaulEvent.fire();

    }, 
    
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
         component.set("v.selectedRecord", "");
        component.find('userinput').set("v.readonly", false);
         var resultBox = component.find('resultBox');
         $A.util.addClass(resultBox, 'slds-is-open');
    }
})