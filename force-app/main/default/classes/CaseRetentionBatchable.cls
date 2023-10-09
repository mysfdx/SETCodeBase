/* Name:  CaseRetentionBatchable
Created By:  Neha Agrawal
Created Date:  2020-03-20
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global class CaseRetentionBatchable implements Database.Batchable<SObject>, Database.Stateful {
	global List<Form_Retention__mdt> retentionMetadata;
	global String logMessage;
	global String errorDescription;
	global Boolean isSuccess;
	
	global CaseRetentionBatchable() {
		this.logMessage = 'Nothing to delete.';
		this.isSuccess = true;
		if (Test.isRunningTest()) {
			this.retentionMetadata = new List<Form_Retention__mdt> { new Form_Retention__mdt(Form_Name__c = 'INC Enrollment', Retention_Period__c = '0m', Record_Type__c = 'Case') };
		} else {
			this.retentionMetadata = [SELECT Id, Form_Name__c, Retention_Period__c, Record_Type__c FROM Form_Retention__mdt WHERE Active__c = TRUE];
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext batchableContext) {
		return queryCasesToDelete();
	}
	
	global void execute(Database.BatchableContext batchableContext, List<SObject> scope) {
		if (this.isSuccess) {
			Map<Id, Case> caseMap = new Map<Id, Case> ((List<Case>) scope);
			Set<Id> documentIds = new Set<Id> ();
			for (ContentDocumentLink link : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :caseMap.keySet()]) {
				documentIds.add(link.ContentDocumentId);
			}
			
			deleteRecords(caseMap.keySet(), documentIds);
		}
	}
	
	global void finish(Database.BatchableContext batchableContext) {
		insert new Form_Retention_Log__c(Success__c = this.isSuccess, Message__c = this.logMessage, Description__c = this.errorDescription);
	}
	
	@TestVisible
	private Database.QueryLocator queryCasesToDelete() {
		String query = 'SELECT Id, RecordType.Name, Form_Name__c FROM Case WHERE ';
		for (Integer i=0; i < this.retentionMetadata.size(); i++) {
			String formName = this.retentionMetadata[i].Form_Name__c;
			Datetime latestRetentionDateTime = getLatestRetentionDateTime(this.retentionMetadata[i].Form_Name__c, this.retentionMetadata[i].Retention_Period__c);
			query += '(RecordType.Name = \'' + this.retentionMetadata[i].Record_Type__c + '\' AND CreatedDate < :latestRetentionDateTime AND Form_Name__c = \'' + formName + '\')';
			query += i < (this.retentionMetadata.size()-1) ? ' OR ' : '';
		}
		return Database.getQueryLocator(query);
	}
	
	@TestVisible
	private Datetime getLatestRetentionDateTime(String formName, String retentionPeriodString) {
		Map<String, Integer> timeMap = new Map<String, Integer> ();
		try {
			retentionPeriodString = validateInputString(formName, retentionPeriodString);
			timeMap = getTimeMap(retentionPeriodString);
		} catch(Exception e) {
			this.isSuccess = false;
			this.logMessage = 'Invalid metadata setup.';
			this.errorDescription = e.getMessage();
		}
		
		Datetime nowDatetime = Datetime.now();
		for (String key : timeMap.keySet()) {
			if (key.equals('Y')) nowDatetime = nowDatetime.addYears(-(timeMap.get(key)));
			if (key.equals('M')) nowDatetime = nowDatetime.addMonths(-(timeMap.get(key)));
			if (key.equals('D')) nowDatetime = nowDatetime.addDays(-(timeMap.get(key)));
			if (key.equals('h')) nowDatetime = nowDatetime.addHours(-(timeMap.get(key)));
			if (key.equals('m')) nowDatetime = nowDatetime.addMinutes(-(timeMap.get(key)));
		}
		return nowDatetime;
	}
	
	private String validateInputString(String formName, String retentionPeriodString) {
		retentionPeriodString = retentionPeriodString.replaceAll('\\s', '');
		if (!retentionPeriodString.isAlphanumeric()) {
			throw new InvalidPeriodRetentionFormatException('Retention Period setup for ' + formName + ' forms is invalid. Format should follow the following format: xY xM xD xh xm');
		}
		return retentionPeriodString;
	}
	
	private Map<String, Integer> getTimeMap(String retentionPeriodString) {
		Map<String, Integer> timeMap = new Map<String, Integer> ();
		Integer previousIndex = 0;
		for (Integer i=0; i<retentionPeriodString.length(); i++) {
			String charVar = retentionPeriodString.substring(i, i+1);
			if (charVar.isAlpha()) {
				timeMap.put(charVar, Integer.valueOf(retentionPeriodString.substring(previousIndex, i)));
				previousIndex = i + 1;
			}
		}
		return timeMap;
	}
	
	@TestVisible
	private void deleteRecords(Set<Id> caseIds, Set<Id> documentIds) {
		List<String> failedDocuments = new List<String> ();
		Integer deletedFiles = 0;
		for (Database.DeleteResult result : Database.delete(new List<Id> (documentIds), false)) {
			if (!result.isSuccess()) {
				failedDocuments.add(result.getId());
			} else {
				deletedFiles++;
			}
		}
		
		List<String> failedCases = new List<String> ();
		Integer deletedCases = 0;
		for (Database.DeleteResult result : Database.delete(new List<Id> (caseIds), false)) {
			if (!result.isSuccess()) {
				failedCases.add(result.getId());
			} else {
				deletedCases++;
			}
		}
		
		if (!failedDocuments.isEmpty() || !failedCases.isEmpty()) {
			this.isSuccess = false;
			this.logMessage = 'Records failed to be deleted.';
			this.errorDescription = 'Failed to run full process successfully. ' + failedCases.size() + ' Case records and ' + failedDocuments.size() + ' files failed to be deleted.';
		} else {
			this.logMessage = 'Case retention process has run successfully.';
			this.errorDescription = deletedCases + ' Cases were deleted and ' + deletedFiles + ' files were deleted.';
		}
	}
	
	public class InvalidPeriodRetentionFormatException extends Exception { }
}