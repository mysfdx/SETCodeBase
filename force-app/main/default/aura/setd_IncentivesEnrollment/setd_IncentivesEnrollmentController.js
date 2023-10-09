/**
 * Created by jeremyasmith on 2019-04-06.
 */
({
    init: function(cmp, evt, hlp) {
        hlp.initCase(cmp);
        hlp.initPicklists(cmp);
        hlp.initPayees(cmp);
    },
    handleVin: function (cmp, evt, hlp) {
        hlp.lookupVin(cmp);
    },
    handleSubmit: function (cmp, evt, hlp) {
        hlp.submitForm(cmp);
    },
    handleClear: function (cmp, evt, hlp) {
        hlp.initCase(cmp);
        hlp.initPayees(cmp);
    },
    handlePrint: function (cmp, evt, hlp) {
        //TODO This approach may work
        //var url = location.origin + '/apex/setd_?id=' + component.get("v.case");
        //window.open(url, '_blank');
        window.print();
    },
    handleAdd: function (cmp, evt, hlp) {
        var payees = cmp.get("v.payees");
        var payee = new Object();
        payees.push(payee);
        cmp.set("v.payees", payees);
    },
    handleRemove: function (cmp, evt, hlp) {
        var payees = cmp.get("v.payees");
        if(payees.length > 1) {
            payees.pop();
            cmp.set("v.payees", payees);
        }
    }

})