@isTest
Public class Test_SetPdfReportsDisplayPdfController{
Public static testmethod void testmet()
{
    Document d= new Document();
    d.name='testname';

    d.body= blob.valueOf('text');


    d.FolderId = UserInfo.getUserId();
    insert d;
    
    ApexPages.currentPage().getParameters().put('id', d.id);
    SetPdfReportsDisplayPdfController s = new SetPdfReportsDisplayPdfController();

    s.DispalyPDFMethod();
}

}