@isTest
global class Test_SetPdfReportsController {
    global static testMethod void testPdfReportsController () {
        String acctDealershipRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealership').getRecordTypeId();
        list<Recordtype> RecordTypelist=new list<Recordtype>();
        RecordTypelist=[select id,Name from recordtype where sobjecttype='acount'];        
        list<string>rectypelist=new list<string>();
        list<Account> accountlst=new list<account>();
        for(integer i=1;i<=10;i++) {
            accountlst.add(new account(name='test'+1,District__c=string.valueof(i),Dealer_Code__c='te'+I, Active_Dealer__c = TRUE, RecordTypeId = acctDealershipRecTypId));
        }
        insert accountlst;
        SetPdfReportsController  classobj1=new  SetPdfReportsController();
        List<SelectOption>temp1= classobj1.getDistrictLevelList();
        classobj1.SelectedDistrictLevel='Non';
        
        List<SelectOption>lsttemp2= classobj1.getDistrictReportList();
        classobj1.SelectedDistrictLevel ='None';
        List<SelectOption>lsttemp3= classobj1.getDealerList();
        classobj1.retrieveDistrict();
        classobj1.SelectedDistrictLevel='D01';
        
        lsttemp2= classobj1.getDistrictReportList();
        // classobj1. SelectedDistrictLevel ='D01';
        lsttemp3= classobj1.getDealerList();
        
        classobj1.SelectedDealer='None';
        classobj1.retrieveDealer();
        List<SelectOption>lsttemp4= classobj1.getDealerReportList();
        classobj1.SelectedDealer='test1';
        lsttemp4= classobj1.getDealerReportList();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMockforPDF.CalloutMockforPDFError());
        classobj1.retrieveDistrict();
        classobj1.retrieveDealer();
        classobj1.SelectedDealer='True';
        
        Test.setMock(HttpCalloutMock.class, new CalloutMockforPDF());
        classobj1.SelectedDealerReport='test.pdf';
        classobj1.retrieveDealer();
        Test.stopTest();
        string s1='test1';    
    }
    
}