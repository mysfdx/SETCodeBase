@isTest
private class SET_Test_HoursofOpsTrigger {

    static testMethod void workHourTest() {
        LIST<Hours_of_Operation__c> hourofOpsList=new LIST<Hours_of_Operation__c> (); 
        Hours_of_Operation__c hrsofOps=new Hours_of_Operation__c();
        hrsofOps.Closed__c=false;
        hrsofOps.Day_of_Week__c='Monday';
        hrsofOps.Start_Time__c='12.30 AM';
        hrsofOps.End_Time__c='11.30 PM';
        hourofOpsList.add(hrsofOps);
        
        Hours_of_Operation__c hrsofOps1=new Hours_of_Operation__c();
        hrsofOps1.Closed__c=false;
        hrsofOps1.Day_of_Week__c='Monday';
        hrsofOps1.Start_Time__c='10.30 PM';
        hrsofOps1.End_Time__c='11.30 AM';
        hourofOpsList.add(hrsofOps1);
        
        database.Saveresult[] sr = database.insert(hourofOpsList,false);
        
        for (database.Saveresult srItm:sr){
        	if(!srItm.isSuccess()){
        		system.assertEquals(srItm.getErrors()[0].getMessage(), 'Start Time Should be Earlier than End Time.');
        	}
        }
        
    }
}