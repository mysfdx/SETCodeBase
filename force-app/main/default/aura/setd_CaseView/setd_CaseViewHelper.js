({
    initForm: function(component) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getFields');
        action.setParams({ recordId : recordId });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var caseFields = response.getReturnValue();
                component.set('v.caseFields', caseFields);
            } else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                //Showtoast event added by Neha Agrawal during Incentive Dashboard project
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info',
                    message: 'This challenge has been submitted by another user.',
                    duration:' 6000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'sticky'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
        
        //ww query for readonly access
        var action = component.get('c.isPortalUser');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var isPortalEnabled = response.getReturnValue();
                if (isPortalEnabled){
                    component.set('v.formMode', 'readonly');
                }				
            } else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                alert('ERROR: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    }
})