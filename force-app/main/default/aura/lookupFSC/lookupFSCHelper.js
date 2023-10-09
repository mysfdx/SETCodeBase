({
    hlpCheckValidity: function (component, event) {
        component.set("v.validate", function () {
            var selectedValue = component.get("v.selectedValue");
            var required = component.get("v.required");
            var label = component.get("v.label");

            if (!required || (selectedValue && !$A.util.isEmpty(selectedValue))) {
                return {
                    isValid: true
                };
            } else {
                return {
                    isValid: false,
                    errorMessage: "A selection is required for: " + label
                };
            }
        });
    },
    getParams: function(component, url){
        var self = this;
        var params = {};
        var parser = document.createElement('a');
        parser.href = url;
        var query = parser.search.substring(1);
        var vars = query.split('&');
        for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split('=');
            params[pair[0]] = decodeURIComponent(pair[1]);
        }
        if(!$A.util.isEmpty(params['APPID'])){
            console.log(params['APPID']);
            self.updateCurrentAppId(component, params['APPID']);
        }
        /*else{
            console.log(params['APPID']);
            self.updateCurrentAppId(component, 'DD');
        }*/
    },
    updateCurrentAppId: function(component, appId){
        var action = component.get('c.updateUserCurrentAppId');
        action.setParams({
            appId: appId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                //handle success
                var result = response.getReturnValue();
                console.log('response',JSON.stringify(result));
                console.log('default Id is',result.Id);
                console.log('default name is',result.Name);
                component.set('v.actualRecord',result);
                component.set('v.selectedValue',result.Id);
                component.set('v.actualProductName',result.Name);
                /*if(!$A.util.isEmpty(result.Id)){
                    var caseProductUpdate = $A.get("e.c:setd_CaseProductEvt");
                    
                    caseProductUpdate.setParams({
                      "productId": result.Id

                    });
                    caseProductUpdate.fire();
                }*/
            } else if (state === 'INCOMPLETE') {
                //handle incomplete
            } else if (state === 'ERROR') {
                //handle error
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});