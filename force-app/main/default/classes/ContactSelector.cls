/* Name:  ContactSelector
Created By:  SET Salesforce System Admin
Created Date:  2019-12-14
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public class ContactSelector {

	private List<String> queryFields = new List<String> {
		'AccountId',
		'Current_Dealer_Code__c',
        'Primary_Dealer_Code__c',   
        'Primary_Dealer_Name__c',    
		'Email',
		'FirstName',
		'LastName',
		'MobilePhone',
		'Name',
		'Phone',
		'Title',
		'Username__c'
	};

	public List<Contact> selectById(Set<Id> ids) {
		return Database.query('SELECT ' + String.join(this.queryFields, ',') + ' FROM Contact WHERE Id IN (\'' + String.join(new List<Id>(ids), '\',\'') + '\')');
	}
	
	public List<Contact> selectByEmail(Set<String> emails) {
		return Database.query('SELECT ' + String.join(this.queryFields, ',') + ' FROM Contact WHERE Email IN (\'' + String.join(new List<String>(emails), '\',\'') + '\')');
	}
	
	public List<Contact> selectByUsername(Set<String> usernames) {
		return Database.query('SELECT ' + String.join(this.queryFields, ',') + ' FROM Contact WHERE Username__c IN (\'' + String.join(new List<String>(usernames), '\',\'') + '\')');
	}
}