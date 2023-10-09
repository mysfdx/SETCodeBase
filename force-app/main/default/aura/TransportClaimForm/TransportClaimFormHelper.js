({
    getTransportClaimInfo:function(component){
        var action = component.get('c.getTransportClaimInfo');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
                var claimInfo=response.getReturnValue();
                console.log('Returned value is ', claimInfo);
				component.set('v.transportclaim', claimInfo.transportClaimObject);
                component.set('v.account', claimInfo.accountObject);
                var acc=claimInfo.accountObject;
                console.log('Returned account is ', acc.Name);
                component.set('v.selectedRecordId', acc.Id);
                
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
    },
    validate: function(component) {
        var invalidLabels="";
		var allValid = component.find('inputField').reduce(function (valid, input) {
			input.showHelpMessageIfInvalid();
            if(!input.get('v.validity').valid) {
                invalidLabels=invalidLabels+input.get('v.label')+"\n";
            }
            console.log(invalidLabels);
            return valid && !input.get('v.validity').valueMissing && input.checkValidity();
            
		}, true);
		if (allValid) {
            console.log('Validation is ',allValid);
			return true;
		} else {
            console.log('Validation is ',allValid);
			alert('Please update the following invalid form entries and try again.'+'\n'+invalidLabels);
		}
		return false;
	},
    setRadioGroupOptions: function(component) {
		this.setCarrierNameOptions(component);
		this.setDeliveryTypeOptions(component);
		this.setVehicleTypeOptions(component);
	},

	toggleOneAndTwoSteps : function(component) {
		var stepOne = component.find("stepOne");
        $A.util.toggleClass(stepOne, 'slds-hide');
        var stepTwo = component.find("stepTwo");
        $A.util.toggleClass(stepTwo, 'slds-hide');
	},
    toggleTwoAndThreeSteps : function(component){
        var stepTwo = component.find("stepTwo");
        $A.util.toggleClass(stepTwo, 'slds-hide');
        var stepThree = component.find("stepThree");
        $A.util.toggleClass(stepThree, 'slds-hide');
    },
    insertClaim:function(component){
       if(!this.validate(component)) {
			return;
		}
        console.log('Select record is ',component.get("v.selectedRecordId"));
        var action = component.get('c.getInsertedClaim');
        console.log("Function Calling and claim is ",component.get("v.transportclaim"));
        console.log("Dealer id is ",component.get("v.selectedRecordId"));
        action.setParams({
            "claim": component.get("v.transportclaim")
                         });
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
                
                console.log("Returned Reposne is ", response.getReturnValue());
				component.set("v.tranportClaimId",response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info',
                    message: 'Please upload the files and then SUBMIT the form.',
                    duration:'6000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.proceedButtonDisabled", true);
                component.set("v.fileUploadDisabled", false);
                
                
                //console.log("Returned Id is ", component.get("v.tranportClaimId"));
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
                
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
    },
    setVehicleTypeOptions: function(component) {
		var action = component.get('c.getVehicleTypeOptions');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.vehicleTypeOptions', response.getReturnValue());
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},
    setDeliveryTypeOptions: function(component) {
		var action = component.get('c.getDeliveryTypeOptions');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
                var options = response.getReturnValue();
				for (var i=0; i<options.length; i++) {
					if (options[i].value == 'Concealed Damage') {
					 options[i].label=options[i].label + ' (notify within 2 days of delivery)';
					} 
                    if (options[i].value == 'After Normal Business Hours') {
					 options[i].label=options[i].label + ' - STI (notify by next business day)';
					} 
                    if (options[i].value == 'Inclement Weather') {
					 options[i].label=options[i].label + ' - STI (notify by next business day)';
					} 
                    
				}
				component.set('v.deliveryTypeOptions', options);
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},
    setCarrierNameOptions: function(component) {
		var action = component.get('c.getCarrierNameOptions');
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
                var options = response.getReturnValue();
				for (var i=0; i<options.length; i++) {
                    if(options[i].value == 'Longhorn'){
                      var seclastVal= options[options.length-2].value;
                      var seclastLab= options[options.length-2].label;
                      options[options.length-2].label=options[i].label;
                      options[options.length-2].value=options[i].value;
                      options[i].label=seclastLab;
                      options[i].value=seclastVal;
                    }
                  if (options[i].value == 'Other') {
                      var lastVal= options[options.length-1].value;
                      var lastLab= options[options.length-1].label;
					  options[options.length-1].label=options[i].label;
                      options[options.length-1].value=options[i].value;
                      options[i].label=lastLab;
                      options[i].value=lastVal;
					} 
  				}
                for (var i=0; i<options.length; i++) {
				 if (options[i].value == 'Auto Carrier Express') {
					 options[i].label=options[i].label + ' (A.C.E.)';
					} 
                  if (options[i].value == 'Southeast Transportation System') {
					 options[i].label=options[i].label + ' (STS)';
                    } 
                }
				component.set('v.carrierNameOptions', options);
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	},
    sendEmail:function(component) {
        var action = component.get('c.sendEmail');
        action.setParams({
            "claimId": component.get("v.tranportClaimId")
        });
		action.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				//component.set('v.vehicleTypeOptions', response.getReturnValue());
			} else if (response.getState() === 'ERROR' && response.getError().length > 0) {
				alert('ERROR: ' + response.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
    },
    getDealerCodeOptions:function(component){
        var action = component.get('c.getDealerCodeOptions');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                //handle success
                var result = response.getReturnValue();
                console.log('Dealer Code options are ',result.length);
                console.log(component.get("v.selectedRecordId"));
                var selectedId= component.get("v.selectedRecordId");
                result.map(function (p) {
                    if(selectedId == p.Id){
                        p.selected = true;
                    }
                    else
                    {
                        p.selected = false;
                    }
               });
                    component.set('v.dealerCodeOptions', result)
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
})