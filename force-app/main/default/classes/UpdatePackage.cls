/**
* UpdatePackage.cls
* Description  : Class to perform update operation on Package.
* @Author      : Vijay Mittal
* @version     : 1.0
* @CreatedDate : May 25, 2012
************************Version Updates***********************************************************************
Updated Date             Updated By                  Update Comments 
21st June 2022           Neha Agrawal           to populate Pacakge Action category field.
**************************************************************************************************************
*/

public class UpdatePackage{
    
    /**  
* To update the Package Action Field on Packages__c object.
*/     
    public static void updatePackageAction(List<Id> packActionId){
        
        Map<Id,List<String>> packIdActionMap = new Map<Id,List<String>>(); 
        Map<Id,String> newPackIdActionMap = new Map<Id,String>(); 
        List<Packages__c> packageList = new List<Packages__c>();
        
        //Extracting the Package Action records which got Inserted, Updated, Deleted or Undeleted.     
        List<Package_Action__c> packActionList = [SELECT Id, Action__c, Package__c FROM Package_Action__c WHERE Package__c IN: packActionId];
        
        //Creating a Map with Package Id and Package Action.
        for(Package_Action__c packAction: packActionList){
            if(packIdActionMap.containsKey(packAction.Package__c)){
                List<String> tmpList = packIdActionMap.get(packAction.Package__c);
                tmpList.add(packAction.Action__c);
                packIdActionMap.put(packAction.Package__c,tmpList);
            }
            else{
                if(packAction.Action__c != null){   
                    List<String> tmpList = new List<string>();
                    tmpList.add(packAction.Action__c);
                    packIdActionMap.put(packAction.Package__c,tmpList);
                }
            }
        }
        
        //Sorting the value of Package Actions field which is separated by a semi-colon and a space.
        for(Id packId: packIdActionMap.keySet()){
            List<String> packAction = packIdActionMap.get(packId);
            packAction.sort();
            String actionStr;
            for(String tempStr: packAction){
                if(actionStr == NULL)
                    actionStr = tempStr;
                else
                    actionStr = actionStr+'; '+tempStr;
            }
            newPackIdActionMap.put(packId, actionStr);            
        }    
        
        //Making the final list of Package(with Package Action values) to Update.
        for(Id packageId: newPackIdActionMap.keySet()){
            String pkgActionString=newPackIdActionMap.get(packageId);
            String pkgActionCategory;
            if(pkgActionString.contains('TDA Renewal')){
                pkgActionCategory='TDA Renewal';
            }
            else if(pkgActionString.contains('Major Owner Change')){
                pkgActionCategory='Major Owner Change';
            }
            else if(pkgActionString.contains('Site Request')){
                pkgActionCategory='Site Request';
            }
            else if(pkgActionString.contains('Location Amendment')){
                pkgActionCategory='Location Amendment';
            }
            else if(pkgActionString.contains('GM Change')){
                pkgActionCategory='GM Change';
            }
            else if(pkgActionString.contains('Relocation')){
                pkgActionCategory='Relocation';
            }
            else if(pkgActionString.contains('Responsible Executive')){
                pkgActionCategory='Responsible Executive';
            }
            else if(pkgActionString.contains('Nomination of Successor')){
                pkgActionCategory='Nomination of Successor';
            }
            else if(pkgActionString.contains('Minor Owner Change - New')){
                pkgActionCategory='Minor Owner Change - New';
            }
            else if(pkgActionString.contains('Minor Owner Change - Existing')){
                pkgActionCategory='Minor Owner Change - Existing';
            }
            else {
                pkgActionCategory='Multiple Actions';
            }
            packageList.add(new Packages__c(Id = packageId,Package_Action_Category__c=pkgActionCategory,
                                            Package_Actions__c = newPackIdActionMap.get(packageId)));  
        }
        
        //Check if any of the Package has no child. Package Action for such record should be blank.
        for(Id packageId: packActionId){
            if(!packIdActionMap.containsKey(packageId)){
                packageList.add(new Packages__c(Id = packageId, Package_Actions__c =''));
            }               
        }
        try{
            //Updating the Package List.
            update packageList;
        }catch(DMLException dmle){
            System.debug('Error while updating the Package. Error: '+dmle.getMessage());        
        }        
    }
}