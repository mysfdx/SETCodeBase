/**
 * Created by Sean Wallace, Salesforce Developer,
 * Ad Victoriam Solutions on 9/11/19.
 */


({
    getParams: function(cmp, url){
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
            self.updateCurrentAppId(cmp, params['APPID']);
        }
        else{
            console.log(params['APPID']);
            self.updateCurrentAppId(cmp, 'DD');
        }
    },
    updateCurrentAppId: function(cmp, appId){
        var action = cmp.get('c.updateUserCurrentAppId');
        action.setParams({
            appId: appId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                //handle success
                var result = response.getReturnValue();
                // console.log('response',JSON.stringify(result));
                cmp.set('v.selectedProductId',result);
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
    },
    loadProductOptions: function (cmp) {
        var action = cmp.get('c.getProductOptions');
        action.setParams({
            parentProduct: cmp.get('v.parentProductId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                //handle success
                var selectedProductId = cmp.get('v.selectedProductId');
                var productSelect = cmp.find('productSelect');
                var result = response.getReturnValue();
                // console.log('options',result);
                result.map(function (p) {
                    if(selectedProductId == p.Id){
                        p.selected = true;
                    }
                    else{
                        p.selected = false;
                    }
                });
                cmp.set('v.products',result);
                if(!$A.util.isEmpty(selectedProductId)){
                    var caseProductUpdate = $A.get("e.c:setd_CaseProductEvt");
                    caseProductUpdate.setParams({
                        "productId": cmp.get('v.selectedProductId')
                    });
                    caseProductUpdate.fire();
                }
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