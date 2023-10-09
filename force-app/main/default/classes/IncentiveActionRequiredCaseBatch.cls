/*
Name:IncentiveActionRequiredCaseBatch
Purpose: This Batch has been used for sending the last 14 days Action Required Incentive Challenge cases to Dealer distribution
email list. Story #	SS1SP-39
Author: Neha Agrawal
Date: 6/16/2021

ChangeLog

Author--             Date--                       Purpose--
Neha Agrawal        6/29/2021          removed Total Incentive Amount calculation 
Neha Agrawal        8/9/2021           added Incentive Department as CC for every email
Neha Agrawal        12/06/2021         added Job Failure and Success emails
*/

public class IncentiveActionRequiredCaseBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.stateful {
    
    Map<String,caseWrapper> caseInfoMap=new Map<String,caseWrapper>();
    Map<String,String> CodetoDealerName=new Map<String,String>();
    Map<string,string> lables=new Map<string,string>();
    string finalstr;
    integer caseCount;
    decimal totalAmount;
    string emailListSeparator;
    String IncEmail;
    String adminEmail;
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Schema.DescribeFieldResult fieldResult = Case.Challenge__c.getDescribe(); 
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues(); 
        for( Schema.PicklistEntry v : values) { 
            lables.put(v.getValue(),v.getLabel());
        } 
        emailListSeparator=MuleTokenRequest__c.getInstance('MuleToken').IncentiveEmailListSeparator__c;
        IncEmail=MuleTokenRequest__c.getInstance('MuleToken').Inc_Team_Email_Address__c;
        adminEmail=MuleTokenRequest__c.getInstance('MuleToken').Current_Salesforce_Admin__c;
        string additionalCriteria=MuleTokenRequest__c.getInstance('MuleToken').ActionRequiredBatchCriteria__c;
        String Query='SELECT id, Status, Dealer_Code__c,account.id,account.Email_List__c,account.name,'+
            'casenumber,Incentive_Amount__c,SET_VIN__c, RecordType.name,Reason_for_Challenge__c, Challenge__c,'+
            'Retail_Date__c, Owner.name,LastModifiedDate, Contest_Number__c, CreatedDate from case '+
            'where Form_Name__c =\'Incentives Challenge\' and '+additionalCriteria+' order by Dealer_Code__c'; 
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<case> caseRecords) { 
        
        for(Case c: caseRecords){  
            if(c.account.Email_List__c!=null){
                if(!caseInfoMap.containskey(c.Account.id)){
                    List<string> emailAddrs=new List<string>();
                    emailAddrs=c.account.Email_List__c.split(emailListSeparator);
                    string header = 'Dealer Code, Dealer Name, VIN,Case Record Type,Reason for Challenge,Challenge,'+
                        'Retail Date,Case Owner,Incentive Amount,Case Number,Contest #,Status,Age,Case Last Modified Date,Opened Date \n';
                    finalstr = header;
                    caseCount=0;
                    //totalAmount=0;
                    caseInfoMap.put(c.Account.id, new caseWrapper(finalstr,caseCount,emailAddrs));
                    
                }
                Integer noOfDays=date.valueof(c.lastmodifieddate).daysBetween(System.Today());
                string recordString = '="'+c.Dealer_Code__c+'"'+','+c.account.name+','+c.SET_VIN__c+','+c.RecordType.name+','
                    +c.Reason_for_Challenge__c+','+lables.get(c.Challenge__c)+','+c.Retail_Date__c.format()+','+c.Owner.name+','
                    +c.Incentive_Amount__c+','+'="'+c.CaseNumber+'"'+','+c.Contest_Number__c+','+c.Status+','+noOfDays+','
                    +c.LastModifiedDate.date().format()+','+c.CreatedDate.date().format()+'\n';
                finalstr=caseInfoMap.get(c.Account.id).caseBody;
                finalstr = finalstr +recordString;
                caseInfoMap.get(c.Account.id).caseBody=caseInfoMap.get(c.Account.id).caseBody+recordString;
                caseInfoMap.get(c.Account.id).numberOfCases=caseInfoMap.get(c.Account.id).numberOfCases+1;
                /*if(c.Incentive_Amount__c!=null){
caseInfoMap.get(c.Account.id).incentiveAmount=caseInfoMap.get(c.Account.id).incentiveAmount+c.Incentive_Amount__c;
}*/
                
            }
            else{
                if(!CodetoDealerName.containskey(c.Dealer_Code__c)){
                    CodetoDealerName.put(c.Dealer_Code__c,c.account.name);
                }
            }
            
            
        }
        
        
    }
    public void finish(Database.BatchableContext BC){ 
        if(!caseInfoMap.isEmpty()){
            List<Messaging.SingleEmailMessage> dealerMailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate tempId=[SELECT Id,HTMLValue,Body,Name,Subject FROM EmailTemplate 
                                  WHERE DeveloperName = 'Open_Incentive_Case_Status_Report' LIMIT 1];
            for(string accountid:caseInfoMap.keySet())
            {
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                attach.setContentType('text/csv');
                String fileName='Case Aging Dealer report_'+Datetime.now().format('yyyy-MM-dd')+'.csv';
                attach.setFileName(fileName);
                String emailBody = tempID.HTMLValue;
                string caseTable = caseInfoMap.get(accountid).caseBody;
                attach.Body = Blob.valueOf(caseTable);
                integer caseCounts=caseInfoMap.get(accountid).numberOfCases;
                String totalCases=String.valueOf(caseCounts);
                //String totalIncentive=String.valueOf(caseInfoMap.get(accountid).incentiveAmount);
                emailbody=emailBody.replace('Total_Records',totalCases);
                //emailbody=emailBody.replace('Total_Amount',totalIncentive);
                List<string> emails=caseInfoMap.get(accountid).emailAdd;
                mail.setToAddresses(emails);
                mail.setCcAddresses(new String[] { IncEmail});// added cc 
                mail.setHtmlBody(emailbody);
                mail.setSubject(tempID.Subject);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });   
                system.debug('counts is '+ caseCounts);
                system.debug('CaseTable is '+ caseTable);
                system.debug('Emails are '+ emails);
                dealerMailList.add(mail);
            }
            Messaging.SendEmailResult[] results;
            try{
                results= Messaging.sendEmail(dealerMailList);
                system.debug('Result size is '+ results.Size());
                
              if(results.Size()>0){
                    if (results[0].isSuccess()) 
                    {
                        System.debug('Dealers email was sent successfully');
                         messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
                List<String> toAdd=new list<String>();
                 toAdd.add(adminEmail);
                 toAdd.add(IncEmail);
                email1.setToAddresses(toAdd);
                email1.setSubject('Incentive Case Aging Report Sent Successfully');
                string messageBody = '<html><body>Hi Team, <br> <br> All '+results.Size()+
                   ' emails sent successfully <br> Thanks..!!.</body></html>';
                    email1.setHtmlBody(messageBody);
                email1.setSenderDisplayName('JM Family SET Org');
                messaging.Email[] emails = new messaging.Email[]{email1};
                    messaging.sendEmail(emails);
                        
                    } else {
                        
                        System.debug('Dealers email failed to send:' +  results[0].errors[0].message);
                    }
                }
            }
            catch(Exception e){
                insert new API_Error_Log__c(Exception_Type__c = 'IncentiveActionRequiredCaseBatch', 
                                            Error_Message__c = e.getMessage(), 
                                            Stack_Trace__c = e.getStackTraceString()+'; '+e.getLineNumber());
                messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
                List<String> toAdd=new list<String>();
                 toAdd.add(adminEmail);
                 toAdd.add(IncEmail);
                email1.setToAddresses(toAdd);
                email1.setSubject('Attn..!! Error Occured in Incentive Case Aging Report');
                string messageBody = '<html><body>Hi Team, <br> <br>'+ e.getMessage()+
                    '<br>'+e.getStackTraceString()+'; '+e.getLineNumber()+
                    '<br> <br>Please look into this issue. <br><br> Thanks..!!</body></html>';
                    email1.setHtmlBody(messageBody);
                email1.setSenderDisplayName('JM Family SET Org');
                messaging.Email[] emails = new messaging.Email[]{email1};
                    messaging.sendEmail(emails);
                
                
            }
        }
        if(!CodetoDealerName.isEmpty()){
            List<Messaging.SingleEmailMessage> accountingMailList = new List<Messaging.SingleEmailMessage>();
            string dealers='';
            for(string code:CodetoDealerName.keySet())
            {
                dealers=dealers+CodetoDealerName.get(code)+' - '+code+'<br/>';         
            } 
            EmailTemplate accTempId=[SELECT Id,HTMLValue,Body,Name,Subject FROM EmailTemplate 
                                     WHERE DeveloperName = 'Dealer_Accounting_List_is_blank' LIMIT 1];
            Messaging.SingleEmailMessage accMail = new Messaging.SingleEmailMessage();
            accMail.setToAddresses(new String[] { IncEmail});
            String accEmailBody = accTempId.HTMLValue;
            accEmailBody=accEmailBody.replace('Dealer_List',dealers);
            accMail.setHtmlBody(accEmailBody);
            accMail.setSubject(accTempId.Subject);
            accountingMailList.add(accMail);
            system.debug('Dealer are '+ dealers);
            Messaging.SendEmailResult[] accResults= Messaging.sendEmail(accountingMailList);
        } 
    }
    
    public class caseWrapper{
        public string caseBody;
        public Integer numberOfCases;
        //public decimal incentiveAmount;
        public List<string> emailAdd;
        public caseWrapper(string caseBody, Integer numberOfCases,List<string> emailAdd){
            this.caseBody=caseBody; 
            this.numberOfCases=numberOfCases;
            //this.incentiveAmount=incentiveAmount;
            this.emailAdd=emailAdd;
        }           
    }  
}