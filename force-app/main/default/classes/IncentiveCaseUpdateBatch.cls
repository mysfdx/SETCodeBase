/*
Name:IncentiveCaseUpdateBatch
Purpose: This Batch has been used for updating the Incentive Challenge cases based on received response from Mainframe.
Case will get either closed or its status will be set as Validation Failed.
Author: Neha Agrawal
Date: 8/31/2020

*************************************************
Change logs
Author--             Date--                  Purpose
Neha Agrawal--   25th May 2021--   To improve error logging and removing Pablo Cibraro from error emails
                                   There was a parsing error with the MuleSoft copybook 
								   so need to put to limit to process record safely then removed limit.
*/


global class IncentiveCaseUpdateBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.stateful {
    global String accessToken;
    global DateTime expiresinsec;
    global integer apiStatus;
    /*
     Purpose: To send the email in case of any unhandled exception
     Author: Neha Agrawal
    */
    global void SendEmail(Integer Statuscode, String Errorsource){
        messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
        List<String> toAdd=new list<String>();
        For(user u: [Select email,id from user where profile.name='System Administrator' and name<>'Pablo Cibraro' and isActive=True]) {
            toAdd.add(u.email);
        }
        email1.setToAddresses(toAdd);
        email1.setSubject('Attn..!!! Error Occured');
        string messageBody = '<html><body>Hi Admin, <br> Error found in IncentiveCaseUpdateBatch Apex Class during ' + Errorsource + ' ,Status code is '+Statuscode + '<br><br>Please look into this issue.</body></html>';
        email1.setHtmlBody(messageBody);
        email1.setSenderDisplayName('JM Family SET Org');
        messaging.Email[] emails = new messaging.Email[]{email1};
        messaging.sendEmail(emails);
    }
    
    /*
     Purpose: To get the MuleSoft token using all information stored in Custom Setting
     Author: Neha Agrawal
    */
    global Void returnAuthToken(){
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        MuleTokenRequest__c mt=MuleTokenRequest__c.getInstance('MuleToken');
        String TokenEndpoint=mt.TokenURL__c;
        request.setEndpoint(TokenEndpoint);
        request.setMethod('POST');
        string Clientid=mt.client_id__c;
        String Clientsec=mt.client_secret__c;
        String granttype=mt.GrantType__c;
        String Scope=mt.Scope__c;   
        string payload = 'client_id=' + Clientid + '&client_secret=' + Clientsec + '&grant_type=' + granttype + '&scope=' + Scope;
        
        request.setBody(payload);
        system.debug('Body Is'+ payload);
        // String accessToken;
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        try{
            HttpResponse res = http.send(request);
            String response=res.getBody();
            system.debug('Token Resposne is '+ response);
            if (res.getStatusCode() == 200) {
                Map<String, Object> response_Map = (Map<String, Object>)JSON.deserializeUntyped(response);
                accessToken=(String)response_Map.get('access_token');
                Decimal expiresIn = (Decimal)response_Map.get('expires_in');
                expiresinsec=System.Now().addSeconds(Integer.valueOf(expiresIn));
                System.debug('access token is '+ accessToken+' and status code is '+res.getStatusCode());
            }
            else{
                SendEmail(res.getStatusCode(),'Token Generation');
                throw new avs_ResourceException('IncentiveCaseUpdateBatchException', 'Token genaration failed. Please review your request or contact support.', '');
            }
        }
        catch(Exception e){
            insert new API_Error_Log__c(Exception_Type__c = 'IncentiveCaseUpdateBatch', Error_Message__c = 'Request was not completed successfully. Please review your request or contact support.', Stack_Trace__c = e.getMessage() + '; ' + e.getStackTraceString()+'; '+e.getLineNumber());
        }
    }
    
    
    Global class RepsonseWrapper {
        Global String status;
        Global String message;
        Global String code;
        Global String dealerNumber;
        Global String vin;
        Global String errorSeverity;
        Global String msgo;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<string> Retrycount=new List<String>();
        Retrycount=MuleTokenRequest__c.getInstance('MuleToken').RetryCriteria__c.split(';');
        String Query='SELECT id, Status, SET_VIN__c, Dealer_Code__c,Contest_Number__c,IncentiveRetryCount__c  from case '+
            'where Form_Name__c =\'Incentives Challenge\' and status in (\'Approved - Validation Pending\',\'Validation Failed\') '+
            'and Challenge__c in (\'CH_SET_CHALLENGE\',\'ASSOCIATE_PURCHASE\',\'DEALER_EMPLOYEE_PURCHASE\',\'FRIEND_NEIGHBOR\',\'TC_TMNA_CHALLENGE\') and IncentiveRetryCount__c in '+Retrycount;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<case> records) {  
        boolean ServiceDownBool = false;
        
        list<case> casetoupdate=new list<case>();
        system.debug('Expires in second is '+expiresinsec+' Access Token value is '+accessToken);
        if(accessToken==null || expiresinsec<= System.Now()){
            returnAuthToken();
        }
        
        for ( integer i = 0; i< records.size(); i++ ){
            try {  
                system.debug('Now calling API');
                String APIURL =MuleTokenRequest__c.getInstance('MuleToken').APIURL__c ;
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                string authheader='Bearer '+accessToken;
                system.debug('Bearer is '+ authheader);
                string parameters='?dealerNumber='+records.get(i).Dealer_Code__c+'&vin='+records.get(i).SET_VIN__c+'&contestNumber='+records.get(i).Contest_Number__c;
                String FullURL=APIURL+parameters;
                req.setHeader('Content-Type', 'application/json'); 
                req.setHeader('Accept', 'application/json');
                req.setHeader('Authorization',authheader);
                req.setMethod('GET');
                req.setTimeOut(120000);
                req.setEndpoint(FullURL);
               
                res = http.send(req);
                String sJson = res.getBody();
                Map<String, Object> APIresponseMap = (Map<String, Object>)JSON.deserializeUntyped(sJson);
                //String error=(String)APIresponseMap.get('error');
                System.debug('Str:' + res.getBody());
                if(res.getStatusCode()==401){
                 String error=(String)APIresponseMap.get('error');
                     if(error.containsIgnoreCase('Invalid Token')){
                        returnAuthToken();
                        res = http.send(req);
                     }
                     
                }
                if(res.getStatusCode()==200){
                    RepsonseWrapper rw=(RepsonseWrapper)JSON.deserialize(sJson,RepsonseWrapper.class);
                    if(rw.status=='Error'){
                        records.get(i).status='Validation Failed';
                        if(records.get(i).IncentiveRetryCount__c==null){
                            records.get(i).IncentiveRetryCount__c=1;
                        }
                        else
                        {
                            records.get(i).IncentiveRetryCount__c=records.get(i).IncentiveRetryCount__c+1; 
                        }
                        
                        
                        system.debug('Error '+rw.status);
                    }
                    else if(rw.status=='Success'){
                        records.get(i).status='Closed - Approved';
                        if(records.get(i).IncentiveRetryCount__c==null){
                            records.get(i).IncentiveRetryCount__c=1;
                        }
                        else
                        {
                            records.get(i).IncentiveRetryCount__c=records.get(i).IncentiveRetryCount__c+1; 
                        }
                        system.debug('Success '+rw.status);
                    }
                    casetoupdate.add(records.get(i)); 
                    
                }
                else{
                    ServiceDownBool = true; 
                    //SendEmail(res.getStatusCode(),'API Calling');
                    apiStatus=res.getStatusCode();
                    throw new avs_ResourceException('IncentiveCaseUpdateBatchException', 'API call failed. Please review your request or contact support.', '');
                }
                            
            }
            catch (Exception e) {         
                System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() ); 
                insert new API_Error_Log__c(Exception_Type__c = 'IncentiveCaseUpdateBatch', Error_Message__c = 'Request was not completed successfully. Please review your request or contact support.', Stack_Trace__c = e.getMessage() + '; ' + e.getStackTraceString()+'; '+e.getLineNumber());
            }
        }
        database.update(casetoupdate,false);
    }   
    
    global void finish(Database.BatchableContext BC){
        if(apiStatus != NULL && !String.isBlank(String.valueOf(apiStatus))){
            SendEmail(apiStatus,'API Calling');
        }
        system.debug('IncentiveCaseUpdateBatch job has been finished.');
    }
}