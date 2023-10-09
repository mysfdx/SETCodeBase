/**
 * Created by Sean Wallace, Salesforce Developer, 
 * Ad Victoriam Solutions on 9/13/19.
 */

@IsTest
private class setd_CaseProductLookupTest {
    @TestSetup
    static void testSetup() {
        DS_Product__c parentProduct = new DS_Product__c(
                Name = 'Dealer Daily'
        );
        insert  parentProduct;

        DS_Product__c[] products = new DS_Product__c[]{};
        DS_Product__c retired = new DS_Product__c(
                Name = 'Retired Product',
                Status__c = 'Retired',
                Parent_Product__c = parentProduct.Id
        );
        products.add(retired);
        DS_Product__c noStatus = new DS_Product__c(
                Name = 'Default Product',
                Parent_Product__c = parentProduct.Id,
                Legacy_ID__c = '128'
        );
        products.add(noStatus);
        DS_Product__c dd = new DS_Product__c(
                Name = 'Default Product',
                Parent_Product__c = parentProduct.Id,
                Legacy_ID__c = 'DD'
        );
        products.add(dd);
        insert products;
        list<Knowledge__kav> kavList=new list<Knowledge__kav>();
        Knowledge__kav kav = new Knowledge__kav(
                Title = 'Test Article',
                DS_Product__c = noStatus.Id,
                Summary = 'Testing a KAV',
                UrlName = 'this-is-a-test3',
                IsVisibleInCsp=true
        );
        kavList.add(kav);
        Knowledge__kav kav1 = new Knowledge__kav(
                Title = 'Test Article2',
                DS_Product__c = noStatus.Id,
                Summary = 'Testing a KAV',
                UrlName = 'this-is-a-test4',
                IsVisibleInCsp=true
        );
        kavList.add(kav1);
        insert kavList;
        List<Knowledge__kav> kavpub = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id in:kavList ];
        //System.debug(JSON.serialize(kavpub));
        for(Knowledge__kav art:kavpub){
            KbManagement.PublishingService.publishArticle(art.KnowledgeArticleId, true);
        }
   
    }

    @IsTest
    static void testProductOptions() {
        DS_Product__c parentProduct = [SELECT Id from DS_Product__c WHERE Name = 'Dealer Daily' LIMIT 1];
        DS_Product__c[] products = setd_CaseProductLookup.getProductOptions(parentProduct.Id);
        System.assert(products.size() == 3);
    }

    @IsTest
    static void testKAV() {
        DS_Product__c parentProduct = [SELECT Id from DS_Product__c WHERE Name = 'Default Product' LIMIT 1];
        Knowledge__kav[] articles = setd_CaseProductLookup.getRelatedArticles(parentProduct.Id);
        System.assert(articles.size() == 2);
        //System.assert(articles[0].UrlName == 'this-is-a-test');
    }

    @IsTest
    static void testAppId(){
        DS_Product__c appIdProduct = setd_CaseProductLookup.updateUserCurrentAppId('DD');
        DS_Product__c dd = [SELECT Id FROM DS_Product__c WHERE Legacy_ID__c = 'DD'];
        System.assertEquals(appIdProduct.id, dd.Id);
    }

    @IsTest
    static void testAppIdBad(){
        DS_Product__c appIdProduct = setd_CaseProductLookup.updateUserCurrentAppId('bad app id');
        DS_Product__c dd = [SELECT Id FROM DS_Product__c WHERE Legacy_ID__c = 'DD'];
        //System.assertEquals(appIdProduct, dd.Id);
    }
}