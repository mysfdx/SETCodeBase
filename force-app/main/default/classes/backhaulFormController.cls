/* Name:  backhaulFormController
Created By:  Neha Agrawal
Created Date:  2022-05-30
Description:  Created for Backhaul form.

Change log

*/

public class backhaulFormController {
    
    static public String backhaulToken;
    static public DateTime expiresinsec;
    
    @AuraEnabled
    static public setd_CaseInfo.CaseInfo getCaseInfo() {
        setd_CaseInfo caseInfo = new setd_CaseInfo();
        setd_CaseInfo.CaseInfo caseInfoObject = caseInfo.createCaseInfoByFormName('Backhaul Request');
        
        setd_Utilities utilities = new setd_Utilities();
        caseInfoObject.caseObject.RTP_Contact_Name__c = utilities.getFieldValue(caseInfoObject.userObject, 'Name');
        caseInfoObject.caseObject.RTP_Contact_Phone__c = utilities.getFieldValue(caseInfoObject.contactObject, 'Phone');
        return caseInfoObject;
    }
    @AuraEnabled
    Static public string returnBackhaulCost(String dlrNum, String fromDlr, String VIN) {
        Boolean serviceNotRespond;
        Backhaul_Mule_API__c bca=Backhaul_Mule_API__c.getInstance('BackhaulCostAPI');
        backhaulCostBody bc=new backhaulCostBody();
        bc.dealerNumber=dlrNum;
        bc.fromDealer=fromDlr;
        bc.toDealer=dlrNum;
        bc.modelYear='';
        bc.modelNumber='';
        bc.vinIn=VIN;
        String backhaulCostBody=JSON.serialize(bc);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('Accept', 'application/json');
        req.setHeader('client-id', bca.client_id__c);
        req.setHeader('event-id', bca.event_id__c);
        req.setHeader('transaction-id', bca.transaction_id__c);
        req.setHeader('event-seq', bca.event_seq__c);
        req.setHeader('last-in-seq-flag', bca.last_in_seq_flag__c);
        Datetime myDT = Datetime.now(); 
        String myDate = myDT.format('yyyy-MM-dd-HH.mm.ss.SSS000');
        req.setHeader('event-ts', myDate);
        req.setMethod('POST');
        req.setBody(backhaulCostBody);
        req.setTimeOut(120000);
        req.setEndpoint(bca.API_URL__c);
        String cost;
        HttpResponse costResponse;
        try{
            if(backhaulToken==null || expiresinsec<= System.Now()){
                returnBackhaulToken();
            }
            string authheader='Bearer '+backhaulToken;
            system.debug('Bearer is '+ authheader);
            req.setHeader('Authorization',authheader);
            costResponse = http.send(req);
            String response=costResponse.getBody();
            Map<String, Object> costResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
            system.debug('Backhaul Cost API Resposne is '+ response);
            if(costResponse.getStatusCode()==401){
                String error=(String)costResponseMap.get('error');
                if(error.containsIgnoreCase('Invalid Token')){
                    returnBackhaulToken();
                    costResponse = http.send(req);
                }
            }
            if(costResponse.getStatusCode()==200){
                BackhaulCostResponse costResponseWrap = BackhaulCostResponse.parse(response);
                Map<String, Object> costResponseMap1 = (Map<String, Object>)JSON.deserializeUntyped(response);
                System.debug('Backhaul Cost is '+costResponseWrap.data.cost);
                System.debug('costResponseMap1 '+costResponseMap1);
                
                if(String.isBlank(costResponseWrap.data.cost) && costResponseWrap.status.hasError){
                    cost=costResponseWrap.status.message;
                    system.debug('costResponseWrap.status.message is '+costResponseWrap.status.message);
                }
                else{
                    cost=costResponseWrap.data.cost;
                    system.debug('costResponseWrap.data.cost is '+costResponseWrap.data.cost);
                }
                    
            }
            else{
                serviceNotRespond=true;
                Map<String, Object> costErrorMap1 = (Map<String, Object>)JSON.deserializeUntyped(response);
                System.debug('costError '+costErrorMap1.get('error'));
                Map<String, Object> costErrorMap2=(Map<String, Object>)costErrorMap1.get('error');
                System.debug('costErrorMsg '+costErrorMap2.get('errorMessage'));
                cost=String.valueOf(costResponse.getStatusCode())+' Backhaul Request Failed';
                System.debug('Backhaul Cost API is not working fine, status code is '+costResponse.getStatusCode());
                throw new avs_ResourceException('Apex-backhaulFormController', 
                                                'Backahaul Cost API error occurred. Cost API status is '+costResponse.getStatusCode()+ ' '+(String)costErrorMap2.get('errorMessage') , '');   
            }     
        }
        catch(avs_ResourceException e){
            insert new API_Error_Log__c(Exception_Type__c = e.getExceptionName(), Error_Message__c = e.getErrorMessage(), Stack_Trace__c = e.getStackTrace());  
        }
        catch(Exception e){
            System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() );
            insert new API_Error_Log__c(Exception_Type__c = 'backhaulFormControllerException', Stack_Trace__c = e.getMessage() + '; ' + e.getStackTraceString()+'; '+e.getLineNumber());  
        }
        
        return cost;
    }
    
    @AuraEnabled
    Static public string backhaulRequestSubmission(String dlrNum, String fromDlr, String VIN,
                                                   String frmDlrContact, String toDlrContact, 
                                                   String comments, Case backhaulCase, String cost) {
        Boolean serviceNotRespond;
        Backhaul_Mule_API__c bca=Backhaul_Mule_API__c.getInstance('BackhaulRequestAPI');
        backhaulRequestBody br=new backhaulRequestBody();
        br.dealerNumber=dlrNum;
        br.fromDealer=fromDlr;
        br.toDealer=dlrNum;
        br.fromDealerContact=frmDlrContact;
        br.toDealerContact=toDlrContact;
        br.generalComment=comments==null?'':comments;
        br.vinIn=VIN;
        String backhaulCostBody=JSON.serialize(br);
        system.debug('backhaulCostBody '+backhaulCostBody);                                              
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        req.setHeader('Content-Type', 'application/json'); 
        req.setHeader('Accept', 'application/json');
        req.setHeader('client-id', bca.client_id__c);
        req.setHeader('event-id', bca.event_id__c);
        req.setHeader('transaction-id', bca.transaction_id__c);
        req.setHeader('event-seq', bca.event_seq__c);
        req.setHeader('last-in-seq-flag', bca.last_in_seq_flag__c);
        Datetime myDT = Datetime.now(); 
        String myDate = myDT.format('yyyy-MM-dd-HH.mm.ss.SSS000');
        req.setHeader('event-ts', myDate);
        req.setMethod('POST');
        req.setBody(backhaulCostBody);
        req.setTimeOut(120000);
        req.setEndpoint(bca.API_URL__c);
        String msg;
        HttpResponse brResponse;
        try{
            if(backhaulToken==null || expiresinsec<= System.Now()){
                returnBackhaulToken();
            }
            string authheader='Bearer '+backhaulToken;
            system.debug('Bearer is '+ authheader);
            req.setHeader('Authorization',authheader);
            brResponse = http.send(req);
            String response=brResponse.getBody();
            Map<String, Object> brResponseMap1 = (Map<String, Object>)JSON.deserializeUntyped(response);
            system.debug('Backhaul Cost API Resposne is '+ response);
            if(brResponse.getStatusCode()==401){
                String error=(String)brResponseMap1.get('error');
                if(error.containsIgnoreCase('Invalid Token')){
                    returnBackhaulToken();
                    brResponse = http.send(req);
                }
            }
            if(brResponse.getStatusCode()==200){
                Map<String, Object> brResponseMap2 = (Map<String, Object>)JSON.deserializeUntyped(response);
                Map<String, Object> brResponseMap3 = (Map<String, Object>)brResponseMap2.get('status');
                System.debug('Backhaul Request response is '+brResponseMap3);
                msg=(String)brResponseMap3.get('message')+' '+brResponseMap3.get('hasError');
                String successMsg=(String)brResponseMap3.get('message');
                backhaulCase.From_Dealer_Code__c=fromDlr;
                backhaulCase.Backhaul_Request_Message__c=(String)brResponseMap3.get('message');
                backhaulCase.Backhaul_Cost__c=String.isBlank(cost)?0.0:decimal.valueOf(cost);
                backhaulCase.SET_VIN__c=VIN;
                insert backhaulCase;
                sentBackhaulEmail(dlrNum,fromDlr,frmDlrContact,toDlrContact,cost,VIN,comments,successMsg);
            }
            else{
                serviceNotRespond=true;
                System.debug('Backhaul Cost API is not working fine, status code is '+brResponse.getStatusCode());
                throw new avs_ResourceException('Apex-backhaulFormController', 'Backhaul request failed. Backhaul request API status is '+brResponse.getStatusCode()+' '+msg, '');   
            }     
        }
        catch(avs_ResourceException e){
            insert new API_Error_Log__c(Exception_Type__c = e.getExceptionName(), Error_Message__c = e.getErrorMessage(), Stack_Trace__c = e.getStackTrace());  
        }
        catch(Exception e){
            System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() );
            insert new API_Error_Log__c(Exception_Type__c = 'backhaulFormControllerException', Stack_Trace__c = e.getMessage() + '; ' + e.getStackTraceString()+'; '+e.getLineNumber());  
        }
        
        return msg;
    }
    
    static public void returnBackhaulToken(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        MuleTokenRequest__c mbt=MuleTokenRequest__c.getInstance('BackhaulMuleToken');
        String TokenEndpoint=mbt.TokenURL__c;
        request.setEndpoint(TokenEndpoint);
        request.setMethod('POST');
        string Clientid=mbt.client_id__c;
        String Clientsec=mbt.client_secret__c;
        String granttype=mbt.GrantType__c;
        String Scope=mbt.Scope__c; 
        string payload = 'client_id=' + Clientid + '&client_secret=' + Clientsec + '&grant_type=' + 
            granttype + '&scope=' + Scope;
        
        request.setBody(payload);
        system.debug('Body Is'+ payload);
        // String accessToken;
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        try{
            HttpResponse res = http.send(request);
            String response=res.getBody();
            system.debug('Token Resposne is '+ response);
            if (res.getStatusCode() == 200) {
                Map<String, Object> token_Response_Map = (Map<String, Object>)JSON.deserializeUntyped(response);
                backhaulToken=(String)token_Response_Map.get('access_token');
                Decimal expiresIn = (Decimal)token_Response_Map.get('expires_in');
                expiresinsec=System.Now().addSeconds(Integer.valueOf(expiresIn));
                System.debug('access token is '+ backhaulToken+' and status code is '+res.getStatusCode());
            }
            else{
                System.debug('Backhaul Mule Token is not working fine else');
                throw new avs_ResourceException('backhaulFormControllerException', 'Token genaration failed. Please review your request or contact support.', '');
            }
        }
        catch(avs_ResourceException e){
            insert new API_Error_Log__c(Exception_Type__c = e.getExceptionName(), Error_Message__c = e.getErrorMessage(), Stack_Trace__c = e.getStackTrace());  
        }
        catch(Exception e){
            System.debug('Backhaul Mule Token is not working fine catch');
            insert new API_Error_Log__c(Exception_Type__c = 'Apex-backhaulFormController', Error_Message__c = 'Request was not completed successfully. Please review your request or contact support.', Stack_Trace__c = e.getMessage() + '; ' + e.getStackTraceString()+'; '+e.getLineNumber());
        }
    }
    @future
    public static void sentBackhaulEmail(String toDlr, String frmDlr, String frmDlrCon, 
                                         String toDlrCon, String totalCost, String VinNo, 
                                         String generalComm, String backhaulMsg) { 
         String commentNotBlank= String.isBlank(generalComm)?'':generalComm;
         String costSign=String.isBlank(totalCost)?'':'$';                                
                                  
         MuleTokenRequest__c getToAdd=MuleTokenRequest__c.getInstance('BackhaulMuleToken');
         Account fromAccount=[SELECT id,Name,ShippingStreet,ShippingCity,ShippingState,Phone FROM Account WHERE Dealer_Code__c=:frmDlr LIMIT 1];
         Account toAccount=[SELECT id,Name,ShippingStreet,ShippingCity,ShippingState,Phone FROM Account WHERE Dealer_Code__c=:toDlr LIMIT 1];
         messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
         List<String> toAdd=new list<String>();
         //toAdd.addAll(getToAdd.Email_Addresses__c.split(';'));
         String toAddreses=getToAdd.Email_Addresses__c;
        String replaceAdderess=toAddreses.replace('[FromDlrCd]', frmDlr);   
        replaceAdderess=replaceAdderess.replace('[ToDlrCd]', toDlr);
        toAdd.addAll(replaceAdderess.split(';'));
        system.debug('toAdd is '+toAdd);
        email1.setToAddresses(toAdd);
        email1.setSubject('Backhaul Request');
        string messageBody = '<html><body>REQUESTING DEALER - '+toDlr+' '+toAccount.Name+
            '<br><br>'+backhaulMsg+
            '<br><br> BACKHAUL FROM - '+frmDlr+
            '<br> NAME - '+fromAccount.Name+'<br>ADDRESS - '+ fromAccount.ShippingStreet +'<br> CITY - '+ fromAccount.ShippingCity+
            '<br>STATE - '+fromAccount.ShippingState+'<br> CONTACT - '+frmDlrCon+'<br> PHONE - '+fromAccount.Phone+
            '<br><br> SERIAL NUMBER - '+VinNo+
            '<br><br> Total Cost - '+costSign+totalCost+
            '<br><br> DROP SHIP TO - '+toDlr+
            '<br> NAME - '+toAccount.Name+'<br>ADDRESS - '+ toAccount.ShippingStreet +'<br> CITY - '+ toAccount.ShippingCity+
            '<br>STATE - '+toAccount.ShippingState+'<br> CONTACT - '+toDlrCon+'<br> PHONE - '+toAccount.Phone+
            '<br><br> COMMENT - '+commentNotBlank+
            '<br><br> ESTIMATED DELIVERY OF 10 DAYS FOR BACKHAUL REQUESTS.<br><br> BILL FREIGHT TO - '+toDlr+
            '</body></html>';
        email1.setHtmlBody(messageBody);
        //email1.setSenderDisplayName('JM Family SET Org');
        messaging.Email[] emails = new messaging.Email[]{email1};
        messaging.sendEmail(emails);
    }
    
    public class backhaulCostBody{
        public String dealerNumber;
        public String fromDealer;
        public String toDealer;
        public String modelYear;
        public String modelNumber;
        public String vinIn;
    }
    public class backhaulRequestBody{
        public String dealerNumber;
        public String fromDealer;
        public String toDealer;
        public String fromDealerContact;
        public String toDealerContact;
        public String generalComment;
        public String vinIn;
    }
}