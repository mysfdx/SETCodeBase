@isTest
private class FacilityStallCountControllerTest {
    
    @isTest
    Static Void testGetFacilityInfo(){
        Account a= TestClientUtils.createAccount();
        insert a;
        Facility__c f =TestClientUtils.createFacility(a.id);
        f.Lifts__c=10;
        f.Flats__c=10;
        f.Alignment__c=10;
        f.Detail__c=10;
        f.Car_Wash__c=10;
        f.Photobooth__c=10;
        insert f;
        FacilityStallCountController.getFacilityInfo();
            
    }

}