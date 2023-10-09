/* Created By:  Magulan Duraipandian
Created Date:  2017-05-09
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description: packageUpdate trigger perform action whenever a Package Action record got Inserted, Updated, Deleted and Undeleted.  
*/

trigger PackageUpdateTrigger on Package_Action__c (after Insert, after Update, after undelete, after delete) {
    
    List<Id> packId = new List<Id>();
//List of Package Id when a record got Inserted, Updated and Undeleted.
    if(!Trigger.isDelete){
        for(Package_Action__c packAction: trigger.new){
            packId.add(packAction.Package__c);
        }
    }
    else{   
//List of Package Id when a record got Deleted.
        for(Package_Action__c packAction: trigger.old){
            packId.add(packAction.Package__c);
        }
    }
    if(packId.size()>0 && packId!= NULL){
//Invoking the method to update the Package Action field with New value.        
        UpdatePackage.updatePackageAction(packId);
        
    }
}