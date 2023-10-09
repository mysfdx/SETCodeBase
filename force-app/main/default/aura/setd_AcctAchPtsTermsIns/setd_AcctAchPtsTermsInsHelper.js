/**
 * Created by jeremyasmith on 2019-04-07.
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
                c.Form_Name__c = 'ACCT ACH PTS TERMS/INS';
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