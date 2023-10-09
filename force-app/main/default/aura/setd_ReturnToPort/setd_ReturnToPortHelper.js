/**
 * Created by jeremyasmith on 2019-04-01.
 */
({
    initCase: function (cmp) {
        var action = cmp.get("c.getCaseInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.caseInfo", response.getReturnValue());
                var c = cmp.get("v.caseInfo.c");
                var contact = cmp.get("v.caseInfo.contact");
                c.sObjectType = 'Case';
                c.Form_Name__c = 'Return to Port';
                c.How_will_the_vehicle_get_back_to_port__c = cmp.get("v.radio1");
                c.RTP_Contact_Name__c = contact.FirstName + ' ' + contact.LastName;
                c.RTP_Contact_Phone__c = contact.Phone;
                cmp.set("v.case", c);
            }
        });
        $A.enqueueAction(action);
    },
    lookupVin: function(cmp) {
        var action = cmp.get("c.getVinDetails");
        action.setParams({ vinNumber : cmp.get("v.case.SET_VIN__c") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mm =response.getReturnValue();
                //cmp.set("v.case.Model_Number__c", mm.model);
                cmp.set("v.case.Model_Year__c", mm.year);
            }
        });
        $A.enqueueAction(action);
    },
    initReturnToPorts: function(cmp) {
        console.log('return to ports');
        var action = cmp.get("c.getReturnToPorts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.returnToPorts", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    initVehicleDeliveryStatuses: function(cmp) {
        var action = cmp.get("c.getVehicleDeliveryStatuses");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.vehicleDeliveryStatuses", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    validate : function(cmp) {
        var allValid = cmp.find('inpField').reduce(function (valid, inp) {
            inp.showHelpMessageIfInvalid();
            return valid && !inp.get('v.validity').valueMissing;
        }, true);
        if (allValid) {
            return true;
        } else {
            alert('Please update the invalid form entries and try again.');
        }
        return false;
    },
    submitForm: function(cmp) {
        if(!this.validate(cmp)) {
            return;
        }
        console.log('inserting case');
        var action = cmp.get("c.insertCase");
        action.setParams({ c : cmp.get("v.case")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var c = response.getReturnValue();
                console.log('case response: ' + JSON.stringify(c));
                location.assign("/Forms/s/thank-you?id=" + c.Id + "&object_label=Case%20Number&object_value=" + c.CaseNumber);
            }
        });
        $A.enqueueAction(action);
    },

})