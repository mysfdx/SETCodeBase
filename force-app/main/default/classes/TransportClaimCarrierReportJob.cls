/* Name:  TransportClaimCarrierReportJob
Created By:Neha Agrawal
Created Date:  2021-03-23
Last Modified By:  Neha Agrawal
Last Modified Date: 2021-04-23
Description: This job has been scheduled for daily to send the Transport Claim Reports to External Carriers.

***********************************************
Change Log

Changed by--     Date--                  Pupose--
Neha Agrawal--   28th May 2021--   Need to change the Apex Page reference due to Lightning Migration
Neha Agrawal--   11th Feb 2022--   Adding two new reports for Friday and Tuesday
Neha Agrawal--   24th Mar 2022--   Added functionality to check the weekday.
Neha Agrawal--   28th Mar 2023--   Added New carriers report.
*/

public class TransportClaimCarrierReportJob implements Schedulable, Database.AllowsCallouts {
    
    
    
    public void execute(SchedulableContext sc) {
        String day='Test';
        reportsMethod();
    }
    @future (callout=true)
    public static void reportsMethod(){
        ApexPages.PageReference report;
        List<reportWrapper> Reports=new List<reportWrapper>();
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        
        if(!test.isRunningTest()){
           List<Report> actualReports=[select id,Name, DeveloperName from report where Name in 
                                       ('ACE Transportation Claims','Centurion Transportation Claims',
                                      'Longhorn Transportation Claims','Transportation Claims Under Review',
                                       'Transportation Claims Not Processed','DMX Transportation Claims',
                                        'Runbuggy Transportation Claims','Hicks Transportation Claims',
                                        'North Beach Transportation Claims','Masney Transportation Claims',
                                        'AMJ Transportation Claims')];
            for(Report r:actualReports){
                Reports.add(new reportWrapper(r.id,r.name));
            }
        }
        else
        {
            
            Reports.add(new reportWrapper('1234567890','ACE Transportation Claims'));
            Reports.add(new reportWrapper('1234567890','Centurion Transportation Claims'));
            Reports.add(new reportWrapper('1234567890','Longhorn Transportation Claims'));
            Reports.add(new reportWrapper('1234567890','Transportation Claims Under Review'));
            Reports.add(new reportWrapper('1234567890','Transportation Claims Not Processed'));
            Reports.add(new reportWrapper('1234567890','DMX Transportation Claims'));
            Reports.add(new reportWrapper('1234567890','Runbuggy Transportation Claims'));
            Reports.add(new reportWrapper('1234567890','Hicks Transportation Claims'));
            Reports.add(new reportWrapper('1234567890','North Beach Transportation Claims'));
            Reports.add(new reportWrapper('1234567890','Masney Transportation Claims'));
            Reports.add(new reportWrapper('1234567890','AMJ Transportation Claims'));
            
        }
            
        
        TransportClaimCarrierMails__c tc=TransportClaimCarrierMails__c.getInstance('CarrierEmails');
        List<string> Longhorn=tc.Longhorn__c.split(';');
        List<string> ACE=tc.ACE__c.split(';');
        List<string> Centurion=tc.Centurion__c.split(';');
        List<string> AMJ=tc.AMJ__c.split(';');
        List<string> DMX=tc.DMX__c.split(';');
        List<string> NorthBeach=tc.NorthBeach__c.split(';');
        List<string> Runbuggy=tc.Runbuggy__c.split(';');
        List<string> Hicks=tc.HICKS__c.split(';');
        List<string> Masney=tc.Masney__c.split(';');
        List<string> ClaimUnderReview=tc.Trans_Claims_Under_Review_Emails__c.split(';');
        List<string> ClaimNotProcessed=tc.Trans_Claims_Not_Processed_Emails__c.split(';');
        Date d = System.today();
        Datetime dt = (DateTime)d;
        String dayOfWeek;
        if(!test.isRunningTest()){
            dayOfWeek = dt.format('EEEE'); //This returns - Monday, Tuesday, Wednesday, etc..
        }else{
            dayOfWeek = 'Friday';
        }
       
        

        for(reportWrapper rp: Reports){
            
            system.debug('Rp name is '+ rp.name);            
            Messaging.SingleEmailMessage mail;
            if(rp.name=='ACE Transportation Claims'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment1 = new Messaging.EmailFileAttachment();
                attachment1.setFileName('ACE_Transportation_Claims.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment1.setBody(report.getContent());
                }else{
                   attachment1.setBody(blob.valueof('TEST'));
                }
                
                attachment1.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment1 } );
                mail.setSubject('ACE Transportation Claims');
                mail.setToAddresses( ACE );
                mail.setPlainTextBody('Please see the attached ACE Transportation Claims report from SET.');
                messages.add(mail);
            }
            if(rp.name=='Centurion Transportation Claims'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment2 = new Messaging.EmailFileAttachment();
                attachment2.setFileName('Centurion_Transportation_Claims.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment2.setBody(report.getContent());
                }else{
                   attachment2.setBody(blob.valueof('TEST'));
                }
                
                attachment2.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment2 } );
                mail.setSubject('Centurion Transportation Claims');
                mail.setToAddresses(Centurion); 
                mail.setPlainTextBody('Please see the attached Centurion Transportation Claims report from SET.');
                messages.add(mail);
            }
            if(rp.name=='Longhorn Transportation Claims'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment3 = new Messaging.EmailFileAttachment();
                attachment3.setFileName('Longhorn_Transportation_Claims.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment3.setBody(report.getContent());
                }else{
                   attachment3.setBody(blob.valueof('TEST'));
                }
                attachment3.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment3 } );
                mail.setSubject('Longhorn Transportation Claims');
                mail.setToAddresses(Longhorn);
                mail.setPlainTextBody('Please see the attached Longhorn Transportation Claims report from SET.');
                messages.add(mail);
                system.debug('Longhorn is '+ Longhorn);
            }
            
            if(rp.name=='Transportation Claims Not Processed' && dayOfWeek=='Friday'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment4 = new Messaging.EmailFileAttachment();
                attachment4.setFileName('Transportation_Claims_Not_Processed.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment4.setBody(report.getContent());
                }else{
                   attachment4.setBody(blob.valueof('TEST'));
                }
                attachment4.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment4 } );
                mail.setSubject('Transportation Claims Not Processed');
                mail.setToAddresses(ClaimNotProcessed);
                mail.setPlainTextBody('Please see the attached Transportation Claims Not Processed report from SET.');
                messages.add(mail);
                system.debug('ClaimNotProcessed is '+ ClaimNotProcessed);
            }
            if(rp.name=='Transportation Claims Under Review' && (dayOfWeek=='Tuesday' || dayOfWeek=='Friday')){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment5 = new Messaging.EmailFileAttachment();
                attachment5.setFileName('Transportation_Claims_Under_Review.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment5.setBody(report.getContent());
                }else{
                   attachment5.setBody(blob.valueof('TEST'));
                }
                attachment5.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment5 } );
                mail.setSubject('Transportation Claims Under Review');
                mail.setToAddresses(ClaimUnderReview);
                mail.setPlainTextBody('Please see the attached Transportation Claims Under Review report from SET.');
                messages.add(mail);
                system.debug('ClaimUnderReview is '+ ClaimUnderReview);
            }
            if(rp.name=='DMX Transportation Claims'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment6 = new Messaging.EmailFileAttachment();
                attachment6.setFileName('DMX_Transportation_Claims.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment6.setBody(report.getContent());
                }else{
                   attachment6.setBody(blob.valueof('TEST'));
                }
                attachment6.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment6 } );
                mail.setSubject('DMX Transportation Claims');
                mail.setToAddresses(DMX);
                mail.setPlainTextBody('Please see the attached DMX Transportation Claims report from SET.');
                messages.add(mail);
                system.debug('DMX is '+ DMX);
            }
            if(rp.name=='Runbuggy Transportation Claims'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment7 = new Messaging.EmailFileAttachment();
                attachment7.setFileName('Runbuggy_Transportation_Claims.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment7.setBody(report.getContent());
                }else{
                   attachment7.setBody(blob.valueof('TEST'));
                }
                attachment7.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment7 } );
                mail.setSubject('Runbuggy Transportation Claims');
                mail.setToAddresses(Runbuggy);
                mail.setPlainTextBody('Please see the attached Runbuggy Transportation Claims report from SET.');
                messages.add(mail);
                system.debug('Runbuggy is '+ Runbuggy);
            }
            if(rp.name=='Hicks Transportation Claims'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment8 = new Messaging.EmailFileAttachment();
                attachment8.setFileName('Hicks_Transportation_Claims.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment8.setBody(report.getContent());
                }else{
                   attachment8.setBody(blob.valueof('TEST'));
                }
                attachment8.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment8 } );
                mail.setSubject('Hicks Transportation Claims');
                mail.setToAddresses(Hicks);
                mail.setPlainTextBody('Please see the attached Hicks Transportation Claims report from SET.');
                messages.add(mail);
                system.debug('Hicks is '+ Hicks);
            }
            if(rp.name=='North Beach Transportation Claims'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment9 = new Messaging.EmailFileAttachment();
                attachment9.setFileName('North_Beach_Transportation_Claims.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment9.setBody(report.getContent());
                }else{
                   attachment9.setBody(blob.valueof('TEST'));
                }
                attachment9.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment9 } );
                mail.setSubject('North Beach Transportation Claims');
                mail.setToAddresses(NorthBeach);
                mail.setPlainTextBody('Please see the attached North Beach Transportation Claims report from SET.');
                messages.add(mail);
                system.debug('North Beach is '+ NorthBeach);
            }
            if(rp.name=='Masney Transportation Claims'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment10 = new Messaging.EmailFileAttachment();
                attachment10.setFileName('Masney_Transportation_Claims.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment10.setBody(report.getContent());
                }else{
                   attachment10.setBody(blob.valueof('TEST'));
                }
                attachment10.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment10 } );
                mail.setSubject('Masney Transportation Claims');
                mail.setToAddresses(Masney);
                mail.setPlainTextBody('Please see the attached Masney Transportation Claims report from SET.');
                messages.add(mail);
                system.debug('Masney is '+ Masney);
            }
            if(rp.name=='AMJ Transportation Claims'){
                mail=new Messaging.SingleEmailMessage();
                Messaging.EmailFileAttachment attachment11 = new Messaging.EmailFileAttachment();
                attachment11.setFileName('AMJ_Transportation_Claims.csv');
                report = new ApexPages.PageReference('/'+rp.Id+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                if(!test.isRunningTest()){
                    attachment11.setBody(report.getContent());
                }else{
                   attachment11.setBody(blob.valueof('TEST'));
                }
                attachment11.setContentType('text/csv');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment11 } );
                mail.setSubject('AMJ Transportation Claims');
                mail.setToAddresses(AMJ);
                mail.setPlainTextBody('Please see the attached AMJ Transportation Claims report from SET.');
                messages.add(mail);
                system.debug('AMJ is '+ AMJ);
            }
            
        }
        system.debug('number of emails are '+ messages.size());
        Messaging.SendEmailResult[] results= Messaging.sendEmail(messages);
        if(results.Size()>0){
            if (results[0].success) 
            {
                System.debug('The email was sent successfully');
            } else {
                System.debug('The email failed to send:' +  results[0].errors[0].message);
            }
        }
        
    }
    public class reportWrapper{
            public string id;
            public string name;
            public reportWrapper(string id, string name){
                this.id=id; 
                this.name=name;
                
            }
                      
        }  
}