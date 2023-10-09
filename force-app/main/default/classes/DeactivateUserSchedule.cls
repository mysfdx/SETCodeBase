/* Name:  DeactivateUserSchedule
Created By:  SET Salesforce System Admin
Created Date:  2020-01-11
Last Modified By:  SET Salesforce System Admin
Last Modified Date: 2020-01-11
Description:   
*/

global class DeactivateUserSchedule implements Schedulable{
	global void execute(SchedulableContext SC) {
       // calling DeactivateUser class. 
       
      DeactivateUsers.deactiveuser();
   }
}