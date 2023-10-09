/**
 * Created by jeremyasmith on 2019-04-01.
 */
({
    init: function(cmp, evt, hlp) {
        console.log('init');
        hlp.initCase(cmp);
        hlp.initReturnToPorts(cmp);
        hlp.initVehicleDeliveryStatuses(cmp);
        cmp.find("defaultRadio").set("v.checked", true);
        var check = cmp.get("v.radio1");
        cmp.set("v.case.How_will_the_vehicle_get_back_to_port__c", check);
    },
    handleRadioClick: function (cmp, evt, hlp) {
        console.log('handle radio Click');
        var radio2 = cmp.get("v.radio2");
        var check = evt.getSource().get("v.value");
        //Store the text from the radio button on the field.
        cmp.set("v.case.How_will_the_vehicle_get_back_to_port__c", check)
        if(check==radio2) {
            cmp.set("v.showBackhaul", true);
        } else {
            cmp.set("v.case.Backhaul_Date_Requested__c", null);
            cmp.set("v.case.Backhaul_Confirmation_Number__c", null);
            cmp.set("v.showBackhaul", false);
        }
    },
    handleVin: function (cmp, evt, hlp) {
        console.log('handling vin change');
        hlp.lookupVin(cmp);
    },
    handleSubmit: function (cmp, evt, hlp) {
        hlp.submitForm(cmp);
        //hlp.navigate(cmp);
    },
    handleClear: function (cmp, evt, hlp) {
        hlp.initCase(cmp);
    },
    handlePrint: function (cmp, evt, hlp) {
        window.print();
    },
})