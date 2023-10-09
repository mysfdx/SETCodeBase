@isTest
private class fwReportTemplateControllerTest {
    
    private static TestMethod void fwRecordsTest() {
        fwReportTemplateController fw=new fwReportTemplateController();
        fw.accountId=TestClientUtils.createAccounts(1, true).get(0).Id;
        fw.recordTypeName='SET_Aged_Claims';
        TestClientUtils.createFWReport(fw.accountId, fw.recordTypeName);
        fw.getfwRecords();
    }

}