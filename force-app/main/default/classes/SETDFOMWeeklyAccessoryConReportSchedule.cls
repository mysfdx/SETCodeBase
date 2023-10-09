/* Name:  SETDFOMWeeklyAccessoryConReportSchedule
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global class SETDFOMWeeklyAccessoryConReportSchedule implements schedulable
{
    /*
        SETDFOMWeeklyAccessoryConReportSchedule scheduleReport = new SETDFOMWeeklyAccessoryConReportSchedule();
        string strSchTime = '0 05 7 ? * MON *';
        system.schedule('DFOM Weekly Accessory Contact Report', strSchTime, scheduleReport);
    */
    
    global void execute(SchedulableContext ctx)
    {
      /*****************************************************************
      Logic to read Email addresses from Public Group - Start
      *****************************************************************/  
        List<String> mailList = new List<String>();
        List<String> mailAddresses = new List<String>(); 
        String strActivityType = 'Accessory';  
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'SET DFOM Accessory Weekly Email'];
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

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {'kishore.chandolu_contractor@jmfamily.com'};
        //mail.setToAddresses(toAddresses);
        
        EmailTemplate EmailToUse=new EmailTemplate();

        EmailToUse=[Select Subject,DeveloperName,Body From EmailTemplate e where DeveloperName='SET_DFOM_Accessory_Contact_Weekly_Email'];
        
        mail.settoAddresses(mailAddresses); 
                
        mail.setSenderDisplayName('DCMS - No Reply');
        mail.setSubject('Weekly DFOM Accessory Contact Report: ' +(String.valueof(Date.Today().toStartOfWeek() - 6))+ ' to '+(String.valueof(Date.Today().toStartOfWeek())));
        mail.setBccSender(false);

        string baseUrl=URL.getSalesforceBaseUrl().getHost();
        //string filePath='https://'+baseUrl+'/apex/SETDFOMWeeklyContactReportPDF?startDate='+(String.valueof(Date.Today().toStartOfWeek() - 6))+ '&endDate='+(String.valueof(Date.Today().toStartOfWeek()));
        string filePath='https://'+baseUrl+'/apex/SETDFOMWeeklyAccessoryContactReportPDF?startDate='+(String.valueof(Date.Today().toStartOfWeek() - 6))+ '&endDate='+(String.valueof(Date.Today().toStartOfWeek()))+'&ActivityType='+strActivityType;
        string emailBody=EmailToUse.Body+ '\n\n';
        emailBody +=filePath;
        mail.setPlainTextBody(emailBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}