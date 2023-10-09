@isTest
private class DS_CreateSubCategoryCon_Test
{
    static testMethod void createSubCategoryConTest()
    {
        Account newAccount = TestClientUtils.getAccount('TestDealer');
        insert newAccount;
        
        DS_CreateSubCategoryCon objCreateSubCategoryCon = new DS_CreateSubCategoryCon();
        objCreateSubCategoryCon.createNewSubCategory();
        objCreateSubCategoryCon.Answer = 'No';
        objCreateSubCategoryCon.createNewSubCategory();    
        
        PageReference pageRef = Page.DS_CreateSubCategory;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('aid', newAccount.id);
        DS_CreateSubCategoryCon newCreateSubCategoryCon = new DS_CreateSubCategoryCon();
        newCreateSubCategoryCon.createNewSubCategory();
        newCreateSubCategoryCon.Answer = 'No';
        newCreateSubCategoryCon.createNewSubCategory();
        newCreateSubCategoryCon.getLstAnswers();
    }
}