/**
 * Created by Sean Wallace, Salesforce Developer,
 * Ad Victoriam Solutions on 9/12/19.
 */


({
    pullKnowledgeArticle: function(cmp){
        var action = cmp.get('c.getRelatedArticles');
        action.setParams({
            productId: cmp.get('v.selectedProductId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                //handle success
                var result = response.getReturnValue();
                // console.log('pullKnowledgeArticle',result);
                result.map(function (article) {
                    if($A.util.isEmpty(article.FirstPublishedDate)){
                        article.FirstPublishedDate = null;
                    }
                });
                cmp.set('v.knowledgeArticles',result);
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