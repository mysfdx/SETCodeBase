/* Name:  SETDFOMMonthlyConReportSchedule
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global class SETDFOMMonthlyConReportSchedule implements schedulable
{
    /*
        SETDFOMMonthlyConReportSchedule scheduleReport = new SETDFOMMonthlyConReportSchedule();
        string strSchTime = '0 0 7 1 * ?';
        system.schedule('DFOM Monthly Contact Report', strSchTime, scheduleReport);
    */
    
    global void execute(SchedulableContext ctx)
    {
      /*****************************************************************
      Logic to read Email addresses from Public Group - Start
      *****************************************************************/  
        List<String> mailList = new List<String>();
        List<String> mailAddresses = new List<String>(); 
  
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'SET DFOM Monthly Email']; 
        for (GroupMember gm : g.groupMembers) 
        {
        if(string.valueof(gm.userOrGroupId).startswith('005')){
            mailList.add(gm.userOrGroupId);
            }
        }
        User[] usr = [SELECT email FROM user WHERE id IN :mailList];
        for(User u : usr) 
        {
        mailAddresses.add(u.email);
        }     
      /*****************************************************************
      Logic to read Email addresses from Public Group - End
      *****************************************************************/          
       
        
        //string currentDate=system.now().adddays(-3).format('MMMM-d-yyyy');
        string currentDate=system.now().addMonths(-1).format('MMMM-d-yyyy');
        integer iMonLen=currentDate.indexof('-');
        system.debug('iMonLen:'+iMonLen);
        string currMonth=currentDate.substring(0,iMonLen);
        string yearstr=currentDate.substring(iMonLen+1,currentDate.length());
        system.debug('yearstr:'+yearstr);
        integer iDateLen=yearstr.indexof('-');
        system.debug('iDateLen:'+iDateLen);
        string currYear=currentDate.substring(iMonLen+iDateLen+2,currentDate.length());
        system.debug('currYear:'+currYear);
        string baseUrl=URL.getSalesforceBaseUrl().getHost();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        EmailTemplate EmailToUse=new EmailTemplate();

        EmailToUse=[Select Subject,DeveloperName,Body From EmailTemplate e where DeveloperName='SET_DFOM_Monthly_Report_Email'];        
        
        /*list<string> toAddressList=new List<string>();
        toAddressList=SET_DFOM_Email__c.getInstance('DFOM Email').Email_Recipient__c.split(';');
        mail.settoAddresses(toAddressList);*/   
        mail.settoAddresses(mailAddresses);
        
        mail.setSenderDisplayName('DCMS - No Reply');
        mail.setSubject(EmailToUse.Subject+' '+currMonth+'-'+currYear);
        mail.setBccSender(false);
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
        string filePath='https://'+baseUrl+'/apex/SETDFOMMonthlyContactReportPDF?forMonth='+currMonth+'-'+currYear;
        system.debug('filePath:'+filePath);
        string emailBody=EmailToUse.Body+ '\n\n';
        emailBody +=filePath;
        mail.setPlainTextBody(emailBody);
        
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
       

       
        
    } 
    
    
}