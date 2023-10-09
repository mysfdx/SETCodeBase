/* Name:  DS_RecentCases
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

Public Class DS_RecentCases{
Public DS_RecentCases(){}
Public List<Case> ProductCaseList {get;set;}
Public List<Case> CustomerCaseList {get;set;}
Public List<DS_Link__c> links {get;set;}
Public List<Case> subprodlist {get;set;}
Public List<Case> subprodCustomerList {get;set;}
Public List<DS_Link__c> splinks {get;set;}
Public void productCseDetails(){
ProductCaseList = new List<Case>();
string cseId= ApexPages.currentPage().getParameters().get('id');
date d = system.today().addDays(-30);
if(cseId != null && cseId != '')
ProductCaseList =[Select CaseNumber,CreatedDate,Subject,DS_Customer_Name__c,User_Assigned_To__c from Case where DS_Vendor_Product_cust__c =:cseId  and CreatedDate >= :d order by CreatedDate Desc];

}
Public void CustomerDetails(){
CustomerCaseList = new List<Case>();
String cseId= ApexPages.currentPage().getParameters().get('id');
date d = system.today().addDays(-30);
if(cseId != null && cseId != '')
CustomerCaseList =[Select CaseNumber,CreatedDate,Subject,DS_Vendor_Product_cust__c,status from Case where DS_Customer_Name__c =:cseId and CreatedDate >= :d order by CreatedDate Desc];
}
Public void ProductLinks(){
links = new List<DS_Link__c>();
String cseId= ApexPages.currentPage().getParameters().get('id');
if(cseId != null && cseId != '')
links =[Select Name,Data_URL__c,User_ID__c,Password__c from DS_Link__c where Product__c =:cseId];

}
Public void subProduct(){
subprodlist= new List<Case>();
String cseId= ApexPages.currentPage().getParameters().get('id');
date d = system.today().addDays(-30);
if(cseId != null && cseId != '')
subprodlist=[Select CaseNumber,CreatedDate,Subject,DS_Customer_Name__c,User_Assigned_To__c from Case where  DS_Subproduct__c =:cseId and CreatedDate >= :d order by CreatedDate Desc];
}
Public void subProdCustDetails(){
subprodCustomerList= new List<Case>();
String cseId= ApexPages.currentPage().getParameters().get('id');
if(cseId != null && cseId != '')
subprodCustomerList=[Select Id,CaseNumber,Subject,Owner.Name,DS_Customer_Name__c from Case where DS_Customer_Name__c =:cseId];
}

Public void SubProductLinks(){
splinks = new List<DS_Link__c>();
String cseId= ApexPages.currentPage().getParameters().get('id');
if(cseId != null && cseId != '')
links =[Select Name,Data_URL__c,User_ID__c,Password__c from DS_Link__c where DS_Subproduct__c =:cseId];
}

}