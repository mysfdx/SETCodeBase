@IsTest
private class CaseRetentionBatchableTest {
    
    @TestSetup
    private static void setupTest() {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Case' LIMIT 1].Id;
        
        Case testCase1 = new Case(RecordTypeId = recordTypeId, Form_Name__c = 'Incentives Challenge');
        Case testCase2 = new Case(RecordTypeId = recordTypeId, Form_Name__c = 'Incentives Challenge');
        Case testCase3 = new Case(RecordTypeId = recordTypeId, Form_Name__c = 'INC Enrollment');
        insert new List<Case> { testCase1, testCase2, testCase3 };
    }
    
    @IsTest
    private static void batch_test() {
        Test.startTest();
        Database.executeBatch(new CaseRetentionBatchable());
        Test.stopTest();
    }

    @IsTest
    private static void buildQuery_TESTINGRecordType_CorrectFormattedString() {
        CaseRetentionBatchable testBatch = new CaseRetentionBatchable();
        Database.QueryLocator result = testBatch.queryCasesToDelete();

        System.assertNotEquals(null, result, 'QueryLocator did not return anything successfully');
    }
    
    @IsTest
    private static void getLatestRetentionDateTime_1Day30Minutes_CorrectDateTime() {
        Datetime testDatetime = Datetime.now();
        CaseRetentionBatchable testBatch = new CaseRetentionBatchable();
        Datetime result = testBatch.getLatestRetentionDateTime('form name', ' 1D   30m ');
        testDatetime = testDatetime.addMinutes(-30);
        testDatetime = testDatetime.addDays(-1);
        
        System.assertEquals(testDatetime, result, 'Datetime string failed to match');
        System.assert(testBatch.isSuccess, 'Error was caught incorrectly');
    }
    
    @IsTest
    private static void getLatestRetentionDateTime_2Month1Day_CorrectDateTime() {
        Datetime testDatetime = Datetime.now();
        CaseRetentionBatchable testBatch = new CaseRetentionBatchable();
        Datetime result = testBatch.getLatestRetentionDateTime('form name', ' 1M1D ');
        testDatetime = testDatetime.addDays(-1);
        testDatetime = testDatetime.addMonths(-1);
        
        System.assertEquals(testDatetime, result, 'Datetime string failed to match');
        System.assert(testBatch.isSuccess, 'Error was caught incorrectly');
    }
    
    @IsTest
    private static void getLatestRetentionDateTime_1Year2Month30Minutes_CorrectDateTime() {
        Datetime testDatetime = Datetime.now();
        CaseRetentionBatchable testBatch = new CaseRetentionBatchable();
        Datetime result = testBatch.getLatestRetentionDateTime('form name', '1Y2M30m');
        testDatetime = testDatetime.addMinutes(-30);
        testDatetime = testDatetime.addMonths(-2);
        testDatetime = testDatetime.addYears(-1);
        
        System.assertEquals(testDatetime, result, 'Datetime string failed to match');
        System.assert(testBatch.isSuccess, 'Error was caught incorrectly');
    }
    
    @IsTest
    private static void getLatestRetentionDateTime_InvalidFormat_ErrorCaught() {
        Datetime testDatetime = Datetime.now();
        CaseRetentionBatchable testBatch = new CaseRetentionBatchable();
        Datetime result = testBatch.getLatestRetentionDateTime('form name', '1Y2 h #M30m');
        
        System.assertEquals(false, testBatch.isSuccess, 'Error was not caught successfully');
    }
    
    @IsTest
    private static void deleteRecords_FakeIds_Error() {
        Id fakeCaseId = Case.getSObjectType().getDescribe().getKeyPrefix() + '0'.repeat(12);
        CaseRetentionBatchable testBatch = new CaseRetentionBatchable();
        testBatch.deleteRecords(new Set<Id> { fakeCaseId }, new Set<Id> ());
        
        System.assertEquals(false, testBatch.isSuccess, 'Error was not caught successfully');
        System.assertEquals(false, String.isBlank(testBatch.logMessage), 'Log message was not set correctly');
        System.assertEquals(false, String.isBlank(testBatch.errorDescription), 'Error description was not set correctly');
    }
    
    @IsTest
    private static void deleteRecords_MockSetup_Success() {
        List<Case> testCases = [SELECT Id FROM Case WHERE Form_Name__c = 'Incentives Challenge'];
        CaseRetentionBatchable testBatch = new CaseRetentionBatchable();
        testBatch.deleteRecords(new Map<Id, Case> (testCases).keySet(), new Set<Id> ());
        
        System.assertEquals(1, [SELECT Id FROM Case].size(), 'Records were failed to be deleted');
        System.assertEquals(true, testBatch.isSuccess, 'Error was caught unexpectedly');
        System.assertEquals(false, String.isBlank(testBatch.logMessage), 'Log message was not set correctly');
        System.assertEquals(false, String.isBlank(testBatch.errorDescription), 'Error description was set incorrectly');
    }
}