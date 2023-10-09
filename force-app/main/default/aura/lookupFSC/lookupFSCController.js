({
    doInit: function (component, event, helper) {
        helper.hlpCheckValidity(component, event);
        helper.getParams(component, window.location.search);
    },
    handleCaseProductEvt: function (component, event, helper) {
        if(event.getParam('productId')){
            component.set('v.selectedValue',event.getParam('productId'));
			}
    }
});