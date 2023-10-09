/* Name:  DS_CreateSubCategoryCon
Created By:  Ankit Nigam
Created Date:  2017-05-03
Last Modified By:  Joshua Hunt
Last Modified Date: 2021-02-01
Description:   
*/

public with sharing class DS_CreateSubCategoryCon
{
    public PageReference createNewSubCategory()
    {
        Pagereference page;
        if(Answer == 'No')
        {
            if(String.isNotBlank(accId))
                page = new Pagereference('/apex/DS_CreateDealerProduct?pId=' +productId+ '&vid=' +vendorId+'&id='+accId);
            else
                page = new Pagereference('/apex/DS_CreateDealerProduct?pId=' +productId+ '&vid=' +vendorId);
        }
        else
        {
            if(String.isNotBlank(accId))
                page = new Pagereference('/apex/DS_AllSubCategory?pId=' +productId+ '&vid=' +vendorId+'&aid='+accId);
            else
                page = new Pagereference('/apex/DS_AllSubCategory?pId=' +productId+ '&vid=' +vendorId);
        }
        system.debug('Answer ==='+Answer);
        return page;
    }

    public String Answer {get; set;}
    String productId, vendorId, accId;
    
    public DS_CreateSubCategoryCon()
    {
        productId = ApexPages.currentPage().getParameters().get('pId');
        vendorId = ApexPages.currentPage().getParameters().get('vId');
        accId = ApexPages.currentPage().getParameters().get('aid');
    }
    
    public List<SelectOption> getLstAnswers()
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }
}