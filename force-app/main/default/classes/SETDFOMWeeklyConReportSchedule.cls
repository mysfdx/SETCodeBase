/* Name:  SETDFOMWeeklyConReportSchedule
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global class SETDFOMWeeklyConReportSchedule implements schedulable
{
    /*
        Modified on 2/18 to include the additional parameter as Activity Type to the SETDFOMWeeklyContactReportPDF page.
        Modified on 3/2 by kishore and ticket#TKT0688027, to comment the mail.setToAddresses(toAddresses) and uncomment the mail.settoAddresses(mailAddresses); 
    */

    /*
        SETDFOMWeeklyConReportSchedule scheduleReport = new SETDFOMWeeklyConReportSchedule();
        string strSchTime = '0 0 7 ? * MON *';
        system.schedule('DFOM Weekly Contact Report', strSchTime, scheduleReport);
    */
    
    global void execute(SchedulableContext ctx)
    {
      /*****************************************************************
      Logic to read Email addresses from Public Group - Start
      *****************************************************************/  
        List<String> mailList = new List<String>();
        List<String> mailAddresses = new List<String>(); 
        String strActivityType = 'All';  //Added on 2/18 
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'SET DFOM Weekly Email'];
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

        EmailToUse=[Select Subject,DeveloperName,Body From EmailTemplate e where DeveloperName='SET_DFOM_Weekly_Report_Email'];

        mail.settoAddresses(mailAddresses); 
                

        mail.setSenderDisplayName('DCMS - No Reply');
        mail.setSubject(EmailToUse.Subject+' ' +(String.valueof(Date.Today().toStartOfWeek() - 6))+ ' to '+(String.valueof(Date.Today().toStartOfWeek())));
        mail.setBccSender(false);

        string baseUrl=URL.getSalesforceBaseUrl().getHost();
        //string filePath='https://'+baseUrl+'/apex/SETDFOMWeeklyContactReportPDF?startDate='+(String.valueof(Date.Today().toStartOfWeek() - 6))+ '&endDate='+(String.valueof(Date.Today().toStartOfWeek()));
        //added the ActivityType Parameter to the below URL.
        string filePath='https://'+baseUrl+'/apex/SETDFOMWeeklyContactReportPDF?startDate='+(String.valueof(Date.Today().toStartOfWeek() - 6))+ '&endDate='+(String.valueof(Date.Today().toStartOfWeek()))+'&ActivityType='+strActivityType;
        string emailBody=EmailToUse.Body+ '\n\n';
        emailBody +=filePath;
        mail.setPlainTextBody(emailBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}