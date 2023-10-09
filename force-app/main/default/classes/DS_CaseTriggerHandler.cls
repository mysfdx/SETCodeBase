/*******************************************************************
   Purpose: Calls required methods to process required functionalities
   Parameters: None
   Returns: void
   Throws : N/A                                                    
********************************************************************/

public Class DS_CaseTriggerHandler {
    
    public static Boolean firstRunBool = true;
    
    public static void onBeforeupdate(Map<Id,Case> oldCases, Map<Id, Case> newCases) {
        List<Case> newCaseList = new List<Case> ();
        newCaseList = newCases.values();
        Map<Id,Case> oldCaseMap = new Map<Id,Case> ();
        oldCaseMap = oldCases;
        createTimeAndCustDetail(newCaseList, oldCases);
    }
    
    public static void onAfterInsert(List<Case> newCases) {
        List<Case> newCaseList = new List<Case> ();
        newCaseList = newCases;
        notifyCustomers(newCaseList);
        //createKnowledgeArticles(newCaseList);
        
    }
    
    public static void onAfterUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        List<Case> newCaseList = new List<Case> ();
        newCaseList = newCases;
        System.debug('firstRunBool = '+firstRunBool);
        if ( firstRunBool ) {
        	 for( Case cse : newCaseList ) {
            	if ( cse.CT_Response__c == null )        	
            		notifyCustomers(newCaseList);
        	 }
            createTasksForKnowledge(newCaseList, oldMap);
            firstRunBool = false;
        }        
    }

 /*******************************************************************
       Purpose: Calls required methods to process before update functionalities
       Parameters: List of new cases
       Returns: void
       Throws : N/A                                                    
    ********************************************************************/    
    /*public static void updateCase(List<Case> newCaseList, Map < Id, Case > oldMap) {
        List < Case > listCaseForUpdat = new List < Case >();
        if ( oldMap != null ) {
            for(Case cse : newCaseList ) {
                if ( cse.JMA_Business_Unit__c != null && cse.JMA_Business_Unit__c == 'Dealer Services' ) {
                    if( cse.DS_Customer_Name__c != oldMap.get(cse.Id).DS_Subproduct__c || cse.DS_Customer_Name__c != oldMap.get(cse.Id).DS_Subproduct__c || cse.DS_Vendor_Product_cust__c != oldMap.get(cse.Id).DS_Vendor_Product_cust__c ) {
                        listCaseForUpdat.add(cse);
                    }
                }
            }
        } else {
            listCaseForUpdat.addAll(newCaseList);
        }
        
        if ( listCaseForUpdat.size() > 0 ) {
            Map<String,SET_DISTRICT_INFO__c> distmap = new Map<String,SET_DISTRICT_INFO__c>();
            for(SET_DISTRICT_INFO__c distInfo:[Select Id, ISDM_Phone__c,ISDM_User__r.Name,Name from SET_DISTRICT_INFO__c ]) { 
                distmap.put(distInfo.Name,distInfo);
            }
            Set<Id> accId = new Set<Id>();
            Set<Id> productId = new Set<Id>();
            Set<Id> subproductId = new Set<Id>();
            for(Case cse : listCaseForUpdat ){
                    if(cse.DS_Customer_Name__c != null)
                    accId.add(cse.DS_Customer_Name__c);
                    if(cse.DS_Vendor_Product_cust__c != null)
                    productId.add(cse.DS_Vendor_Product_cust__c);
                    if(cse.DS_Subproduct__c != null)
                    subproductId.add(cse.DS_Subproduct__c);
            }
            Map<Id,Account>  accmap = new Map<Id,Account>([Select Id,Name,Phone,JMA_Account_Owner_Email_Formula__c,Dealer_Number__c,Account__r.Name,District__c from Account where Id IN:accId]);
            Map<Id,DS_Product__c> ProductMap = new Map<Id,DS_Product__c>([select Id,name,Phone__c,Email__c,DS_Critical_App__c,
            DS_Business_Owner__c,DS_Internal_Support_Email__c,DS_Internal_Support_group__c from DS_Product__c where Id IN:productId]);
            Map<Id,DS_Subcategory__c> subproduct = new Map<Id,DS_Subcategory__c>([select Id,name,DS_Business_Owner__c,Email__c,DS_Critical_App__c,DS_Internal_Support_Email__c,DS_Internal_Support_group__c,Phone__c from DS_Subcategory__c where Id IN:subproductId]);                
    
            Map<Id,List<Contact>> ItconMap = new Map<Id,List<Contact>>();
            List<Contact> ItCon = New List<Contact>();
            for(Contact c:[Select Id,Name,Phone,Email,Role__c,AccountId from Contact where Role__c='IT Contact' and AccountId IN:accId order by CreatedDate Desc]){
                ItCon.add(c);
                ItconMap.put(c.AccountId,ItCon );
            }
            for(Case cse : listCaseForUpdat ) {
                    if(ItconMap.get(cse.DS_Customer_Name__c) != null) {
                        cse.DS_IT_Contact_Name__c =ItconMap.get(cse.DS_Customer_Name__c)[0].Name;
                        cse.DS_IT_Contact_Email__c = ItconMap.get(cse.DS_Customer_Name__c)[0].Email;
                        cse.DS_IT_Contact_Phone__c = ItconMap.get(cse.DS_Customer_Name__c)[0].Phone;
                    }
                    if(cse.DS_Customer_Name__c != null) {
                        cse.DS_Cust_Dealer_Name__c = accmap.get(cse.DS_Customer_Name__c).Account__r.Name;

                        if(accmap.get(cse.DS_Customer_Name__c).District__c != null && accmap.get(cse.DS_Customer_Name__c).District__c != '') {
                            cse.DS_Cust_ISDM_Name__c = distmap.get(accmap.get(cse.DS_Customer_Name__c).District__c).ISDM_User__r.Name;
                            cse.DS_Cust_ISDM_Phone__c = distmap.get(accmap.get(cse.DS_Customer_Name__c).District__c).ISDM_Phone__c;
                        } 
                    }
                    if(cse.DS_Vendor_Product_cust__c != null) {
                        cse.DS_cust_Internal_Support_group__c = ProductMap.get(cse.DS_Vendor_Product_cust__c).DS_Internal_Support_group__c;
                        cse.DS_cust_Internal_Support_Email__c =  ProductMap.get(cse.DS_Vendor_Product_cust__c).DS_Internal_Support_Email__c;
                        cse.DS_cust_Product_Phone__c =  ProductMap.get(cse.DS_Vendor_Product_cust__c).Phone__c;
                        cse.DS_cust_Business_Owner__c =  ProductMap.get(cse.DS_Vendor_Product_cust__c).DS_Business_Owner__c;
                        cse.DS_cust_Product_Email__c =  ProductMap.get(cse.DS_Vendor_Product_cust__c).Email__c;
                        cse.DS_Cust_Critical_App__c =  ProductMap.get(cse.DS_Vendor_Product_cust__c).DS_Critical_App__c;
                    }
                    if(cse.DS_Subproduct__c != null) {
                        cse.DS_Internal_Support_group_sp__c= subproduct.get(cse.DS_Subproduct__c).DS_Internal_Support_group__c;
                        cse.DS_Internal_Support_Email_sp__c = subproduct.get(cse.DS_Subproduct__c).DS_Internal_Support_Email__c;
                        cse.DS_Sub_product_Phone__c = subproduct.get(cse.DS_Subproduct__c).Phone__c;
                        cse.DS_Business_Owner_sp__c = subproduct.get(cse.DS_Subproduct__c).DS_Business_Owner__c;
                        cse.DS_Sub_Product_Email__c = subproduct.get(cse.DS_Subproduct__c).Email__c;
                        cse.DS_Critical_App_sp__c = subproduct.get(cse.DS_Subproduct__c).DS_Critical_App__c;
                    }
            }
        }
    } */
    
  /*******************************************************************
       Purpose: Calls required methods to process before updates functionalities
       Parameters: List of new cases
       Returns: void
       Throws : N/A       
       Modified by Magulan Duraipandian on 18th April 2016 to Bulkify the code                                             
    ********************************************************************/      
    
    private static void sendanEmail(List<Case> csList) {
        Set<Id> csId = new Set<Id>();
        Map < Id, Case > mapCase = new Map < Id, Case >();
        for(case c: csList) {
            csId.add(c.Id);
        }
        
        for ( Case c : [SELECT Id, CaseNumber, ClosedDate, DS_Customer_Name_cust__c, DS_Dealer_Name__c, DS_User_Assigned_To_Name__c, Owner.Name, DS_Vendor_Product_cust__r.Name, Subject, User_Assigned_To__r.Name, DS_Customer_Visible_Description__c, Description FROM Case WHERE Id IN: csId] ) {          
            mapCase.put(c.Id, c);
        }
        List<DS_Customer_Details__c> emailList = new List<DS_Customer_Details__c>();
        emailList = [Select Id,DS_Customer_Email__c,DS_Customer_Name__c, Name, DS_Dealer_Name__c from DS_Customer_Details__c where DS_Customer_Name__c IN:csId];
    	
        if(emailList.size() > 0) {
            List < Messaging.SingleEmailMessage > listMsgs = new List < Messaging.SingleEmailMessage >();
            for(DS_Customer_Details__c ds : emailList) {
            	System.debug('Customer Email Address = '+ ds.DS_Customer_Email__c);            	
                if ( String.isNotBlank(ds.DS_Customer_Email__c) ) {
                    Case cas = mapCase.get(ds.DS_Customer_Name__c);
                    String CaseIDy = Id.valueOf(cas.Id);
                    String ThreadID = '[ ref:_'
					     + UserInfo.getOrganizationId().left(5)
					     + UserInfo.getOrganizationId().mid(11,4) + '._'
					     + CaseIDy.left(5)
					     + CaseIDy.mid(10,5) + ':ref ]';
					System.debug('ThreadID = '+ThreadID);
                    List<String> emailstring = new List<String>();              
                    emailstring.add(ds.DS_Customer_Email__c);                    
                    Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                    m.setBCCAddresses(emailstring);   
                    String subjct = ' Case '+ Cas.CaseNumber + ' has been closed for '+ ds.Name +' at '+ ds.DS_Dealer_Name__c + ' by ' + Cas.DS_User_Assigned_To_Name__c +' on ' + Cas.ClosedDate;    
                    m.setSubject(subjct);                
                    String htmlBdy = ds.Name + ',<br/><br/>Your Requested IT ticket # ' + cas.CaseNumber + ' was closed on ' + cas.ClosedDate + '.<br/><br/>';
                    htmlBdy += 'You called on: ' + cas.DS_Vendor_Product_cust__r.Name + '<br/>';
                    htmlBdy += 'Ticket Description: ' + cas.Description + '<br/>';
                    htmlBdy += 'Ticket Subject: ' + cas.Subject + '<br/>';
                    htmlBdy += 'Ticket Assigned To: ' + cas.User_Assigned_To__r.Name + '<br/>';
                    htmlBdy += 'Ticket Close Description: ' + cas.DS_Customer_Visible_Description__c + '<br/>';
/*For UAT */					//htmlBdy += '<p style="font-family: Arial; font-size: 12px;"><b>How was your Experience working with '+ Cas.Owner.Name + ' from SET Dealer Services?</b></p><div style="font-family: Arial; font-size: 12px; overflow:hidden;"><table cellpadding="0" cellspacing="0" border="0" style="border-collapse: separate; border-spacing: 10px 5px; margin: 0 0; width: 320px;"><tr><td width="25%" style="vertical-align:bottom; text-align:center;"><a style="text-decoration:none;" href="https://app.customerthermometer.com/?template=log_feedback&hash=8c83a287&embed_data=dGVtcGVyYXR1cmVfaWQ9NCZ0aGVybW9tZXRlcl9pZD01MTc4OQ==&e='+ ds.DS_Customer_Email__c +'&f='+ds.Name+'&l=&c=&c1='+Cas.Id+'&c2='+ThreadID+'&c3='+cas.Owner.Name+'&c4=&c5=&c6=&c7=&c8=&c9=&c10="><img style="border: none;" src="https://app.customerthermometer.com/sites/app/images/icon_sets/emb_smiley5/Red-1.jpg" alt="Red Light" title="Red Light" class="_temp" /></a></td><td width="25%" style="vertical-align:bottom; text-align:center;"><a style="text-decoration:none;" href="https://app.customerthermometer.com/?template=log_feedback&hash=5d79e89d&embed_data=dGVtcGVyYXR1cmVfaWQ9MyZ0aGVybW9tZXRlcl9pZD01MTc4OQ==&e='+ ds.DS_Customer_Email__c +'&f='+ds.Name+'&l=&c=&c1='+Cas.Id+'&c2='+ThreadID+'&c3='+cas.Owner.Name+'&c4=&c5=&c6=&c7=&c8=&c9=&c10="><img style="border: none;" src="https://app.customerthermometer.com/sites/app/images/icon_sets/emb_smiley5/Amber-1.jpg" alt="Yellow Light" title="Yellow Light" class="_temp" /></a></td><td width="25%" style="vertical-align:bottom; text-align:center;"><a style="text-decoration:none;" href="https://app.customerthermometer.com/?template=log_feedback&hash=2084b93a&embed_data=dGVtcGVyYXR1cmVfaWQ9MiZ0aGVybW9tZXRlcl9pZD01MTc4OQ==&e='+ ds.DS_Customer_Email__c +'&f='+ds.Name+'&l=&c=&c1='+Cas.Id+'&c2='+ThreadID+'&c3='+cas.Owner.Name+'&c4=&c5=&c6=&c7=&c8=&c9=&c10="><img style="border: none;" src="https://app.customerthermometer.com/sites/app/images/icon_sets/emb_smiley5/Green-1.jpg" alt="Green Light" title="Green Light" class="_temp" /></a></td><td width="25%" style="vertical-align:bottom; text-align:center;"><a style="text-decoration:none;" href="https://app.customerthermometer.com/?template=log_feedback&hash=9559726f&embed_data=dGVtcGVyYXR1cmVfaWQ9MSZ0aGVybW9tZXRlcl9pZD01MTc4OQ==&e='+ ds.DS_Customer_Email__c +'&f='+ds.Name+'&l=&c=&c1='+Cas.Id+'&c2='+ThreadID+'&c3='+cas.Owner.Name+'&c4=&c5=&c6=&c7=&c8=&c9=&c10="><img style="border: none;" src="https://app.customerthermometer.com/sites/app/images/icon_sets/emb_smiley5/Gold-1.jpg" alt="Gold Star" title="Gold Star" class="_temp" /></a></td></tr><tr><td style="text-align:center;"><span style="color:#CC3333;">Poor</span></td><td style="text-align:center;"><span style="color:#FFB40D;">Average</span></td><td style="text-align:center;"><span style="color:#66CC33;">Good</span></td><td style="text-align:center;"><span style="color:#B17657;">Excellent</span></td></tr></table></div><p style="font-family: Arial; font-size: 12px;">Your feedback is valuable and will only take 5 seconds.<br />Click or tap the rating which best represents your experience.</p><a href="http://www.customerthermometer.com/intrigued" target="_blank"><img style="border: none;" border="0" src="https://app.customerthermometer.com/images/powered_by_ct.png" alt="Powered by Customer Thermometer" /></a>';
/*For Prod*/        htmlBdy += '<p style="font-family: Arial; font-size: 12px;"><b>How was your Experience working with '+ Cas.Owner.Name + ' from SET Dealer Services?</b></p><div style="font-family: Arial; font-size: 12px; overflow:hidden;"><table cellpadding="0" cellspacing="0" border="0" style="border-collapse: separate; border-spacing: 10px 5px; margin: 0 0; width: 320px;"><tr><td width="25%" style="vertical-align:bottom; text-align:center;"><a style="text-decoration:none;" href="https://app.customerthermometer.com/?template=log_feedback&hash=d2d116c2&embed_data=dGVtcGVyYXR1cmVfaWQ9NCZ0aGVybW9tZXRlcl9pZD01Nzg4MQ==&e='+ ds.DS_Customer_Email__c +'&f='+ds.Name+'&l=&c=&c1='+Cas.Id+'&c2='+ThreadID+'&c3='+cas.Owner.Name+'&c4=&c5=&c6=&c7=&c8=&c9=&c10="><img style="border: none;" src="https://app.customerthermometer.com/sites/app/images/icon_sets/emb_smiley5/Red-1.jpg" alt="Red Light" title="Red Light" class="_temp" /></a></td><td width="25%" style="vertical-align:bottom; text-align:center;"><a style="text-decoration:none;" href="https://app.customerthermometer.com/?template=log_feedback&hash=f2aac402&embed_data=dGVtcGVyYXR1cmVfaWQ9MyZ0aGVybW9tZXRlcl9pZD01Nzg4MQ==&e='+ ds.DS_Customer_Email__c +'&f='+ds.Name+'&l=&c=&c1='+Cas.Id+'&c2='+ThreadID+'&c3='+cas.Owner.Name+'&c4=&c5=&c6=&c7=&c8=&c9=&c10="><img style="border: none;" src="https://app.customerthermometer.com/sites/app/images/icon_sets/emb_smiley5/Amber-1.jpg" alt="Yellow Light" title="Yellow Light" class="_temp" /></a></td><td width="25%" style="vertical-align:bottom; text-align:center;"><a style="text-decoration:none;" href="https://app.customerthermometer.com/?template=log_feedback&hash=f86ffbbb&embed_data=dGVtcGVyYXR1cmVfaWQ9MiZ0aGVybW9tZXRlcl9pZD01Nzg4MQ==&e='+ ds.DS_Customer_Email__c +'&f='+ds.Name+'&l=&c=&c1='+Cas.Id+'&c2='+ThreadID+'&c3='+cas.Owner.Name+'&c4=&c5=&c6=&c7=&c8=&c9=&c10="><img style="border: none;" src="https://app.customerthermometer.com/sites/app/images/icon_sets/emb_smiley5/Green-1.jpg" alt="Green Light" title="Green Light" class="_temp" /></a></td><td width="25%" style="vertical-align:bottom; text-align:center;"><a style="text-decoration:none;" href="https://app.customerthermometer.com/?template=log_feedback&hash=1166937d&embed_data=dGVtcGVyYXR1cmVfaWQ9MSZ0aGVybW9tZXRlcl9pZD01Nzg4MQ==&e='+ ds.DS_Customer_Email__c +'&f='+ds.Name+'&l=&c=&c1='+Cas.Id+'&c2='+ThreadID+'&c3='+cas.Owner.Name+'&c4=&c5=&c6=&c7=&c8=&c9=&c10="><img style="border: none;" src="https://app.customerthermometer.com/sites/app/images/icon_sets/emb_smiley5/Gold-1.jpg" alt="Gold Star" title="Gold Star" class="_temp" /></a></td></tr><tr><td style="text-align:center;"><span style="color:#CC3333;">Poor</span></td><td style="text-align:center;"><span style="color:#FFB40D;">Average</span></td><td style="text-align:center;"><span style="color:#66CC33;">Good</span></td><td style="text-align:center;"><span style="color:#B17657;">Excellent</span></td></tr></table></div><p style="font-family: Arial; font-size: 12px;">Your feedback is valuable and will only take 5 seconds.<br />Click or tap the rating which best represents your experience.</p><a href="http://www.customerthermometer.com/intrigued" target="_blank"><img style="border: none;" border="0" src="https://app.customerthermometer.com/images/powered_by_ct.png" alt="Powered by Customer Thermometer" /></a>';
                    
                    m.setHTMLBody(htmlBdy);
                    System.debug('Email Body = '+ m);
                    listMsgs.add(m);
                }
            }
            if ( listMsgs.size() > 0 ) {
                Messaging.sendEmail(listMsgs);
                System.debug('Email Sent ');
            }
        }
    }         
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 4/12/2016
    Purpose      : To avoid Visualforce page for Dealer Service
    */
    
    public static void createTimeAndCustDetail(List < Case > newCases, Map < Id, Case > oldCases) {
       List < DS_Time_Worked__c > listTimeWorked = new List < DS_Time_Worked__c >();
        Decimal TotalTime = 0;
        Set<Id> CaseIds = new Set<Id>();
        for ( Case cas : newCases ) {
            if ( cas.JMA_Business_Unit__c != null && cas.JMA_Business_Unit__c == 'Dealer Services' && cas.RecordTypeId == oldCases.get(cas.Id).RecordTypeId ) {
                CaseIds.add(cas.id);
                DS_Time_Worked__c tc = new DS_Time_Worked__c();
                Decimal timeinMinutes;
                if( String.isBlank(cas.DS_Time_Entry_Mins__c) ) {       
                    cas.DS_Time_Entry_Mins__c.addError('Please enter Time Entry(Mins)');
                } 
                if( String.isNotBlank(cas.DS_Time_Entry_Mins__c) )
                {
                    system.debug('Time entry in min'+cas.DS_Time_Entry_Mins__c);
                cas.DS_Time_Spent_In_Minutes__c = Decimal.ValueOf(cas.DS_Time_Entry_Mins__c);
                }
                if(cas.DS_Time__c != null) {
                    System.debug('Time entry Hours is not blank.'+ cas.DS_Time__c);
                    TotalTime = TotalTime + Decimal.valueOf(cas.DS_Time__c);
                    timeinMinutes = Decimal.valueOf(cas.DS_Time__c)*60;
                }                   
                        
                if(cas.DS_Time_Spent_In_Minutes__c != 0 && cas.DS_Time_Spent_In_Minutes__c != null && String.isNotBlank(cas.DS_Time_Entry_Mins__c) ) {              
                    Decimal timeSpent = cas.DS_Time_Spent_In_Minutes__c;
                
                    if( TotalTime != 0 && TotalTime != null ) {
                        cas.DS_Total_Time_Spent_In_Hours__c = TotalTime + (timeSpent / 60);
                    }
                    else
                    cas.DS_Total_Time_Spent_In_Hours__c = timeSpent/60 ;
                
                    if(timeinMinutes != 0 && timeinMinutes != null)
                    tc.Name = timeinMinutes + timeSpent +' Minutes';
                    else
                    tc.Name = timeSpent + ' Minutes';            
                    cas.DS_Time_Spent_In_Minutes__c = 0;
                    cas.DS_Time__c = '';
                    cas.DS_Time_Entry_Mins__c = '5';
                }
                tc.DS_Time_Case__c = cas.Id;
                tc.DS_Total_time_worked__c = cas.DS_Total_Time_Spent_In_Hours__c.setScale(2);  
                //tc.DS_Total_time_worked__c=tc.DS_Total_time_worked__c.setScale(2,RoundingMode.FLOOR);
                listTimeWorked.add(tc);
               // cas.DS_Total_Time_Spent_In_Hours__c=0;
            }
        }
        if ( listTimeWorked.size() > 0 ) 
            insert listTimeWorked; 
        // changes made by Neha Agrawal on 13th aug 2020 for displaying total spent hours on cases
       
        for(AggregateResult aRes : [SELECT DS_Time_Case__c, SUM(DS_Total_time_worked__c) Total FROM DS_Time_Worked__c WHERE DS_Time_Case__c IN :CaseIds GROUP BY DS_Time_Case__c]) {
        //accList.add(new Account(Id = (Id)aRes.get('AccountId'), Total__c = (Decimal)aRes.get('Total')));
            for(Case c: newCases){
                Decimal totaltime1=0;
                if(c.Id==((id)aRes.get('DS_Time_Case__c'))){
                    totaltime1=(Decimal)aRes.get('Total');
                    c.DS_Total_Time_Spent_In_Hours__c=totaltime1.setscale(2, RoundingMode.FLOOR);
                }
                System.debug('Total time is '+''+ c.DS_Total_Time_Spent_In_Hours__c);
            }
    }
   }      
    /*
    Created By   : Magulan Duraipandian
    Created Date : 4/28/2016
    Purpose      : To notify Customers after closing the case
    */
    
    public static void notifyCustomers( List < Case > newCaseList) {
        List<Case> closeList = new List<Case>();
        for( Case cse : newCaseList ) {
            if ( cse.JMA_Business_Unit__c != null && cse.JMA_Business_Unit__c == 'Dealer Services' ) {
                if ( cse.Status == 'Closed' )
                closeList.add(cse);
            }
        }
        if(closeList.size() > 0)
        sendanEmail(closeList);
    }
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 4/28/2016
    Purpose      : To create tasks to notify users for knowledge article creation
    Modified By  : Shailesh Bhirud
    Modified Date: 2/12/2018
    Purpose      : Modified the code to incorporate data type for the field DS_Knowledge__c from checkbox/boolean to Picklist with values "Yes/No"
    */
    
    public static void createTasksForKnowledge( List < Case > newCaseList, Map<Id, Case> oldMap) {
        List < Task > listTasksToInsert = new List < Task >();
        
        for( Case cse : newCaseList ) {
            if ( cse.JMA_Business_Unit__c != null && cse.JMA_Business_Unit__c == 'Dealer Services' && cse.Status == 'Closed' && cse.DS_Knowledge__c == 'Yes'  && cse.DS_Knowledge__c != oldMap.get(cse.Id).DS_Knowledge__c ) {
                String strDesc = 'You identified a missing knowledge item as part of the case closed data collected on a previous case. ';
                strDesc += 'You can review the case you identified this to here ' + cse.CaseNumber + '. Please create simple easy to follow instructions with lots of screen shots if possible. '; 
                strDesc += 'These will be used for both internal and customer facing knowledge in the future. Thank you for all you do.';
                listTasksToInsert.add(new Task(WhatId = cse.Id, Subject = cse.Subject, Description = strDesc, RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('JMSC').getRecordTypeId()));
            }
        }          
        
        if ( listTasksToInsert.size() > 0 )
            insert listTasksToInsert;      
    }
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 9/20/2016
    Purpose      : To attach related knowledge articles to case
    */
    /*
    public static void createKnowledgeArticles( List < Case > newCaseList) {
        List < CaseArticle > listCaseArticlesToInsert = new List < CaseArticle >();
        List < Knowledge__kav > listKnowledge = new List < Knowledge__kav >();
        Set < Id > setProdIds = new Set < Id >();
        Set < Id > setSubProdIds = new Set < Id >();
        Set < String > setSubjects = new Set < String >();
        Map < String, Id > mapCaseSubjectCaseId = new Map < String, Id >();
        Map < Id, Id > mapSubProdCaseId = new Map < Id, Id >();
        Map < Id, Id > mapProdIdCaseId = new Map < Id, Id >();
        
        for( Case cse : newCaseList ) {
            if ( String.isNotBlank(cse.DS_Vendor_Product_cust__c) ) {
                setProdIds.add(cse.DS_Vendor_Product_cust__c);
                mapProdIdCaseId.put(cse.DS_Vendor_Product_cust__c, cse.Id);
            }
            if ( String.isNotBlank(cse.DS_Subproduct__c) ) {
                setSubProdIds.add(cse.DS_Subproduct__c);
                mapSubProdCaseId.put(cse.DS_Subproduct__c, cse.Id);
            }            
            if ( String.isNotBlank(cse.Subject) ) {
                setSubjects.add('%' + cse.Subject + '%');
                mapCaseSubjectCaseId.put(cse.Subject, cse.Id);
            }            
        } 
        
        for ( Knowledge__kav k : [ SELECT KnowledgeArticleId, Title, DS_Product__c, DS_Subproduct__c FROM Knowledge__kav WHERE language = 'en_US' AND PublishStatus = 'Online' AND KnowledgeArticleId != null 
            AND ( DS_Product__c IN: setProdIds OR DS_Subproduct__c IN: setSubProdIds OR DS_Problem_Statement__c LIKE : setSubjects ) LIMIT 5] ) {
            if ( mapProdIdCaseId.containsKey(k.DS_Product__c) ) {
                CaseArticle CA = new CaseArticle();
                CA.CaseId = mapProdIdCaseId.get(k.DS_Product__c); 
                CA.KnowledgeArticleId = k.KnowledgeArticleId;
                listCaseArticlesToInsert.add(CA);
            }
            if ( mapSubProdCaseId.containsKey(k.DS_Subproduct__c) ) {
                CaseArticle CA = new CaseArticle();
                CA.CaseId = mapSubProdCaseId.get(k.DS_Subproduct__c);
                CA.KnowledgeArticleId = k.KnowledgeArticleId;
                listCaseArticlesToInsert.add(CA);
            }
            if ( mapCaseSubjectCaseId.containsKey(k.Title) ) {
                CaseArticle CA = new CaseArticle();
                CA.CaseId = mapCaseSubjectCaseId.get(k.Title);
                CA.KnowledgeArticleId = k.KnowledgeArticleId;
                listCaseArticlesToInsert.add(CA);
            }
        }
        
        if ( listCaseArticlesToInsert.size() > 0 )
            insert listCaseArticlesToInsert;      
    }*/
    
}