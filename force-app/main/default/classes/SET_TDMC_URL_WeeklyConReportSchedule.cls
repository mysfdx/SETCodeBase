/* Name:  SET_TDMC_URL_WeeklyConReportSchedule
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global class SET_TDMC_URL_WeeklyConReportSchedule implements schedulable
{
    /*
        SET_TDMC_URL_WeeklyConReportSchedule scheduleReport = new SET_TDMC_URL_WeeklyConReportSchedule();
        string strSchTime = '0 0 7 ? * MON *';
        system.schedule('TDMC URL Weekly Contact Report', strSchTime, scheduleReport);
    */
    
    global void execute(SchedulableContext ctx)
    {
      /*****************************************************************
      Logic to read Email addresses from Public Group - Start
      *****************************************************************/  
      List<String> mailList = new List<String>();
      List<String> mailAddresses = new List<String>(); 
      String strActivityType = 'TDMC%20URL';
      Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'SET TDMC Weekly Email'];
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
        //String[] toAddresses = new String[] {'rakshik.bhan_contractor@jmfamily.com'};
        //mail.setToAddresses(toAddresses);
        
        EmailTemplate EmailToUse=new EmailTemplate();

        EmailToUse=[Select Subject,DeveloperName,Body From EmailTemplate e where DeveloperName='SET_TDMC_Weekly_Report_Email'];

        mail.settoAddresses(mailAddresses); 
                

        mail.setSenderDisplayName('DCMS - No Reply');
        mail.setSubject(EmailToUse.Subject+' ' +(String.valueof(Date.Today().toStartOfWeek())));
        mail.setBccSender(false);

        string baseUrl=URL.getSalesforceBaseUrl().getHost();
        string filePath='https://'+baseUrl+'/apex/SET_TDMC_URL_WeeklyContactReportPDF?activityType='+strActivityType ;
        string emailBody=EmailToUse.Body+ '\n\n';
        emailBody +=filePath;
        mail.setPlainTextBody(emailBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}