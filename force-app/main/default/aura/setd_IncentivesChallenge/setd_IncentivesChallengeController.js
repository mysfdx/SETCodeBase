/**
 * Created by jeremysmith on 2019-03-12.
 */
({
    init: function(cmp, evt, hlp) {
        console.log('init');
        hlp.initCase(cmp);
        hlp.initChallenges(cmp);
        hlp.initForm(cmp);
    },
    handleSubmit: function (cmp, evt, hlp) {
        hlp.submitForm(cmp);
        //hlp.navigate(cmp);
    },
    handleClear: function (cmp, evt, hlp) {
        hlp.initCase(cmp);
    },
    handleVin: function (cmp, evt, hlp) {
        console.log('handling vin change');
        hlp.lookupVin(cmp);
    },
    handlePrint: function (cmp, evt, hlp) {
        window.print();
    },
    handleFilesChange: function (cmp, evt, hlp) {
        var files = evt.getSource().get("v.files");
        cmp.set("v.files", files);
        //alert(files.length + ' files !!');
        hlp.saveFiles(cmp);
    }
})