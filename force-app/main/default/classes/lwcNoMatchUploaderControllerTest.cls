@isTest
public class lwcNoMatchUploaderControllerTest {
    
    
    @testSetup
    static void createTestData(){
        Account a = new Account(Name='Acme', Dealer_Code__c='12345');
        insert a;
    }
    
    static testMethod void method1() {
        
        
        String str = JSON.serialize('REC,MODEL,SERIAL,CC,VDS,NAME,REGMO/Y,ACTIVITY DATE,RETAIL DATE,TYPE SALE,DEALER SELLING,SET DEALER,SERIES NAME'+
                                    '\nR,1853,12345678901234567,1,1234a,test,3/5/2022,3/5/2022,3/5/2022,1,500-01007,12345,Test');        
        lwcNoMatchUploaderController.saveFile(str);
        
    }
    
    static testMethod void method2() {
        
        
        String str = JSON.serialize('REC,MODEL,SERIAL,CC,VDS,NAME,REGMO/Y,ACTIVITY DATE,RETAIL DATE,TYPE SALE,DEALER SELLING,SET DEALER,SERIES NAME'+
                                    '\nR,1853,12345678901234567,1,1234a,"test",3/5/2022,3/5/2022,3/5/2022,1,500-01007,12345,Test');
        lwcNoMatchUploaderController.saveFile(str);
        
    }
}