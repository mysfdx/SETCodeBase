/* Name:  DS_CaseCommentTriggerHandler
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_CaseCommentTriggerHandler {
    public static void onAfterInsert(List < CaseComment > listCaseComments) {
    	createTimeDetailForNewCaseComm(listCaseComments);
    }
    
    public static void createTimeDetailForNewCaseComm(List < CaseComment > listCaseComments) {
    	Set < Id > caseCommIds = new Set < Id >();
        List < DS_Time_Worked__c > listTimeWorked = new List < DS_Time_Worked__c >();
        Decimal TotalTime = 0;
    	
    	for ( CaseComment cas : listCaseComments ) {
    		caseCommIds.add(cas.Id);
    	}
    	
    	listCaseComments = [ SELECT Id, Parent.JMA_Business_Unit__c FROM CaseComment WHERE Id IN: caseCommIds ];
    	
        for ( CaseComment cas : listCaseComments ) {
        	if ( cas.Parent.JMA_Business_Unit__c != null && cas.Parent.JMA_Business_Unit__c == 'Dealer Services' ) {        		
		    	DS_Time_Worked__c tc = new DS_Time_Worked__c();
	            Decimal timeEntry = 5;            
	                    
	            if( timeEntry != 0 ) {              
	                Decimal timeSpent = timeEntry;
	                tc.Name = timeSpent + ' Minutes';      
	            }
	            tc.DS_Time_Case__c = cas.ParentId;
	            tc.DS_Total_time_worked__c = 0.08;
	            listTimeWorked.add(tc);       
        	}
        }
        if ( listTimeWorked.size() > 0 ) 
            insert listTimeWorked;
    }
}