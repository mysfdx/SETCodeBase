({
    doinit : function(component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        console.log('sURLVariables are ', sURLVariables);
        var sParameterName;
        var params = {};
        var i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            params[sParameterName[0]] =  decodeURIComponent(sParameterName[1]);
            console.log('params[sParameterName[0]] is ', params[sParameterName[0]]);
        }
        
        console.log(params['CaseType']=== undefined ? '' :'Hello Test');
        console.log('params Requested Date '+params['BackhaulDateRequested']);
        /*var date = new Date('2022-10-17');
    if (!isNaN(date.getTime())) {
        console.log('what is the issue');
        var d= date.getMonth() + 1+'/' + date.getDate() + '/' + date.getFullYear();
    }*/
        
        var flow = component.find("flowData");
        console.log('Testing '); 
        var inputVariables = [
            {
                name : 'CaseType',
                type : 'String',
                value : params['CaseType']=== undefined ? '' :params['CaseType']
            },
            {
                name : 'VIN',
                type : 'String',
                value : params['VIN']=== undefined ? '' :params['VIN']
            },
            {
                name : 'Accessory1',
                type : 'String',
                value : params['Accessory1']=== undefined ? '' :params['Accessory1']
            },
            {
                name : 'Accessory2',
                type : 'String',
                value : params['Accessory2']=== undefined ? '' :params['Accessory2']
            },
            {
                name : 'Accessory3',
                type : 'String',
                value : params['Accessory3']=== undefined ? '' :params['Accessory3']
            },
            {
                name : 'Accessory4',
                type : 'String',
                value : params['Accessory4']=== undefined ? '' :params['Accessory4']
            },
            {
                name : 'Accessory5',
                type : 'String',
                value : params['Accessory5']=== undefined ? '' :params['Accessory5']
            },
            {
                name : 'Accessory6',
                type : 'String',
                value : params['Accessory6']=== undefined ? '' :params['Accessory6']
            },
            {
                name : 'Accessory7',
                type : 'String',
                value : params['Accessory7']=== undefined ? '' :params['Accessory7']
            },
            {
                name : 'Accessory8',
                type : 'String',
                value : params['Accessory8']=== undefined ? '' :params['Accessory8']
            },
            {
                name : 'Accessory9',
                type : 'String',
                value : params['Accessory9']=== undefined ? '' :params['Accessory9']
            },
            {
                name : 'Accessory10',
                type : 'String',
                value : params['Accessory10']=== undefined ? '' :params['Accessory10']
            },
            {
                name : 'AuthorizedName',
                type : 'String',
                value : params['AuthorizedName']=== undefined ? '' :params['AuthorizedName']
            },
            {
                name : 'BackhaulRequested',
                type : 'String',
                value : params['BackhaulRequested']=== undefined ? '' :params['BackhaulRequested']
            },
            {
                name : 'Comments',
                type : 'String',
                value : params['Comments']=== undefined ? '' :params['Comments']
            },
            {
                name : 'Model',
                type : 'String',
                value : params['Model']=== undefined ? '' :params['Model']
            },
            {
                name : 'ConfirmationNumber',
                type : 'String',
                value : params['ConfirmationNumber']=== undefined ? '' :params['ConfirmationNumber']
            },
            {
                name : 'BackhaulDateRequested',
                type : 'String',
                value : params['BackhaulDateRequested']=== undefined ? '' :params['BackhaulDateRequested']
            } 
        ];
        
        console.log('inputVariables length is '+inputVariables.length); 
        
        for (i = 0; i < inputVariables.length; i++) {
            console.log('inputVariables '+inputVariables[i].value);
        }
        
        flow.startFlow("DD365LandingForm", inputVariables);
    }
})