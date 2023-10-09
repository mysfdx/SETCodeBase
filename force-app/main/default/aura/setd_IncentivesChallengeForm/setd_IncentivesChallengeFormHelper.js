({
    init: function(component) {
        this.resetForm(component);
        this.setPicklistOptions(component);
    },
    
    resetForm: function(component) {
        var action = component.get('c.getCaseInfo');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var caseInfo = response.getReturnValue();
                component.set('v.user', caseInfo.communityUser);
                component.set('v.contact', caseInfo.contactObject);
                component.set('v.case', caseInfo.caseObject);
            } else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                alert('ERROR: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    setPicklistOptions: function(component) {
        var action = component.get('c.getChallenges');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.challenges', response.getReturnValue());
            } else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                alert('ERROR: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
        var action = component.get('c.getchallengemonth');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.challengemonth', response.getReturnValue());
            } else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                alert('ERROR: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
        var action = component.get('c.getchallengeyear');
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.challengeyear', response.getReturnValue());
            } else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                alert('ERROR: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    setRequiredDocuments: function(component) {
        var challenge = component.get('v.case.Challenge__c');
        var action = component.get('c.getChallengeRequirements');
        action.setParams({ challenge : challenge});
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.requiredDocuments', response.getReturnValue());
            } else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                alert('ERROR: ' + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    /*fireSubmitEvent : function(component) {
        if(!this.validate(component)) {
            console.log('Testing testing '+ component.get('v.dupNoMatchFound'));
			return;
		}
       
        var event = component.getEvent('formSubmission');
        event.setParams({
			case : component.get('v.case'),
			vinEntries : component.get('v.vins')
		});
		event.fire();
    },*/
    
    fireSubmitEvent: function(component) {
        var allValid = component.find('inputField').reduce(function (valid, input) {
            input.showHelpMessageIfInvalid();
            return valid && !input.get('v.validity').valueMissing && input.checkValidity();
        }, true);
        
        if (allValid) {
            var vinNum = component.get('v.case.SET_VIN__c');
            var chlType= component.get('v.case.Challenge__c');
            var action = component.get('c.duplicateCases');
            action.setParams({ vin : vinNum, 
                              chalngType:chlType });
            action.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    var records =response.getReturnValue();
                    if(response.getReturnValue().length>0){
                        component.set('v.dupNoMatchFound', true);
                        component.set('v.columns', [
                            {label: 'Case Number', fieldName: 'caseLink', type: 'url',
                             typeAttributes: {
                                 label: {
                                     fieldName: 'CaseNumber'
                                 },
                                 target: '_blank'
                             }},
                            {label: 'VIN', fieldName: 'SET_VIN__c', type: 'text' },
                             {label: 'Created By', fieldName: 'RTP_Contact_Name__c', type: 'text' },
                            {label: 'Opened Date', fieldName: 'CreatedDate', type: 'date' },
                            {label: 'Challenge', fieldName: 'Challenge__c', type: 'text' },
                           
                            
                        ]);
                        records.forEach(function(record) {
                            record.caseLink = '/' + record.Id;
                        });
                        component.set('v.dupCases', response.getReturnValue());
                        console.log('dup cases are '+component.get('v.dupCases'));
                        window.scrollTo(0, 0);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:'Case can not be submitted due to duplicate cases.',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        //return false;
                        
                    }
                    else{
                        component.set('v.dupNoMatchFound', false); 
                        console.log('inside function ', new Date().toLocaleTimeString([], { hour: '2-digit', minute: "2-digit" }));
                        console.log('v.dupNoMatchFound  is '+component.get('v.dupNoMatchFound'));
                        // return true;
                        var event = component.getEvent('formSubmission');
                        event.setParams({
                            case : component.get('v.case'),
                            vinEntries : component.get('v.vins')
                        });
                        event.fire();
                    }
                } else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                    alert('ERROR: ' + response.getError()[0].message);
                } 
            });
            $A.enqueueAction(action);
            
        } else {
            alert('Please update the invalid form entries and try again.');
        }
        console.log('v.dupNoMatchFound  is testing again '+component.get('v.dupNoMatchFound'));
        console.log('outside function ', new Date().toLocaleTimeString([], { hour: '2-digit', minute: "2-digit" }));
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
});