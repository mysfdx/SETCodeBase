/* Name:  CaseBatch
Created By:  Neha Agrawal
Created Date:  2020-06-24
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

global class CaseBatch implements 
    Database.Batchable<sObject>, Database.Stateful{

        global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
       // set<id> caseids=new set<id>{};
        string Condition='IsClosed=true and JMA_Business_Unit__c=\'Dealer Services\' and DS_Time_Entry_Mins__c <>null and casenumber not in (\'00020276\',\'00001958\')';
       //List<case> caseids=[Select id,DS_Total_Time_Spent_In_Hours__c,CaseNumber, LastModifiedDate from case where IsClosed=true and JMA_Business_Unit__c='Dealer Services' and DS_Time_Entity_In_Minutes__c <>null and LastModifiedBy.name<>'Neha Agrawal'];
        String Query='SELECT ID, DS_Total_Time_Spent_In_Hours__c,(Select Id,DS_Total_time_worked__c,DS_Time_Case__c from Time_Worked__r) FROM Case where  '+Condition;
        //String Query='SELECT ID, DS_Total_Time_Spent_In_Hours__c,(Select Id,DS_Total_time_worked__c,DS_Time_Case__c from Time_Worked__r) FROM Case where id in:caseids ';
        return Database.getQueryLocator(Query);
    }
        global void execute(Database.BatchableContext bc, List<Case> scope){
        // process each batch of records
        List<Case> updatedcases = new List<Case>();
            //list<DS_Time_Worked__c> timeworked=new List<DS_Time_Worked__c>();
            //timeworked=[Select Id, DS_Total_time_worked__c,DS_Time_Case__c from DS_Time_Worked__c where DS_Total_time_worked__c<>null and  DS_Time_Case__c in: scope ];
            Decimal total=0;
        for (Case cse : scope) {
            system.debug('Case id is '+ cse.Id);
            for (DS_Time_Worked__c timework : cse.Time_Worked__r) {
                if((cse.id==timework.DS_Time_Case__c)&& (timework.DS_Total_time_worked__c!=null)){
                    total=timework.DS_Total_time_worked__c.setScale(2)+total;
                }
                
                
              
                recordsProcessed = recordsProcessed + 1;
            }
            cse.DS_Total_Time_Spent_In_Hours__c =total.setScale(2,RoundingMode.FLOOR);
            total=0;
            updatedcases.add(new Case (id=cse.Id, DS_Total_Time_Spent_In_Hours__c=cse.DS_Total_Time_Spent_In_Hours__c));
        }
        update updatedcases;
    }    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Neha!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        //EmailUtils.sendMessage(job, recordsProcessed);
    }    
}