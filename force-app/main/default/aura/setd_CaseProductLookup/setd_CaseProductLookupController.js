/**
 * Created by Sean Wallace, Salesforce Developer,
 * Ad Victoriam Solutions on 9/11/19.
 */


({
    init: function (cmp, evt, hlp) {
        hlp.getParams(cmp, window.location.search);
        hlp.loadProductOptions(cmp);
    },
    productSelected: function (cmp, evt, hlp) {
        // console.log('productSelected',cmp.get('v.selectedProductId'));
        // cmp.get('v.products').map(function(p){
        //     console.log(p.selected);
        // });
        var caseProductUpdate = $A.get("e.c:setd_CaseProductEvt");
        caseProductUpdate.setParams({
            "productId": cmp.get('v.selectedProductId')
        });
        caseProductUpdate.fire();
    }
});