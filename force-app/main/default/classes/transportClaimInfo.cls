/*Name:transportClaimInfo
Purpose: Used to get existing contact information like name, phone and email from user's community account and associated
Dealer code, used in TranportClaimFormController class, ENHC0012574
Author:Neha Agrawal
Date:2/3/2021

Change Log
Date - Changed by - Change Description
*/


public class transportClaimInfo {
    
    /*
    to Initiate the Transport Claim record with current contact information and Dealer Code.
    */
    public claimInfo createTransportClaim(){
        User userRecord = getCurrentUser();
		Contact contactRecord = getContactRecord(userRecord.ContactId);
		Account accountRecord = getAccountRecord(contactRecord);
        Transportation_claim__c claimRecord=new Transportation_claim__c(
            Dealer__c=accountRecord == null ? null : accountRecord.Id,
            Contact_Email__c=contactRecord.Email == null ? null : contactRecord.Email,
            Contact_Phone__c=contactRecord.Phone== null ? null : contactRecord.Phone,
            Contact_Name__c=contactRecord.Name== null ? null : contactRecord.Name
        );
        return new claimInfo(accountRecord,claimRecord);
    }
    /*
     Used to find currently running user
    */
    private User getCurrentUser() {
        UserSelector selector = new UserSelector();
        return selector.selectById(new Set<Id> { UserInfo.getUserId() }).get(0);
    }
    /*
     Used to find associated contact for running user
    */
    private Contact getContactRecord(Id contactId) {
        ContactSelector contactSelector = new ContactSelector();
        List<Contact> queriedContacts = new List<Contact> ();
        if(String.isNotBlank(contactId)) {
            queriedContacts = contactSelector.selectById(new Set<Id> { contactId });
        }
        return queriedContacts.isEmpty() ? null : queriedContacts.get(0);
    }
    /*
     Used to find associated Dealer for running user
    */
    private Account getAccountRecord(Contact contactRecord) {
        AccountSelector accountSelector = new AccountSelector();
        List<Account> queriedAccounts = new List<Account> ();
        if (contactRecord != null) {
            queriedAccounts = accountSelector.selectByDealerCode(new Set<String> { contactRecord.Current_Dealer_Code__c });
            if (queriedAccounts.isEmpty()) {
                queriedAccounts = accountSelector.selectById(new Set<Id> { contactRecord.AccountId });
            }
        }
        return queriedAccounts.isEmpty() ? null : queriedAccounts.get(0);
    }
    public class claimInfo {
        @AuraEnabled public Account accountObject { get; set; }
        @AuraEnabled public Transportation_claim__c transportClaimObject { get; set; }
        
        public claimInfo(Account accountObject, Transportation_claim__c transportClaimObject) {
            this.accountObject = accountObject;
            this.transportClaimObject = transportClaimObject;
        }
    }
    
}