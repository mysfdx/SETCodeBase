({
    init: function(component, event, helper) {
        if(component.get('v.booleanFeedback')=='true'){
            var encodedFeedback = component.get('v.encodedFeedback');
            var dec = decodeURIComponent(encodedFeedback);// to decode
            var feedbackSub='Feedback: '+dec;
            component.set('v.decodedFeedback',feedbackSub);
            console.log('encodedFeedback',encodedFeedback);
            console.log('decodedFeedback',feedbackSub);
        }
             
            component.set('v.validate', function() {
               // var subjectVal = cmp.get('v.decodedFeedback');
               console.log('IN IT called');
               console.log('component.get("v.decodedFeedback") is '+ 
                           component.get("v.decodedFeedback"));
                if(!$A.util.isUndefined(component.get("v.decodedFeedback")) &&
                  !$A.util.isEmpty(component.get("v.decodedFeedback"))) {
                    // If the component is valid...
                    return { isValid: true };
                }
                else {
                    // If the component is invalid...
                    return { isValid: false, 
                            errorMessage: 'Reason for contact is required.' };
                }
            })
        
    }
})