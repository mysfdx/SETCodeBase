/* Name:  SET_WorkingHoursController
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public without sharing class SET_WorkingHoursController {

 private final Account ActhrsOfOps;
 public Hours_of_Operation__c newHrsOfOps {get;set;}
 
 public SET_WorkingHoursController(ApexPages.StandardController stdController){
    
    this.ActhrsOfOps=(Account)stdController.getRecord();
    newHrsOfOps=new Hours_of_Operation__c();
    
 }
 
 
 public list<SelectOption> departmentList{get {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '--None--'));
    Schema.DescribeFieldResult fieldResult = Hours_of_Operation__c.Department__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry f : ple)
    {
        options.add(new SelectOption(f.getLabel(), f.getValue()));
    }       
   return options;
 }
 set;}
 
 public string hourOpId{get;set;}
 
 public boolean dispMsg{get {
    if (dispMsg==null){
        return false;
    }
    else {
        return dispMsg;
    }
 }
 set;}
 
 public void CloseMsg() {
    dispMsg=false;
    
 }
  
   
 public string selectedDepartment{get{
     if(selectedDepartment==null){
         return 'Sales';
         }
     else {
         return selectedDepartment;
         }    
     
     }
 set;}
 
 public list<Hours_of_Operation__c> hoursOpsList{get {
    list<Hours_of_Operation__c> listHoursforDealer=new list<Hours_of_Operation__c>();
    system.debug(selectedDepartment);
    if(selectedDepartment!=null){
        listHoursforDealer=[Select ID,Closed__c,Day_of_Week__c,Start_Time__c,End_Time__c from Hours_of_Operation__c where Dealer__c=:ActhrsOfOps.Id and Department__c=:selectedDepartment order by Day_Sequence__c ];
            
    }
    return listHoursforDealer;
    
 }
 set;}
    
public boolean bDispHours{get{
    if(bDispHours==null){
        return true;
    }
    else {
        return bDispHours;
    }
}
set;}

public boolean bEnterHours{get{
    if(bEnterHours==null){
        return false;
    }
    else {
        return bEnterHours;
    }
}
set;}

public void displayWorkHours(){
    bDispHours=true;
}


public void newHours(){
    bDispHours=false;
    bEnterHours=true;
    newHrsOfOps=new Hours_of_Operation__c();
    if(selectedDepartment!=null){
        newHrsOfOps.Department__c=selectedDepartment;
    }
}


public void updateRecord(){
    bDispHours=false;
    bEnterHours=true;
    if(hourOpId!=null){
        newHrsOfOps=[Select ID,Department__c,Day_of_Week__c,Closed__c,Start_Time__c,End_Time__c,Dealer__c from Hours_of_Operation__c where id=:hourOpId ];
            
    }
}

public void saveNew() {
    
    system.debug('newHrsOfOps.startTime:'+newHrsOfOps.Start_Time__c);
    system.debug('newHrsOfOps.EndTime:'+newHrsOfOps.End_Time__c);
    errorMessage='No Error';
    newHrsOfOps.Dealer__c=ActhrsOfOps.Id;
    if (newHrsOfOps.id==null){
        
        LIST<Hours_of_Operation__c> existHoursofOps=[Select ID from Hours_of_Operation__c where Dealer__c=:newHrsOfOps.Dealer__c and Department__c=:newHrsOfOps.Department__c and Day_of_Week__c=:newHrsOfOps.Day_of_Week__c ];
        if(existHoursofOps.size()==0){
            LIST<Hours_of_Operation__c> hourofOpsList=new LIST<Hours_of_Operation__c>();
            hourofOpsList.add(newHrsOfOps);
            database.Saveresult[] sr=database.insert(hourofOpsList,false);
            for (database.Saveresult srItm:sr){
                if(!srItm.isSuccess()){
                    system.debug('string.valueof(srItm.getErrors()[0]):'+string.valueof(srItm.getErrors()[0].getMessage()));
                    //ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,string.valueof(srItm.getErrors()[0].getMessage()));
                    //ApexPages.addMessage(errMsg);
                    errorMessage=string.valueof(srItm.getErrors()[0].getMessage());
                    dispMsg=true;
                    
                }
            }
        }
        else {
            //ApexPages.Message ExsterrMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Record Already Exists for this Dealer,Department and day of week');
            //ApexPages.addMessage(ExsterrMsg);
            errorMessage='Record Already Exists for this Dealer,Department and Day of Week';
            dispMsg=true;
        }
    }
    else {
        LIST<Hours_of_Operation__c> hourofOpsList=new LIST<Hours_of_Operation__c>();
        hourofOpsList.add(newHrsOfOps);
        LIST<Hours_of_Operation__c> existHoursofOpsRec=new  LIST<Hours_of_Operation__c>();
        existHoursofOpsRec=[Select ID from Hours_of_Operation__c where Dealer__c=:newHrsOfOps.Dealer__c and Department__c=:newHrsOfOps.Department__c and Day_of_Week__c=:newHrsOfOps.Day_of_Week__c and id!=:newHrsOfOps.Id ];
        if(existHoursofOpsRec.size()==0 ){
        
        database.Saveresult[] sr=database.update(hourofOpsList,false);
        for (database.Saveresult srItm:sr){
            if(!srItm.isSuccess()){
                system.debug('string.valueof(srItm.getErrors()[0]):'+string.valueof(srItm.getErrors()[0].getMessage()));
                //ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,string.valueof(srItm.getErrors()[0].getMessage()));
                //ApexPages.addMessage(errMsg);
                errorMessage=string.valueof(srItm.getErrors()[0].getMessage());
                dispMsg=true;
               
                
            }
            
        }
        
      }
      else {
         errorMessage='Record Already Exists for this Dealer,Department and Day of Week';
         
         dispMsg=true;
      }
        
    }
    bEnterHours=false;
    bDispHours=true;    
}

public void doCancel() {
    bDispHours=true;
    bEnterHours=false;
    errorMessage='No Error';
    }
    

public string errorMessage{get {
	if (errorMessage==null){
		return 'No Error';
	}
	else {
		return errorMessage;
	}
	}
	set;}    



public void doDelete() {
    system.debug('hourOpId:'+hourOpId);
    Hours_of_Operation__c delRec=[Select ID,Name from Hours_of_Operation__c where id=:hourOpId];
    delete delRec;
    
    }
}