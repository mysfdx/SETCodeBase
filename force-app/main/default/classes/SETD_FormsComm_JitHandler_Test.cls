@IsTest
global class SETD_FormsComm_JitHandler_Test {
    
    @IsTest 
    global static void testSETD_FormsComm_JitHandler (){
        //buildTestData();
        Map<String,String> attributes = getTestAttributes();
        
        String federationIdentifier = 'testFed@id'; 
        String userId = null;
        String samlSsoProviderId = null;
        String communityId = null;
        String portalId = null;
        String assertion = 'ASSERTION_IS_BASE64_PASSTHROUGH_DATA_FROM_SSO_PROVIDER';
        
        SETD_FormsComm_JitHandler tJitHandler = new SETD_FormsComm_JitHandler();
        tJitHandler.createUser(samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }
    
    @IsTest
    global static void testSETD_FormsComm_JitHandlerUpdate(){
        // buildTestData();
        Map<String,String> attributes = getTestAttributes();
        
        String federationIdentifier = 'testFed@id';
        String userId = null;
        String samlSsoProviderId = null;
        String communityId = null;
        String portalId = null;
        String assertion = 'ASSERTION_IS_BASE64_PASSTHROUGH_DATA_FROM_SSO_PROVIDER';
        
        SETD_FormsComm_JitHandler tJitHandler = new SETD_FormsComm_JitHandler();
        Account acc = [SELECT Id from Account WHERE Name ='Acme' AND Dealer_Code__c='01234'];
        User u = [SELECT Id FROM User WHERE username = 'testuser@setdjithandler.com' ];
        tJitHandler.updateUser(u.Id, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    }
    
    @TestSetup
    global static void buildTestData(){
       // Experience_Dealer_Roles__c expDealerRoles=new Experience_Dealer_Roles__c();
        //expDealerRoles.Name='Roles';
        //expDealerRoles.Dealer_Roles__c='Controller,Office Manager';
        //insert expDealerRoles;
        Account a = new Account(Name='Acme', Dealer_Code__c='01234');
        insert a;
        
        Contact con = new Contact(
            AccountId = a.Id,
            LastName = 'portalUser',
            Role__c='General Manager'
            
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
            contactId = con.id
        );
        insert newUser;
        
    }
    // Added by Neha Agrawal on 10/21/2021 to test CommUserProfileUpdate Apex class
    /*@isTest
    static void CommUserProfileUpdateTest() 
    {
        
        User u1 = [SELECT Id,Contact.Role__c,Profile.Name FROM User WHERE username = 'testuser@setdjithandler.com' ];
        List<CommUserProfileUpdate.userInfo> futureInputs= new List<CommUserProfileUpdate.userInfo>();
        
        CommUserProfileUpdate.userInfo userInfoInput = new CommUserProfileUpdate.userInfo();
        userInfoInput.commUser=u1;
        userInfoInput.contactRole=u1.Contact.Role__c;
        userInfoInput.profileName=u1.Profile.Name;
        futureInputs.add(userInfoInput);
        Test.startTest();
        CommUserProfileUpdate.callCommUserProfileFuture(futureInputs);
        Test.stopTest();
        
    }*/
    
    
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
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/currentdealerrole','Controller');
        attMap.put('http://schemas.jmfamily.com/set/identity/claims/currentdealername','AUTONATION TOYOTA PINELLAS PARK');
        attmap.put('http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn','testFed@id');
        return attMap;
    }
}