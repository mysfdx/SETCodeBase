({
    doInit : function(component, event, helper) {
        var objectLabel=component.get('v.object_label');
        component.set('v.object_label', decodeURI(objectLabel));
        component.set('v.case_challenge', component.get('v.case_challenge'));
        console.log('case_challenge is '+component.get('v.case_challenge'));
    },
	handleClose: function (component, event, helper) {
		location.assign('case/' + component.get('v.id'));
	}
})