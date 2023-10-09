public class AccountSelector {

	private List<String> queryFields = new List<String> {
		'Dealer_Code__c',
		'Dealer_Number__c',
		'District__c',
		'Name'
	};

	public List<Account> selectById(Set<Id> ids) {
		return Database.query('SELECT ' + String.join(this.queryFields, ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<Id>(ids), '\',\'') + '\')');
	}

	public List<Account> selectByDealerCode(Set<String> codes) {
		return Database.query('SELECT ' + String.join(this.queryFields, ',') + ' FROM Account WHERE Dealer_Code__c IN (\'' + String.join(new List<String>(codes), '\',\'') + '\')');
	}
}