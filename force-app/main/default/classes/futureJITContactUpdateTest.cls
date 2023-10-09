@IsTest
global class futureJITContactUpdateTest {
    @TestSetup
    global static void buildTestData(){
        Account a = new Account(Name='Acme', Dealer_Code__c='01234');
        insert a;

        Contact con = new Contact(
                AccountId = a.Id,
                LastName = 'portalUser'
        );
        insert con;

        Profile p = [select Id,name from Profile where Name = 'Dealer User Community Profile 1' Limit 1];
        User newUser = new User(
                profileId = p.Id,
                username = 'testuser@setdjithandler.com',
                email = 'testuser@setdjithandler.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='sjuser',
                lastname='portalUser',
                contactId = con.id,
            federationIdentifier='portal@123jit'
        );
        insert newUser;

    }
    
    global static Map<String,String> getTestAttributes(){
        Map<String,String> attMap = new Map<String,String>();
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/firstname','Test');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/lastname','User');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/email','uniqueEmail@a789031783180.com');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/dealersalesarea','01234:A');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/dealersalesdistrict','01234:01');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/currentdealercode','01234');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/dealer','01234');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/currentdealersalesdistrict','128');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/appname','128');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/spinid','777');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/currentdealerrole','Dealer Principal');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/currentdealername','AUTONATION TOYOTA PINELLAS PARK');
        attmap.put('http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn','portal@123jit');
        return attMap;
    }
    @IsTest
    global static void testJITContactUpdate(){
       // buildTestData();
        Map<String,String> attributes = getTestAttributes();
        User u = [SELECT Id, contactId,federationIdentifier FROM User WHERE username = 'testuser@setdjithandler.com' ];
        String federationIdentifier=u.FederationIdentifier;
        Id ContactId=u.ContactId;
        Test.startTest();
        futureJITContactUpdate.ContactUpdate(ContactId, attributes, federationIdentifier);
        Test.stopTest();
        
        System.assertEquals(1, [select count() from Contact where Current_SPIN__c='777']);
        
    }
    

}