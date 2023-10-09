/**
 * Created by Sean Wallace, Salesforce Developer,
 * Ad Victoriam Solutions on 9/12/19.
 */


({
    init: function (cmp, evt, hlp) {

    },
    handleProductUpdate: function (cmp, evt, hlp) {
        if(evt.getParam('productId')){
            cmp.set('v.selectedProductId',evt.getParam('productId'));
            hlp.pullKnowledgeArticle(cmp);
        }
    }
});