/* Name:  DeactivateUsers
Created By:  SET Salesforce System Admin
Created Date:  2020-01-11


Change Log

Date - Changed by - Change Description
8th Sept 2021 -- Neha Agrawal -- Made change to query so only Active users will be queried and added job running flag 
                                 to prevent user trigger execution.

*/

public class DeactivateUsers {
    
    public static boolean deactivateUserJobRunning=False;
    
    public static void deactiveuser(){
        try{
            
            
            Deactivate_Profile_User__mdt[] deactive_users = [Select MasterLabel, Days__c from Deactivate_Profile_User__mdt];
            
            
            for(Deactivate_Profile_User__mdt deactive_user : deactive_users ){
                
                List<User> LstUser = new list<User>{};
                    DateTime newDate = null;
                Integer days = integer.valueOf(deactive_user.Days__c);
                //System.debug('Inactive :Label'+ deactive_user.MasterLabel);
                //System.debug('Inactive Days'+ deactive_user.Days__c);
                
                if (days == 0){
                    newDate = System.Now();
                    
                }
                Else{
                    newDate = newDate = System.Now().addDays(-days);
                }
                
                for(User InactiveUser :[select id,LastLoginDate   from User 
                                        Where IsActive=True  AND  Profile.name =:deactive_user.MasterLabel AND (LastLoginDate <=:newDate or LastLoginDate =null)])
                {
                    InactiveUser.IsActive = false;//Make'em inactive
                    System.debug('Inactive Users'+ InactiveUser.IsActive);
                    System.debug('Inactive Users'+ InactiveUser.LastLoginDate);
                    LstUser.add(InactiveUser);
                }
                deactivateUserJobRunning=True;
                update LstUser; //User the Community Plus User 
                deactivateUserJobRunning=False;
            }
        }
        
        catch(Exception ex){
            System.debug('Exception_Line_No->'+ex.getLineNumber());
            System.debug('Exception_Message->'+ex.getMessage());
        }
        
    }
}