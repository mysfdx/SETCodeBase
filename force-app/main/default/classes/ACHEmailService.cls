/*
Created By: Neha Agrawal
Created Date: 19th July 2022
Description: Created to handle email responses for non Salesforce users for Accounting ACH Cases.
Changelog 

Author--             Date--                       Purpose--

*/
global class ACHEmailService implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
            Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
            system.debug('Email body is '+email.plainTextBody);
            if(email.Subject.contains('ACH Parts Program Elec. Transf. Authorization')){
                String caseNum = this.parseEmailContent(email.plainTextBody, 'Case Number: ');
                system.debug('case number is '+caseNum);
                Case caseToUpdate=[SELECT id, Status FROM Case where CaseNumber=:caseNum];
                if(email.plainTextBody.containsIgnoreCase('AP Validation Completed')){
                    caseToUpdate.Status='Closed - Approved';
                }
                if(email.plainTextBody.containsIgnoreCase('Denied')){
                    caseToUpdate.Status='Closed - Denied';
                }
                
                try{
                    update caseToUpdate;
                }
                catch(System.DmlException e){
                    System.debug('Error: not able to create a case: '+e);
                }
            }
            return result;
        }
    private String parseEmailContent(String emailText, String dataLabal){
        emailText += '\n';
        //System.debug('Email text with new line '+ emailText);
        String dataValue = '';
        Integer labalIdx = emailText.indexOf(dataLabal);
        System.debug('Datalabel is '+dataLabal);
        system.debug('labalIdx '+labalIdx);
        if(labalIdx >= 0){
            
            dataValue = emailText.substring(labalIdx + dataLabal.length(), 
                                            emailText.indexOf('\n', labalIdx + dataLabal.length()));
            system.debug('2nd index'+ emailText.indexOf('\n', labalIdx + dataLabal.length()));
            
            if(String.isNotBlank(dataValue)){
                dataValue = dataValue.trim();
            }
        }
        return dataValue;
    }
}