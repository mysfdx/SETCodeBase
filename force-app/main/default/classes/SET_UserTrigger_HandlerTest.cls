@isTest
private class SET_UserTrigger_HandlerTest {

    static testMethod void testSET_UserTrigger_Handler() {
        Profile profile = [Select Id from Profile Where Name like 'SET%' limit 1];
        
        UserRole userRole = [Select Id from UserRole Limit 1];
        
        User userNew = new User();
        userNew.FirstName = 'firstName';
        userNew.LastName = 'lastName';
        userNew.Alias = 'pTst';
        userNew.Username = userNew.Email = 'setEmail@testNew.com';
        userNew.EmailEncodingKey = 'UTF-8';
        userNew.LanguageLocaleKey = 'en_US';
        userNew.LocaleSidKey = 'en_US';
        userNew.TimeZoneSidKey = 'America/Los_Angeles';
        userNew.ProfileId = profile.Id;
        userNew.SET_Area__c = 'A';
        userNew.SET_District__c = '01';
        userNew.LOB__c = 'SET';
        userNew.UserRoleId = userRole.Id;
        insert userNew;
        
        userNew.FirstName = 'testFirstName';
        update userNew;
    }
    
}