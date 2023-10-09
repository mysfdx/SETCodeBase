/**
 * Created by jeremysmith on 2019-03-23.
 */
({
    initForm: function(cmp) {
        var action = cmp.get("c.getCommunityUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.user", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    initCase: function (cmp) {
        var c = new Object();
        c.sObjectType = 'Case';
        c.Form_Name__c = 'Incentives Challenge';
        cmp.set("v.case", c);
    },
    initChallenges: function(cmp) {
        var action = cmp.get("c.getChallenges");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.challenges", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    submitForm: function(cmp) {
        if(!this.validate(cmp)) {
            return;
        }
        console.log('inserting case');
        var action = cmp.get("c.insertCase");
        // var binaries = cmp.get("v.binaries");
        // console.log('binaries: ' + JSON.stringify(binaries));
        // action.setParams({ c : cmp.get("v.case"), binaries : binaries });
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
    // navigate: function (cmp) {
    //     //window.location = "/Forms/s/recordlist/Case/00B46000001zrtaEAA";
    // },
    // saveFiles : function (cmp) {
    //     var files = cmp.get("v.files");
    //     for(var i=0;i<files.length;i++) {
    //         var reader = new FileReader();
    //         const filename = files[0].filename;
    //         reader.onloadend = function(evt) {
    //             if (evt.target.readyState == FileReader.DONE) { // DONE == 2
    //                 var binary = window.btoa(evt.target.result);
    //                 var arr = cmp.get("v.binaries");
    //                 arr.push(binary);
    //                 cmp.set("v.binaries", arr);
    //                 var fnames = cmp.get("v.filenames");
    //                 fnames.push(filename);
    //                 cmp.set("v.fnames", fnames);
    //             }
    //         }
    //         reader.readAsBinaryString(files[i]);
    //     }
    // }
})