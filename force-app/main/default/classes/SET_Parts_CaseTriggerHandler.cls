/*******************************************************************
   Purpose: Calls required methods to process required functionalities
   Parameters: None
   Returns: void
   Throws : N/A     
   Modified By  : Chandra Marthala
   Modified Date : 05/05/2018
   Purpose      : Removed reference of Sub Product 
********************************************************************/

public Class SET_Parts_CaseTriggerHandler {
    
    public static Boolean firstRunBool = true;
    

    public static void onAfterUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        List<Case> newCaseList = new List<Case> ();
        newCaseList = newCases;
        if ( firstRunBool ) {
            createTasksForKnowledge(newCaseList, oldMap);
            firstRunBool = false;
        }        
    }

 
    
    /*
    Purpose      : To create tasks to notify users for knowledge article creation
    */
    
    public static void createTasksForKnowledge( List < Case > newCaseList, Map<Id, Case> oldMap) {
      
               List < Task > listTasksToInsert = new List < Task >();
        
        for( Case cse : newCaseList ) {
            if ( cse.DS_Support_Team__c == 'SET Parts Support' && cse.Status == 'Closed' && cse.DS_Knowledge__c == 'Yes'  && cse.DS_Knowledge__c != oldMap.get(cse.Id).DS_Knowledge__c ) {
                String strDesc = 'You identified a missing knowledge item as part of the case closed data collected on a previous case. ';
                strDesc += 'You can review the case you identified this to here ' + cse.CaseNumber + '. Please create simple easy to follow instructions with lots of screen shots if possible. '; 
                strDesc += 'These will be used for both internal and customer facing knowledge in the future. Thank you for all you do.';
                listTasksToInsert.add(new Task(WhatId = cse.Id, Subject = cse.Subject, Description = strDesc, RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('JMSC').getRecordTypeId()));
            }
             for ( Case c : [SELECT Id, CaseNumber, ClosedDate, DS_Vendor_Product_cust__r.Name, Subject, User_Assigned_To__r.Name, DS_Customer_Visible_Description__c, Description FROM Case WHERE Id =: cse.Id] ) {          
                  }

        }          
        
        if ( listTasksToInsert.size() > 0 )
            insert listTasksToInsert;      
    }
   }