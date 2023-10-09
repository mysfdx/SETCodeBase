({
	doInit : function(component, event, helper) {
		var action = component.get("c.getFacilityInfo");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var result=response.getReturnValue();
                console.log('SUCCESS '+response.getReturnValue());
                component.set('v.FacilityList', response.getReturnValue());
                console.log('v.FacilityList '+component.get('v.FacilityList')[1].Lifts);
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