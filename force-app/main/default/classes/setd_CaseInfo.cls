/*
Change Log
9/10/2020 - Neha Agrawal - used Dealer Incentive Challenge record type for Incentive Challenge Forms instaed of DD Forms.

*/

public class setd_CaseInfo {

	public CaseInfo createCaseInfoByFormName(String formName) {
		User userRecord = getCurrentUser();
		Contact contactRecord = getContactRecord(userRecord.ContactId);
		Account accountRecord = getAccountRecord(contactRecord);
		Case caseRecord = createCaseObject(formName, contactRecord, accountRecord);

		return new CaseInfo(userRecord, contactRecord, accountRecord, caseRecord);
	}

	private User getCurrentUser() {
		UserSelector selector = new UserSelector();
		return selector.selectById(new Set<Id> { UserInfo.getUserId() }).get(0);
	}

	private Contact getContactRecord(Id contactId) {
		ContactSelector contactSelector = new ContactSelector();
		List<Contact> queriedContacts = new List<Contact> ();
		if(String.isNotBlank(contactId)) {
			queriedContacts = contactSelector.selectById(new Set<Id> { contactId });
		}
		return queriedContacts.isEmpty() ? null : queriedContacts.get(0);
	}

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

	@TestVisible
	private Case createCaseObject(String formName, Contact contact, Account account) {
       
        Case caseRecord;
       if(formName=='Incentives Challenge')
        {
            caseRecord = new Case (
			Form_Name__c = formName,
			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dealer Incentives Challenge').getRecordTypeId(),
			Community_Contact__c = contact == null ? null : contact.Id,
			AccountId = account == null ? null : account.Id
		);
        }
		
       else{
            caseRecord = new Case (
			Form_Name__c = formName,
			RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DD Forms').getRecordTypeId(),
			Community_Contact__c = contact == null ? null : contact.Id,
			AccountId = account == null ? null : account.Id
		);
        }
		return caseRecord;
	}

	public class CaseInfo {
		@AuraEnabled public User userObject { get; set; }
		@AuraEnabled public Account accountObject { get; set; }
		@AuraEnabled public Contact contactObject { get; set; }
		@AuraEnabled public Case caseObject { get; set; }

		public CaseInfo(User userObject, Contact contactObject, Account accountObject, Case caseObject) {
			this.userObject = userObject;
			this.contactObject = contactObject;
			this.accountObject = accountObject;
			this.caseObject = caseObject;
		}
	}
}