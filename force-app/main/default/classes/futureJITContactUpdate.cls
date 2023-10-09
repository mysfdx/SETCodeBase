/* Name:  futureJITContactUpdate
Created By:  Neha Agrawal
Created Date:  2020-05-08
Last Modified By:  Neha Agrawal
Last Modified Date: 2020-08-21
Description: 
 
ChangeLog:
Changes by Neha Agrawal on 2/7/2022 to change SAML attribute from DealerRole to currentdealerrole 
Changes by Neha Agrawal on 2/28/2022, to not update these if Dealer code, role and name are blank
Changes by Neha Agrawal on 8/1/2022, Added Primary Dealer code and Primary Dealer name to contact
*/

Public class futureJITContactUpdate {
    
    @future
    public static void ContactUpdate(Id ContactId,Map < String, String > attributes,String federationIdentifier){
        
        Contact con = [SELECT Id, Name, Current_Dealer_Code__c, Current_Dealer_Name__c, AccountId,
                       Current_SPIN__c, Username__c, Phone, Most_Recent_App_ID__c,Primary_Dealer_Code__c FROM Contact WHERE Id = :ContactId ];
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/appname')){
            con.Most_Recent_App_ID__c = attributes.get('http://schemas.jmfamily.com/set/identity/claims/appname');
        }
        else{
            con.Most_Recent_App_ID__c = 'DD';
        }
        system.debug('Within Future');
        if(String.isNotEmpty(federationIdentifier)){
            con.Username__c =attributes.get('http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn').substringBefore('@'); 
                //federationIdentifier.substringBefore('@');
            // this can be changed to UPN as ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn")
        }
        
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/email')){
            con.Email =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/email');
        }
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/currentdealercode') &&
           String.IsNotBlank(attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealercode'))){
               //String Current_Dealer_Code=attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealercode');
            con.Current_Dealer_Code__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealercode');
               
        }
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/dealer') &&
           String.IsNotBlank(attributes.get('http://schemas.jmfamily.com/set/identity/claims/dealer'))){
               String primaryCode=attributes.get('http://schemas.jmfamily.com/set/identity/claims/dealer');
             con.Primary_Dealer_Code__c=primaryCode;
               try{
            Account primaryDlrName = [SELECT Id, Name,Dealer_Code__c FROM Account WHERE Dealer_Code__c =: primaryCode LIMIT 1];
                con.Primary_Dealer_Name__c=primaryDlrName.Name;
        }
        catch(System.QueryException e)
        {
            system.debug('Exception is '+ e.getCause()+' '+e.getMessage());
        }
               
        }
        
        if(attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/currentdealername') &&
           String.IsNotBlank(attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealername'))){
            con.Current_Dealer_Name__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealername');
        }
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/currentdealerrole') &&
           String.IsNotBlank(attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealerrole'))){
            con.Current_Dealer_Role__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealerrole');
        }
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/currentdealersalesdistrict') &&
           String.IsNotBlank(attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealersalesdistrict'))){
            con.Current_Dealer_Sales_District__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/currentdealersalesdistrict');
        }
        
        if( attributes.containsKey('http://schemas.jmfamily.com/set/identity/claims/spinid')){
            con.Current_SPIN__c =  attributes.get('http://schemas.jmfamily.com/set/identity/claims/spinid');
        }
        Try{
            update con;
        }
        catch(DmlException e){
            System.debug('Contact Update ERROR: ' + e.getMessage());
        }
        
    }
    
}