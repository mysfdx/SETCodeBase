/*******************************************************************************************************************
Created On: 08/15/2014
Author: Jay B
Purpose: This class is a library of codes, those are reused acrosss different modules within JMFE.

***********************************************************************************************************************/

public class COE_CodeLibrary {
    public static MAP<string,string> getsObjectNameFieldValue(LIST<ID> objIDs){
        /**************************************************************************************************************
        This method accepts a list of SFDC IDs and based on those IDs, it identifies the object. Then it 
        queries the name field for corresponding objects and returns a map comprising the record's ID and Name field value.
        
        **************************************************************************************************************/        
        
        MAP<string,LIST<string>> mpObjIds=new MAP<string,LIST<string>> ();
        for (string recID:objIDs){
        //******Determining the Object************************************************
        if(recID!=null){
        Schema.SObjectType sObjTp=COE_CodeLibrary.getSobjectTypeByPrefix(recID.substring(0,3));
        
        //*************Building a map of object name and list of IDs those belong to that object.
       
            if (mpObjIds.containsKey(sObjTp.getDescribe().getName())){
                LIST<string> lstIdValues=mpObjIds.get(sObjTp.getDescribe().getName());
                lstIdValues.add(recID);
                mpObjIds.put(sObjTp.getDescribe().getName(),lstIdValues);
            
            }
            else {
                LIST<string> lstIdValues= new LIST<string>();
                lstIdValues.add(recID);
                mpObjIds.put(sObjTp.getDescribe().getName(),lstIdValues);    
            }
        
        }        
        }
        
        
        MAP<string,string> mprecName=new MAP<string,string>();
        for (string sObjQry:mpObjIds.keySet()){
            //**********Each iteration of this for loop, queries different object.
            string qryclause='(';
            for (string strIds:mpObjIds.get(sObjQry)){
                qryclause+='\''+strIds +'\',';
            }
            qryclause=qryclause.substring(0,qryclause.length()-1) + ')';
            
            string qryStr = 'SELECT ID, ';
            if ( sObjQry == 'Case' )
                qryStr += 'CaseNumber ';
            else
                qryStr += 'Name ';
            qryStr += 'FROM ' + sObjQry + ' WHERE Id IN '+ qryclause;
            LIST<Sobject> sObjres=Database.query(qryStr);
                        
            for (Sobject ojdata:sObjres) {       
                if ( sObjQry == 'Case' )     
                    mprecName.put((string)ojdata.get('id'),(string)ojdata.get('CaseNumber'));
                else
                    mprecName.put((string)ojdata.get('id'),(string)ojdata.get('name'));
            }
            
        }
        
        return mprecName;
    
    }
    
    public static Schema.SObjectType getSobjectTypeByPrefix( String SObjectPrefix ) {
        for( Schema.SObjectType ot : Schema.getGlobalDescribe().values() ){
            String keyPrefix = (String)ot.getDescribe().getKeyPrefix();
            if( keyPrefix != null && keyPrefix.equals( SObjectPrefix ) ){
                return ot;
            }
        }
        return null;
    }
        
    /*public void createCustomAudit(string objName,string FSName,map<ID,sObject> newMap, MAP<ID,sObject> oldMap,string objectTracker)  {
    
   LIST<sObject> objList=new LIST<sObject>();
   COE_CodeLibrary utility=new COE_CodeLibrary();
   
   LIST<Schema.FieldSetMember> fldSetMembers=utility.readFieldSet(FSName, objName);
    
   for (sObject sObjRec:newMap.values()) {
   
       for (Schema.FieldSetMember field:fldSetMembers) {
           system.debug('field.getType():'+field.getType());
           string newfieldVal;
           string oldfieldVal;
           
           if((field.getType() != Schema.DisplayType.Boolean) && (field.getType() != Schema.DisplayType.DateTime) && (field.getType() != Schema.DisplayType.Date) && (field.getType() != Schema.DisplayType.Integer) && (field.getType() != Schema.DisplayType.Double) && (field.getType() != Schema.DisplayType.Currency)){
           newfieldVal=(string)sObjRec.get(field.getFieldPath());
           oldfieldVal=(string)oldMap.get(sObjRec.ID).get(field.getFieldPath());
           }
           
           else {
           newfieldVal=string.valueof(sObjRec.get(field.getFieldPath()));
           oldfieldVal=string.valueof(oldMap.get(sObjRec.ID).get(field.getFieldPath()));
           }
           system.debug('newfieldVal:'+newfieldVal);
           
           if(newfieldVal !=oldfieldVal) {           
              system.debug('objectTracker:'+objectTracker);              
              sObject objData = Schema.getGlobalDescribe().get(objectTracker).newSObject() ; 
              objData.put('parent_Field__c',sObjRec.ID); 
              objData.put('Field_Name__c',field.getLabel());
              objData.put('Old_Value__c',oldfieldVal );
              objData.put('New_Value__c',newfieldVal);
              objList.add(objData);
           }              
       }   
   }
   
       if(objList.size()>0) {
           system.debug('objList:'+objList);
           insert objList;
       
       }
      
    }
    
    public  List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    
        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));
    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    
        //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        //system.debug('fieldSetMemberList ====>' + fieldSetMemberList);  
        return fieldSetObj.getFields(); 
    } */
    
    /*
    Created By   : Magulan Duraipandian
    Created Date : 4/12/2016
    Purpose      : To get object name from the id
    
    Note         : Please pass a valid id
    */   
    
    public static String getObjectName(Id objId) {
        return objId.getSObjectType().getDescribe().getName();
    }
}