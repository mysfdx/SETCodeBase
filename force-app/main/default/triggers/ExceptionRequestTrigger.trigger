trigger ExceptionRequestTrigger on Exception_Request__c (after update) {
    
    if(trigger.isAfter && trigger.isUpdate){
        ExceptionRequestTriggerHandler th=New ExceptionRequestTriggerHandler();
        Map<Id, Exception_Request__c> statusChangedMap= New Map<Id, Exception_Request__c>();
        for(Exception_Request__c excep: Trigger.newMap.Values()){
            if ((excep.Status__c != trigger.oldMap.get(excep.Id).Status__c) || 
                (excep.SETF_Sub_Programs__c != trigger.oldMap.get(excep.Id).SETF_Sub_Programs__c))
            {
                statusChangedMap.put(excep.id, excep);
            }
        }
        if(statusChangedMap <> null && !statusChangedMap.isEmpty()){
            system.debug('After update is');
            th.afterUpdate(statusChangedMap);
        }
    } 
    
}