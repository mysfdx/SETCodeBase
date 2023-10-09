({
	submitForm: function(component, event) {
		this.toggleSpinner(component);
		var action = this.initiateInsertCallback(component, event);
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				var caseObject = response.getReturnValue();
                console.log('caseObject Challenge__c is  '+ caseObject.Challenge__c);
                console.log('caseObject.CaseNumber is  '+ caseObject.CaseNumber);
                console.log('caseObject.Form Name is  '+ caseObject.Form_Name__c);
                 console.log('caseObject is  '+ caseObject);
                
				 //ACCT ACH PTS AUTHORIZE Change
                if(component.get('v.formType')!=='INC ACH Authorization' &&
                  caseObject.Challenge__c!=='Presold'){
                    location.assign('/Forms/s/thank-you?id=' + caseObject.Id + '&object_label=Case%20Number&object_value=' + caseObject.CaseNumber);
                }
                else if(caseObject.Challenge__c==='Presold'){
                   location.assign('/Forms/s/thank-you?id=' + caseObject.Id + '&object_label=Case%20Number&case_challenge=Presold&object_value=' + caseObject.CaseNumber); 
                }
                else if(component.get('v.formType')==='INC ACH Authorization'){
                component.set('v.parentCaseId', caseObject.Id);
                component.set('v.parentCaseNumber', caseObject.CaseNumber);    
                console.log('Parent Case id is  '+ caseObject.Id); 
                component.set('v.validatingForm', false);
                    //this.toggleSpinner(component);
                }
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				this.toggleSpinner(component);
				alert('ERROR: ' + response.getError()[0].message);
				console.log('response.getError '+ JSON.stringify(response.getError()));
			}
		});
		$A.enqueueAction(action);
	},

	initiateInsertCallback: function(component, event) {
		var action = component.get('c.insertForm');
		var formObject = new Object();
		formObject.caseRecord = event.getParam('case');
		formObject.payees = event.getParam('payees');
		formObject.vehicles = event.getParam('vehicles');
		formObject.vinEntries = event.getParam('vinEntries');
		formObject.vins = event.getParam('vins');

		action.setParams({ formObject : JSON.stringify(formObject) });
        console.log('formObject '+JSON.stringify(formObject.caseRecord));
		return action;
	},

	toggleSpinner: function(component) {
		var validating = component.get('v.validatingForm');
		if (validating) {
			component.set('v.validatingForm', false);
		} else {
			component.set('v.validatingForm', true);
		}
	}
});