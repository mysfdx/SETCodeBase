/* Name:  DS_SubProdSelectForDealerCtlr
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_SubProdSelectForDealerCtlr {
    public Id vendorId;
    public String acctId;
    public Id prodId;
    public String subProdName {get;set;}
    public List < DS_Subcategory__c > listSelectedSubProduct {get; set;}
	public Boolean selectedSubProdBool {get;set;}
	public Id subProdId;
	Id subProdIdFromPrev;
    Set < Id > setSubProductIds = new Set < Id >();
    public List<SubProductWrapper> LstSubProductWrapper {get; set;}
    
    public DS_SubProdSelectForDealerCtlr() {
    	lstSubProductWrapper = new List<SubProductWrapper>();
    	List<SubProductWrapper> lstSubProductWrapper2 = new List<SubProductWrapper>();
    	vendorId = ApexPages.currentPage().getParameters().get('vendorId');
    	prodId = ApexPages.currentPage().getParameters().get('prodId');
		acctId = ApexPages.currentPage().getParameters().get('acctId');
		subProdIdFromPrev = ApexPages.currentPage().getParameters().get('subProdId');

		for ( DS_Product_Subcategory__c subProd : [ SELECT Subcategory__c FROM DS_Product_Subcategory__c WHERE Product__c =: prodId ] )
			setSubProductIds.add(subProd.Subcategory__c);
		
		for ( DS_Subcategory__c subProd : [ SELECT Id, Name, DS_Status__c, Type__c FROM DS_Subcategory__c ORDER BY NAME LIMIT 1000 ] ) {
			if ( setSubProductIds.contains(subProd.Id) )
				LstSubProductWrapper.add(new SubProductWrapper(subProd, true));
			else
				LstSubProductWrapper2.add(new SubProductWrapper(subProd, false));
		}
		LstSubProductWrapper.addAll(LstSubProductWrapper2);
    }
    
    public void filterSubProds() {
    	lstSubProductWrapper = new List<SubProductWrapper>();
    	List<SubProductWrapper> lstSubProductWrapper2 = new List<SubProductWrapper>();
		for ( DS_Subcategory__c subProd : [ SELECT Id, Name, DS_Status__c, Type__c FROM DS_Subcategory__c WHERE Name Like :subProdName+'%' ORDER BY NAME LIMIT 1000 ] ) {
			if ( setSubProductIds.contains(subProd.Id) )
				LstSubProductWrapper.add(new SubProductWrapper(subProd, true));
			else
				LstSubProductWrapper2.add(new SubProductWrapper(subProd, false));
		}
		LstSubProductWrapper.addAll(LstSubProductWrapper2);
	}
	
	public void selectSubProd() {
        subProdId = System.currentPagereference().getParameters().get('subProdId');
        listSelectedSubProduct = [ SELECT Id, DS_Status__c, Name FROM DS_Subcategory__c WHERE Id =: subProdId ];
        selectedSubProdBool = true;
    }
	
    public PageReference nxt() {
    	DS_Vendor__c vendor = [ SELECT Id, Name FROM DS_Vendor__c WHERE Id =: vendorId ];
    	DS_Product__c prod = [ SELECT Id, Name FROM DS_Product__c WHERE Id =: prodId ];
    	Dealer_Product_Subproduct__c dealerProdSubProd = new Dealer_Product_Subproduct__c();
    	dealerProdSubProd.DS_Product__c = prodId;
		dealerProdSubProd.DS_Subproduct__c = subProdId;
		dealerProdSubProd.DS_Vendor__c = vendorId;
    	String nam = vendor.Name + '.' + prod.Name + '.' + listSelectedSubProduct.get(0).Name;
    	if ( String.isNotBlank(acctid) && acctid != 'null' ) {
    		dealerProdSubProd.DS_Account_Dealer__c = acctid;
    		Account acc = [ SELECT Name FROM Account WHERE Id =: acctId];
    		nam += '.' + acc.Name;
    	}
    	dealerProdSubProd.DS_Dealer_Product_Subproduct_Name__c = nam;
    	insert dealerProdSubProd;
        return cncl();
    }
    
    public PageReference cncl() {
    	if ( acctId != null && acctId != 'null' )
    		return new Pagereference('/' + acctId);
    	else
    		return new Pagereference('/' + subProdIdFromPrev);
    }
    
    public class SubProductWrapper {
        public Boolean IsRelated {get; set;}
        public DS_Subcategory__c SubProduct {get; set;}
        
        public SubProductWrapper(DS_Subcategory__c DS_SubProduct, Boolean IsRelated) {
            this.SubProduct = DS_SubProduct;
            this.IsRelated = IsRelated;
        }
    }
}