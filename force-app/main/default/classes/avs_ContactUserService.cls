/*
 Change Log
17th Sep 2020 - Neha Agrawal, user alredy exist check has been added in insertNewUser function and new username should
be like SPIN@setdealerdaily.com.set.uat in UAT and SPIN@setdealerdaily.com.set in PROD
*/

public class avs_ContactUserService {
	
	public Contact queryContactRecord(String username) {
		ContactSelector selector = new ContactSelector();
		List<Contact> contacts = selector.selectByUsername(new Set<String> { validateUsername(username) });
		return contacts.isEmpty() ? null : contacts.get(0);
	}
	
	public Contact insertNewContactRecord(Contact contactRecord, Id accountId) {
		contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealer Community Contact').getRecordTypeId();
		contactRecord.AccountId = accountId;
		contactRecord.Username__c = validateUsername(contactRecord.Username__c);
		insert contactRecord;
		return contactRecord;
	}
	
	public Contact updateContactRecord(Contact contactRecord, Id existingContactId) {
		Contact updatedContact = new Contact(
			Id = existingContactId,
			Phone = contactRecord.Phone,
			Current_Dealer_Role__c = contactRecord.Current_Dealer_Role__c,
			Current_Dealer_Code__c = contactRecord.Current_Dealer_Code__c
		);
		update updatedContact;
		contactRecord.Id = existingContactId;
		return contactRecord;
	}
	
	public void insertNewUser(Contact contact, String federationId) {
        user exists;
        string existingusername=validateUsername(federationId)+'@setdealerdaily.com.set.uat'; // For UAT
       //string existingusername=validateUsername(federationId)+'@setdealerdaily.com.set'; // For PROD
        try{
            exists=[select id, email from user where username=:existingusername or federationidentifier=:federationId];
        
        }
        catch(exception e)
        {
            system.debug('Exception occured '+ e);
        }
        if(exists!=null){
            throw new avs_ResourceException('SalesforceException', 'User already exist with this Email or FederationId ', '');
        }
		User newUser = new User(
			ContactId = contact.Id,
		   Username = validateUsername(federationId)+'@setdealerdaily.com.set.uat', // For UAT
			//Username = validateUsername(federationId)+'@setdealerdaily.com.set', //For PROD
			FirstName = contact.FirstName,
			LastName = contact.LastName,
			Alias = createAlias(contact.Username__c),
			Email = contact.Email,
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'Dealer User Community Profile 1'].Id,
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			FederationIdentifier = federationId
		);
		insert newUser;
	}
	
	private String createAlias(String username) {
		Integer randomInt = Integer.valueOf(Math.rint(Math.random()*10000));
		String alias = username.contains('@') ? username.split('@')[0] + String.valueOf(randomInt) : username + String.valueOf(randomInt);
		return (alias.length() > 8) ? alias.substring(0, 8) : alias;
	}
	
	private String validateUsername(String username) {
		username = username.replaceAll('@dp$', '');
		username = username.replaceAll('@DP$', '');
		username = username.replaceAll('@jm$', '');
		username = username.replaceAll('@JM$', '');
		return username;
	}
}