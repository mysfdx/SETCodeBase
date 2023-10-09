({
    init: function(cmp) {
        cmp.set('v.myVal', '');
    },

    validate: function(cmp) {
        if(!cmp.get("v.myVal")){
            cmp.set("v.validity", false);
        }
        else{
            cmp.set("v.validity", true);
        }
    }
})