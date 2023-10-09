@isTest
public with sharing class TestClientUtils {
    
    public static Contact createContact(Id AccountId) {
        return new Contact(AccountId = AccountId, LastName = 'Test');
    }
    
    public static Exception_Request__c createExceptionRequest(String status, String reqType, 
                                                             Integer vin1Amount, Integer manualVinAmount,
                                                             String reqEmail) {
        return new Exception_Request__c(Status__c=status,Exception_Request_Type__c=reqType,
                                                            VIN_1_Amount__c=vin1Amount,
                                                            Manual_Total_VIN_Amount__c=manualVinAmount,
                                       Requester_Email__c=reqEmail);
    }
    
    public static ContentVersion createCV(String title, String pathOnClient, String verData){
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = pathOnClient;
        cv.VersionData = Blob.valueOf(verData);
        return cv;
    }
    
    public static ContentDocumentLink createCDL(String entityId, String shareType, String conDocId){
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = entityId;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = shareType;
        return cdl;
    }
    
    public static Facility__c createFacility(Id AccountId) {        
        return new Facility__c(Account__c = AccountId
                                  , Name = 'Test');
    }
    public static Factory_Warranty_Reports__c createFWReport(Id AccountId, String fwRecordTypeName) {
      string fwRecordTypeId = Schema.SObjectType.Factory_Warranty_Reports__c.getRecordTypeInfosByDeveloperName().get(fwRecordTypeName).getRecordTypeId();     
        return new Factory_Warranty_Reports__c(Dealer__c = AccountId, RecordTypeId=fwRecordTypeId, 
                                               Name = 'Test');
    }
    
    public static SET_Dealer_Performance_Metrics__c createSetDealerPerformanceMetrics(Id AccountId, Date asOfDate)  {
        return new SET_Dealer_Performance_Metrics__c(Dealership__c = AccountId
                                                    ,As_of_Date__c = asOfDate);
    }
    
    public static Task createTask(Id whatId, Id whoId) {
        return new Task(Subject = 'Test1'
                      , ActivityDate = System.Today() + 1
                      , Description = 'this is a test'
                      , Status = 'New'
                      , WhatId = whatId
                      , Activity_Type__c = 'Awards'
                      , WhoId = whoId);
    }
    
    public static Event createEvent(Id whatId, Id whoId) {
        
        return new Event(Subject = 'Test1'
                      , ActivityDateTime = System.now().addDays(1)
                      , DurationInMinutes = 60
                      , Description = 'this is a test'
                      , WhatId = whatId
                      , WhoId = whoId);
    } 
    
    public static Toyota_Dealer_Agreements__c createToyotaDealerAgreements(Id accountId) {
          return new Toyota_Dealer_Agreements__c(Account__c = accountId
                                                ,Active__c = true);
    }
    
    public static Packages__c createPackages(Id accountId, Id tda) {
        return new Packages__c(Account__c = accountId, Toyota_Dealer_Agreements__c = tda);
    }

   
   public static District_Area_Ownership_Mapping__c createDistrictAreaOwnershipMapping(string area, string district, string ownerId, string level) {
       return new District_Area_Ownership_Mapping__c(Area__c = area
                                                    ,District__c = district
                                                    ,Level__c = level
                                                    ,ownerId = ownerId);
   }
   
   public static Group createGroup(string grpName){
        Group grpRec=new Group(Name=grpName);
        return grpRec;
    }
    
    public static GroupMember createGroupMbr(ID grpID,string UsrId){
        GroupMember grpMbrRec=new GroupMember(GroupID=grpID,UserOrGroupId=UsrId);
        return grpMbrRec;
    }
    
    public static User createUser(ID profileId,string firstName,string LastName,string EmailVal,string userID){
        User usrRec = new User(Alias = 'standt', Email=EmailVal, 
        EmailEncodingKey='UTF-8', LastName=LastName,FirstName=firstName,LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileId, 
        TimeZoneSidKey='America/Los_Angeles', UserName=userID, Division='SET');             
        return usrRec;
    }
    
    
    public static Competitive_Contact__c createCompContact(string fullname,string firstname,string lastname){
      Competitive_Contact__c cmpContact=new Competitive_Contact__c(name=fullname,First_Name__c=firstname,Last_Name__c=lastname);
      
      return cmpContact;
      
    }
    
    public static LIST<Task> createTask(LIST<Id> whatIds,string subj,string StatusVal) {
        LIST<Task> lstTsks=new LIST<Task>();
        for (ID recID:whatIds){
            Task tskRec= new Task(Subject = subj
                      , ActivityDate = System.Today() + 1
                      , Description = 'this is a test'
                      , Status = StatusVal
                      , Activity_Type__c = 'Awards'
                      , WhatId = recID);
            lstTsks.add(tskRec);          
                    
        }                     
        return lstTsks;                      
    }
    
   
    public static ID createCustomSetting(string csName,string template,string grpName,string repVal) {        
        LIST <Send_Email_Info__c> CmplCustSet=new LIST<Send_Email_Info__c>(); 
        CmplCustSet=[SELECT ID FROM Send_Email_Info__c WHERE name=:csName limit 1];
        if (CmplCustSet.size()==0){
            Send_Email_Info__c cmpRec=new Send_Email_Info__c (Name=csName,Email_template_to_use__c=template,Group_Name__c=grpName,replace_field_in_template__c=repVal);
            insert cmpRec;
            return cmpRec.Id;
        }
        else {
            return CmplCustSet[0].Id;
        }
    }
    
    
     public static ID createEmailTemplate(string subject,string emailBody,string templateName,ID folderid) {        
        LIST<EmailTemplate> lstEmailTmplt=new LIST<EmailTemplate>();
        lstEmailTmplt=[SELECT ID FROM EmailTemplate WHERE DeveloperName=:templateName limit 1 ];        
        return lstEmailTmplt[0].Id;
        
    }
    
    public static Account createAccount() {     
        Account acctRec=new Account();
        string dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();
        acctRec.RecordTypeId = dealerRecordTypeId;
        acctRec.Name='A Test Account';
        acctRec.Dealer_Code__c='Tst';
        acctRec.District__c='7';
        return acctRec;
    }
    
    public static DPR__c createDPR() {
        DPR__c dprRec = new DPR__c();   
        return dprRec;
    }
    
    public static SET_DISTRICT_INFO__c createDistrictInfo(Boolean boolCreate) {
        SET_DISTRICT_INFO__c obj = new SET_DISTRICT_INFO__c(Name = '100');
        if ( boolCreate ) 
           insert obj;
        return obj;
    }
    
    public static Account getAccount(String name) {
        Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();
        Account newAccount = new Account();
        newAccount.Name = name;
        newAccount.RecordTypeId = acctRecordTypeId;
        return newAccount;
    }
    
    public static DS_Vendor__c getVendor(String name) {
        DS_Vendor__c vendor = new DS_Vendor__c();
        vendor.Name = name;
        return vendor;
    }
    
    public static DS_Product__c getProduct(String name, String rType, String type) {
        Id prodRecordTypeId = Schema.SObjectType.DS_Product__c.getRecordTypeInfosByName().get(rType).getRecordTypeId();
        DS_Product__c product = new DS_Product__c();
        product.RecordTypeId = prodRecordTypeId;
        product.Name = name;
        product.Type__c = type;
        return product;
    }
    
    public static DS_Subcategory__c getSubcategory(String name, String type)
    {
        DS_Subcategory__c subcategory = new DS_Subcategory__c();
        subcategory.Name = name;
        subcategory.Type__c = type;
        return subcategory;
    }
    
    public static DS_Contact__c getDSContact(String name, String lastName, String email, String phone)
    {
        DS_Contact__c contact = new DS_Contact__c();
        contact.Name = name;
        contact.Last_Name__c = lastName;
        contact.Email__c = email;
        contact.Cell_Phone__c = phone;
        return contact;
    }
    
    public static DS_Link__c getLink(String name, String accountId, String productId, String vendorId)
    {
        DS_Link__c link = new DS_Link__c();
        link.Name = name;
        link.Account__c = accountId;
        link.Product__c = productId;
        link.Vendor__c = vendorId;
        return link;
    }
    
    public static List < Account > createAccounts(Integer recordCount, Boolean createBool) {
        Id acctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();
        List < Account > listAccounts = new List < Account >();        
        for( Integer i = 0 ; i < recordCount; i++) {
            Account newAccount = new Account();
            newAccount.Name = 'Test Dealer Service Account';
            newAccount.JMA_Business_Unit__c = 'DS';
            newAccount.RecordTypeId = acctRecordTypeId;
            newAccount.Dealer_Code__c = 'zz' + String.valueOf(i);
            newAccount.District__c = '1';
            listAccounts.add(newAccount);
        }
        if ( createBool )
        insert listAccounts;
        return listAccounts;
    }
    
    public static List < Contact > createContacts(List < Account > listAccounts, Integer recordCount, Boolean createBool) {
        List < Contact > listContacts = new List < Contact >();        
        for( Integer i = 0 ; i < recordCount; i++) {
            Contact newContact = new Contact();
            newContact.FirstName = 'Test';
            newContact.LastName = 'Test';
            if ( listAccounts.size() > i)
            newContact.AccountId = listAccounts.get(i).Id;
            else 
            newContact.AccountId = listAccounts.get(0).Id;
            listContacts.add(newContact);
        }
        if ( createBool )
        insert listContacts;
        return listContacts;
    }
    
    public static List < Case > createCases(List < Account > listAccounts, Integer recordCount, Boolean createBool) {        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SET DS Case').getRecordTypeId();
        List < Case > listCases = new List < Case >();        
        for( Integer i = 0 ; i < recordCount; i++) {
            Case newCase = new Case();
            newCase.RecordTypeId = caseRecordTypeId;
            newCase.JMA_Business_Unit__c = 'Dealer Services';
            newCase.DS_Time_Spent_In_Minutes__c = 5;
            newCase.DS_Time_Entry_Mins__c = '5';
            newCase.DS_Time__c = '2';
            if ( listAccounts.size() > i)
            newCase.AccountId = listAccounts.get(i).Id;
            else 
            newCase.AccountId = listAccounts.get(0).Id;
            listCases.add(newCase);
        }
        if ( createBool )
            insert listCases;
        return listCases;
    }
    
    public static List < CaseComment > createCaseComments(List < Case > listCases, Integer recordCount, Boolean createBool) {
        List < CaseComment > listCaseComments = new List < CaseComment >();        
        for( Integer i = 0 ; i < recordCount; i++) {
            CaseComment newCaseComment = new CaseComment();
            newCaseComment.CommentBody = 'Test Dealer Service Case Comment';
            if ( listCases.size() >= i)
            newCaseComment.ParentId = listCases.get(i).Id;
            else 
            newCaseComment.ParentId = listCases.get(0).Id;
            listCaseComments.add(newCaseComment);
        }
        if ( createBool )
            insert listCaseComments;
        return listCaseComments;
    }
    
    public static List<DS_Customer_Details__c> createCustomerDetails(List < Case > listCases, Integer recordCount, Boolean createBool) {
        List < DS_Customer_Details__c > listCustomerDetails = new List < DS_Customer_Details__c >();        
        for ( Integer i = 0 ; i < recordCount; i++ ) {
            DS_Customer_Details__c newCustDetail = new DS_Customer_Details__c();
            newCustDetail.Name = 'Test';
            newCustDetail.DS_Customer_Email__c = 'test@test.com';
            if ( listCases.size() >= i )
                newCustDetail.DS_Customer_Name__c = listCases.get(i).Id;
            else 
                newCustDetail.DS_Customer_Name__c = listCases.get(0).Id;
            listCustomerDetails.add(newCustDetail);
        }
        if ( createBool )
            insert listCustomerDetails;
        return listCustomerDetails;
    }
    
    public static List < DS_Time_Worked__c > createTimeWorked(List < Case > listCases, Integer recordCount, Boolean createBool) {
        List < DS_Time_Worked__c > listTimeWorked = new List < DS_Time_Worked__c >();        
        for ( Integer i = 0 ; i < recordCount; i++ ) {
            DS_Time_Worked__c newTimeWorked = new DS_Time_Worked__c();
            newTimeWorked.Name = '10 Minutes';
            if ( listCases.size() >= i )
                newTimeWorked.DS_Time_Case__c = listCases.get(i).Id;
            else 
                newTimeWorked.DS_Time_Case__c = listCases.get(0).Id;
            listTimeWorked.add(newTimeWorked);
        }
        if ( createBool )
            insert listTimeWorked;
        return listTimeWorked;
    }
    
    public static DS_Vendor_Product__c getVendorProd(DS_Vendor__c vendor, DS_Product__c prod, Boolean createBool) {
        DS_Vendor_Product__c vendorPrd = new DS_Vendor_Product__c(Product__c = prod.Id, Vendor__c = vendor.Id);
        if ( createBool )
            insert vendorPrd;
        return vendorPrd;
    }
    
    public static DS_Product_Subcategory__c getProdSubProd(DS_Product__c prod, DS_Subcategory__c subProd, Boolean createBool) {
        DS_Product_Subcategory__c ProdSubProd = new DS_Product_Subcategory__c(Product__c = prod.Id, Subcategory__c = subProd.Id);
        if ( createBool )
            insert ProdSubProd;
        return ProdSubProd;
    }
    
    public static DS_Dealer_Product__c getDealerProd(Id acctId, Id prodId, Boolean createBool) {
        DS_Dealer_Product__c dealerProd = new DS_Dealer_Product__c(Dealer__c = acctId, Product__c = prodId);
        if ( createBool )
            insert dealerProd;
        return dealerProd;
    }
    
    public static Dealer_Product_Subproduct__c getDealerSubProd(Id acctId, Id prodId, Id subProdId, Boolean createBool) {
        Dealer_Product_Subproduct__c dealerSubProd = new Dealer_Product_Subproduct__c(DS_Account_Dealer__c = acctId, DS_Product__c = prodId, DS_Subproduct__c = subProdId);
        if ( createBool )
            insert dealerSubProd;
        return dealerSubProd;
    }

}