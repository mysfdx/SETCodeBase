/**
 * Created by jeremyasmith on 2019-04-07.
 */
({
    init: function(cmp, evt, hlp) {
        hlp.initCase(cmp);
        hlp.initPicklists(cmp);
    },
    handleSubmit: function (cmp, evt, hlp) {
        hlp.submitForm(cmp);
    },
    handleClear: function (cmp, evt, hlp) {
        hlp.initCase(cmp);
    },
    handlePrint: function (cmp, evt, hlp) {
        window.print();
    },
})