/* Name:  DS_DealerProductSOQLMethods
Created By:  Magulan Duraipandian
Created Date:  2017-06-08
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_DealerProductSOQLMethods {
    public static List < DS_Dealer_Product__c > fetchDealerProductsByIds(Set < Id > setDPIds) {
        return [ SELECT Dealer__c, Name, Product__c, Start_Date__c, End_Date__c, Notes__c, OEM_Cert_Brands__c, Install_Date__c, Critical__c, SLA__c, Equipment_Type__c,
                Circuit_ID__c, Circuit_Type__c, Circuit_Used_For__c, Connection_Speed__c, Content_Filter__c, Dealer_network_Default_Gateway_IP__c, 
                Dealer_network_Default_Gateway_Owner__c, DMS_Failover__c, Provider_DNS_Primary__c, Provider_DNS_Secondary__c, Provider_Gateway__c, 
                Provider_IP_End__c, Provider_IP_Start__c, Provider_Subnet_Mask__c, Remote_Management_IP__c, Remote_Management_U_P__c, Set_Gateway_IP__c,
                Config_Default_Gateway__c, Config_DNS__c, Config_Set_Gateway__c, Equipment_Model__c, Hardware_IP__c, IP__c, Login__c, Server_Name__c, Supported_By__c,
                DS_Upfront_Hardware_Charge__c, DS_Upfront_License_Charge__c, DS_Upfront_Installation_Charge__c, DS_Upfront_Total_Fee__c, DS_Monthly_Charges__c,
                Desktops_use_SET_Gateway__c, Quantity__c, Total_Monthly_Charges__c, Lic_Renewal_Charge__c, Lic_Renewal_Date__c     
                FROM DS_Dealer_Product__c WHERE Id IN: setDPIds ];
    }
    
    public static List < DS_Dealer_Product__c > fetchDealerProductsByIdsAndDealerIds(Set < Id > setDPIds, Set <Id > setDealerIds) {
        return [ SELECT Dealer__c, Name, Product__c, Start_Date__c, End_Date__c, Notes__c, OEM_Cert_Brands__c, Install_Date__c, Critical__c, SLA__c, Equipment_Type__c,
                Circuit_ID__c, Circuit_Type__c, Circuit_Used_For__c, Connection_Speed__c, Content_Filter__c, Dealer_network_Default_Gateway_IP__c, 
                Dealer_network_Default_Gateway_Owner__c, DMS_Failover__c, Provider_DNS_Primary__c, Provider_DNS_Secondary__c, Provider_Gateway__c, 
                Provider_IP_End__c, Provider_IP_Start__c, Provider_Subnet_Mask__c, Remote_Management_IP__c, Remote_Management_U_P__c, Set_Gateway_IP__c,
                Config_Default_Gateway__c, Config_DNS__c, Config_Set_Gateway__c, Equipment_Model__c, Hardware_IP__c, IP__c, Login__c, Server_Name__c,  Supported_By__c,
                DS_Upfront_Hardware_Charge__c, DS_Upfront_License_Charge__c, DS_Upfront_Installation_Charge__c, DS_Upfront_Total_Fee__c, DS_Monthly_Charges__c,
                Desktops_use_SET_Gateway__c, Quantity__c, Total_Monthly_Charges__c, Lic_Renewal_Charge__c, Lic_Renewal_Date__c  
                FROM DS_Dealer_Product__c WHERE Product__c IN: setDPIds AND Dealer__c IN: setDealerIds ];
    }
}