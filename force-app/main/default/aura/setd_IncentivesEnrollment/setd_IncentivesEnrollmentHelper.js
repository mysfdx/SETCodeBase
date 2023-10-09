/**
 * Created by jeremyasmith on 2019-04-01.
 */
({
    initCase: function (cmp) {
        console.log('initing case');
        var action = cmp.get("c.getCaseInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.caseInfo", response.getReturnValue());
                var c = cmp.get("v.caseInfo.c");
                c.sObjectType = 'Case';
                c.Form_Name__c = 'INC Enrollment';
                cmp.set("v.case", c);
            }
        });
        $A.enqueueAction(action);
    },
    initPicklists: function(cmp) {
        var action = cmp.get("c.getPicklists");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.picklists", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    initPayees: function(cmp) {
        var action = cmp.get("c.getPayees");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.payees", response.getReturnValue());
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

        //Set the payees up for insert
        var payees = cmp.get("v.payees");
        var payees_up = Array();
        for(var i=0; i<payees.length; i++) {
            if(payees[i].Payee_Type__c || payees[i].First_Name__c || payees[i].Last_Name__c || payees[i].SPIN_ID__c) {
                payees[i].sObjectType = 'Payee__c';
                payees_up.push(payees[i]);
            }
        }

        console.log('inserting case');
        var action = cmp.get("c.insertCase");
        action.setParams({ c : cmp.get("v.case"), payees : payees_up});
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