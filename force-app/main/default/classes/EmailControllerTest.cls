/*Name:EmailControllerTest
Purpose: Test Class for EmailController
Author:Neha Agrawal
Date:08/02/2021

Change Log
Date - Changed by - Change Description
10/25/2021 - Neha Agrawal - To cover the additional methods of EmailController
*/
@isTest 
public class EmailControllerTest {
    
    @isTest static void testIncentiveApproveNoteWithFinanceEdit(){
         //record 1
        List<EmailController.EmailWrapper> inputparams1 = new List<EmailController.EmailWrapper>();
       
        EmailController.EmailWrapper ew1=new EmailController.EmailWrapper();
        ew1.strEmailTemplate='Test Template';
        ew1.strRecordId='5007j000008mmKG';
        ew1.strToEmail='Test@mail.com';
        ew1.strCCEmail='Test@mail.com';
        ew1.strContactId='0037j00000WwVxe';
        ew1.strFinancialStatementEdit='<p><img src="https://set--setdev--c.documentforce.com/servlet/'+
            'rtaImage?eid=5007e00000EIbX8&amp;feoid=00N7e000002Sjov&amp;refid=0EM7e0000009HM0"></img></p>';
        inputparams1.add(ew1); 
        
        Test.startTest();
        EmailController.incentiveApproveNote(inputparams1);
        Test.stopTest();
        
    }
     @isTest static void testIncentiveApproveNote(){
   
        //record 2
         List<EmailController.EmailWrapper> inputparams2 = new List<EmailController.EmailWrapper>();
        EmailController.EmailWrapper ew2=new EmailController.EmailWrapper();
        ew2.strEmailTemplate='Test Template';
        ew2.strRecordId='5007j000008mmKG';
        ew2.strToEmail='Test@mail.com';
        ew2.strCCEmail='Test@mail.com';
        ew2.strContactId='0037j00000WwVxe';
        inputparams2.add(ew2); 
        Test.startTest();
        EmailController.incentiveApproveNote(inputparams2);
        Test.stopTest();
    }
    
}