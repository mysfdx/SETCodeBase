/* Name:  UserSelector
Created By:  SET Salesforce System Admin
Created Date:  2019-12-14
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-02-28
Description:   
*/

public class UserSelector {

	private List<String> queryFields = new List<String> {
		'ContactId',
		'Email',
		'FirstName',
		'LastName',
		'Name',
		'Phone',
		'Username'
	};

	public List<User> selectById(Set<Id> ids) {
		return Database.query('SELECT ' + String.join(this.queryFields, ',') + ' FROM User WHERE Id IN (\'' + String.join(new List<Id>(ids), '\',\'') + '\')');
	}
	
	public List<User> selectByUsername(Set<String> usernames) {
		return Database.query('SELECT ' + String.join(this.queryFields, ',') + ' FROM User WHERE Username IN (\'' + String.join(new List<String>(usernames), '\',\'') + '\')');
	}
	
	public List<User> selectByFederationId(Set<String> ids) {
		return Database.query('SELECT ' + String.join(this.queryFields, ',') + ' FROM User WHERE FederationIdentifier IN (\'' + String.join(new List<String>(ids), '\',\'') + '\')');
	}
	
	public List<User> selectByContactId(Set<Id> ids) {
		return Database.query('SELECT ' + String.join(this.queryFields, ',') + ' FROM User WHERE ContactId IN (\'' + String.join(new List<Id>(ids), '\',\'') + '\')');
	}
}