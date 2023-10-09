/*
Created by Sean Wallace, Salesforce Developer, 
Ad Victoriam Solutions on 9/16/19.


Changes done by Neha Agrawal on 5/7/2020
Changes by Neha Agrawal on 2/7/2022 to change SAML attribute from DealerRole to currentdealerrole
Changes by Neha Agrawal on 8/1/2022, Added Primary Dealer code and Primary Dealer name on contact

*/

global class SETD_FormsComm_JitHandler implements Auth.SamlJitHandler {
    
    private class JitException extends Exception{}
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        
        System.debug('Create User');
        
        System.debug('Attributes: ' + JSON.serializePretty(attributes));
        Contact con;
        String Usermail;
        String dealerCode = attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealercode');
        
        if(String.isNotEmpty(federationIdentifier)){
            Usermail = federationIdentifier.substringBefore('@')+'@setdealerdaily.com.set';
        }
        
        String UPN=attributes.get('http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn');
        String conusername=UPN.substringBefore('@');
        
        //dealerCode = dealerCode.substringBefore(':').removeStart('0');
        Id dealerProfile1 = [SELECT Id FROM Profile WHERE Name = 'Dealer User Community Profile 1' Limit 1].Id;
        Account acc;
        User CheckUser;
        
        // Existing User Checking
        system.debug('Existing Username '+ Usermail);
        try{
            CheckUser= [ SELECT Id FROM User WHERE username=:Usermail];
        }
        catch(System.QueryException e){
            system.debug('There is no existing user new can be created');
        }
        
        if((CheckUser!=null)) {
            MessageEvent__e ErrEvents = new MessageEvent__e(Error__c='Duplicate User',
                                                            ErrorDescription__c='Please check FedId or Username'+' '+Usermail+' '
                                                            +'correct FedID  '+federationIdentifier+' UPN is '+UPN,EntityID__c=CheckUser.Id);
            Database.SaveResult results=EventBus.publish(ErrEvents);
            if (results.isSuccess()) {
                System.debug('Successfully published User event.');
            } else {
                for(Database.Error err : results.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
            
            Throw new JitException('Duplicate Username '+' '+Usermail);
        }
        
        Contact CheckCon;
        String Conmail;
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/email')){
            Conmail =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/email');
        }        
        //Account Checking
        try{
            acc = [SELECT Id, Name, Email_List__c FROM Account WHERE Dealer_Code__c =: dealerCode LIMIT 1];
        }
        catch(System.QueryException e)
        {
            MessageEvent__e ErrEvents = new MessageEvent__e(Error__c='Account does not exist',
                                                            ErrorDescription__c='Dealer Code '+dealerCode+' '+'for '+UPN+ 'DD User with email '+Conmail);
            //Call method to publish events
            Database.SaveResult results = EventBus.publish(ErrEvents);
            // Inspect publishing result for each event
            
            if (results.isSuccess()) {
                System.debug('Successfully published account event.');
            } else {
                for(Database.Error err : results.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
            
            Throw new JitException('Account does not exist with Dealer Code '+' '+dealerCode);
        }
        
        
        RecordType conRT = [SELECT Id, Name from RecordType Where SobjectType = 'Contact' AND Name = 'Dealer Community Contact' Limit 1];
        
        // Contact Check
        try{
            CheckCon=[SELECT id, LastName, Email, Current_Dealer_Code__c from Contact where 
                      Current_Dealer_Code__c=:dealerCode and username__c=:conusername Limit 1];
        }
        catch(System.QueryException e){
            system.debug('New contact can be created');
        }
        
        if(CheckCon!=null)
        {
            MessageEvent__e ErrEvents = new MessageEvent__e(Error__c='Duplicate Contact',
                                                            ErrorDescription__c='Contact already Exist with Username__c or FEDid  '+conusername+' '
                                                            +'and Dealer Code  '+CheckCon.Current_Dealer_Code__c,EntityID__c=CheckCon.Id);
            //Call method to publish events
            Database.SaveResult results = EventBus.publish(ErrEvents);
            // Inspect publishing result for each event
            if (results.isSuccess()) {
                System.debug('Successfully published contact event.');
            } else {
                for(Database.Error err : results.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
            throw new JitException('Contact already exist'+' '+ CheckCon.LastName+' ' + 'already exist');                        
        }
        else{
            con = new Contact(
                AccountId = acc.Id,
                RecordTypeId = conRT.Id,
                LastName = attributes.get('http://schemas.jmfamily.com/set/identity/claims/lastname'),
                FirstName = attributes.get('http://schemas.jmfamily.com/set/identity/claims/firstname'),
                Username__c = conusername
                //federationIdentifier.substringBefore('@') 
                // this can be changed to UPN as ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn")
            );
        }
        User u = new User();
        
        con.Email =  Conmail;
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/dealer')){
            con.Primary_Dealer_Code__c=attributes.get('http://schemas.jmfamily.com/set/identity/claims/dealer');
            try{
            Account primaryDlrName = [SELECT Id, Name, Email_List__c FROM Account WHERE Dealer_Code__c =: dealerCode LIMIT 1];
                con.Primary_Dealer_Name__c=primaryDlrName.Name;
        }
        catch(System.QueryException e)
        {
            system.debug('Exception is '+ e.getCause()+' '+e.getMessage());
        }
        }
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/currentdealercode')){
            con.Current_Dealer_Code__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealercode');
        }
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/currentdealername')){
            con.Current_Dealer_Name__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealername');
        }
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/currentdealerrole')){
            System.debug('dealerrole is '+attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealerrole'));
            con.Current_Dealer_Role__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealerrole');
        }
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/currentdealersalesdistrict')){
            con.Current_Dealer_Sales_District__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealersalesdistrict');
        }
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/spinid')){
            con.Current_SPIN__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/spinid');
        }
        
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/appname')){
            con.Most_Recent_App_ID__c = attributes.get('http://schemas.jmfamily.com/set/identity/claims/appname');
            u.Most_Recent_App_ID__c = attributes.get('http://schemas.jmfamily.com/set/identity/claims/appname');
        }
        else{
            con.Most_Recent_App_ID__c = 'DD';
            u.Most_Recent_App_ID__c = 'DD';
        }
        
        try{
            Database.insert(con);
        }
        catch (DmlException e){
            System.debug('[SETD_FormsComm_JitHandler.createUser]: ' + e.getMessage());
        }
        
        u.ContactId = con.Id;
        u.ProfileId = dealerProfile1;
        
        u.Email = Conmail;
        u.Username = Usermail;
        u.FederationIdentifier = federationIdentifier;
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/firstname')) {
            u.FirstName = attributes.get('http://schemas.jmfamily.com/set/identity/claims/firstname');
        }
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/lastname')) {
            u.LastName = attributes.get('http://schemas.jmfamily.com/set/identity/claims/lastname');
        }
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/dealersalesarea')) {
            u.SET_Area__c = (String)attributes.get('http://schemas.jmfamily.com/set/identity/claims/dealersalesarea');
        }
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/dealersalesdistrict')) {
            u.SET_District__c = (String)attributes.get('http://schemas.jmfamily.com/set/identity/claims/dealersalesdistrict');
        }
        
        
        String uid = UserInfo.getUserId();
        User currentUser =  [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
        
        u.LocaleSidKey = currentUser.LocaleSidKey;
        u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        
        String alias = '';
        if(u.FirstName == null) {
            alias = u.LastName;
        } 
        else {
            alias = u.FirstName.charAt(0) + u.LastName;
        }
        if(alias.length() > 5) {
            alias = alias.substring(0, 5);
        }
        u.Alias = alias;
        u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        u.EmailEncodingKey = currentUser.EmailEncodingKey;
        
        System.debug('createUser: ' + JSON.serialize(u));
        
        
        return u; 
    }
    
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        System.debug('Attributes: ' + JSON.serializePretty(attributes));
        
        User u = [
            SELECT
            Id, Name, ContactId, FirstName, LastName, FederationIdentifier, Email, SET_Area__c,
            SET_District__c, Street, State, City, PostalCode, Profile.Name,
            Country, CallCenterId, ManagerId, MobilePhone, DelegatedApproverId,
            Department, Division, EmployeeNumber, Extension, Fax,
            CommunityNickname, Most_Recent_App_ID__c, ReceivesAdminInfoEmails, ReceivesInfoEmails, isActive, username
            FROM User WHERE Id=:userId
        ];
        
        
        u.isActive = true;
        Id ContactId= u.ContactId;
        
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/dealersalesarea')) {
            u.SET_Area__c = (String)attributes.get('http://schemas.jmfamily.com/set/identity/claims/dealersalesarea');
        }
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/dealersalesdistrict')) {
            u.SET_District__c = (String)attributes.get('http://schemas.jmfamily.com/set/identity/claims/dealersalesdistrict');
        }
        
        String uid = UserInfo.getUserId();
        User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
        
        u.LocaleSidKey = currentUser.LocaleSidKey;
        
        u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        
        String alias = '';
        if(u.FirstName == null) {
            alias = u.LastName;
        } else {
            alias = u.FirstName.charAt(0) + u.LastName;
        }
        if(alias.length() > 5) {
            alias = alias.substring(0, 5);
        }
        u.Alias = alias;
        
        
        u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        
        
        u.EmailEncodingKey = currentUser.EmailEncodingKey;
        
        
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/appname')){
            u.Most_Recent_App_ID__c = attributes.get('http://schemas.jmfamily.com/set/identity/claims/appname');
            //con.Most_Recent_App_ID__c = attributes.get('http://schemas.jmfamily.com/set/identity/claims/appname');
        }
        else{
            u.Most_Recent_App_ID__c = 'DD';
            //con.Most_Recent_App_ID__c = 'DD';
        }
        
        
        
        try{
            update u;
            System.debug('updatedUser: ' + JSON.serialize(u));
            system.debug('Calling Future Contact Update');
            futureJITContactUpdate.ContactUpdate(ContactId, attributes, federationIdentifier);
            System.debug('Contact Updated by Future');
            
            
        }
        catch (DmlException e){
            System.debug('Update ERROR: ' + e.getMessage());
        }
    }
    
}