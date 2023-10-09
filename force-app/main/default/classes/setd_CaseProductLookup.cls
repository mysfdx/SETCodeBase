/**
* Created by Sean Wallace, Salesforce Developer, 
* Ad Victoriam Solutions on 9/11/19.

Change Log

Author--           Date--                Purpose
Neha Agrawal--      6/07/2021--       To get top 10 rated knowledge Articles in Salesforce Community.
*/

public without sharing class setd_CaseProductLookup {
    
    @AuraEnabled
    public static DS_Product__c[] getProductOptions(String parentProduct){
        return [
            SELECT Id, Name, Legacy_ID__c
            FROM DS_Product__c
            WHERE Status__c != 'Retired'
            AND Community_Product__c = TRUE
            ORDER BY Name
        ];
    }
    
    @AuraEnabled
    public static Knowledge__kav[] getRelatedArticles(String productId){
        list<Knowledge__Kav> relevantArticles= new list<Knowledge__Kav>();
        Map<string,Knowledge__Kav> pulledArticles= new Map<string,Knowledge__Kav>();
        for(Knowledge__kav k:[SELECT Id, DS_Product__c, DS_Product__r.Name,KnowledgeArticleId,
                              Title, Summary, FirstPublishedDate, UrlName,ArticleNumber
                              FROM Knowledge__kav
                              WHERE DS_Product__c = :productId
                              AND PublishStatus = 'Online'
                              AND isLatestVersion = true and IsVisibleInCsp=true]){
                                  pulledArticles.put(k.ArticleNumber,k);               
                                  
                              }
        system.debug('Pulled articles '+pulledArticles.keyset());
        id articleids;
        for(Knowledge__kav kav:pulledArticles.values()){
            articleids=kav.KnowledgeArticleId;
            break;
        }
        if(!pulledArticles.isEmpty()){
            Map<string,scoreWrapper> articeToScore=new Map<string,scoreWrapper>();
            if(!test.isRunningTest()){
            list<Knowledge__VoteStat> votStat=[Select id, ParentId, NormalizedScore, parent.ArticleNumber,
                                               Channel from Knowledge__VoteStat where
                                               parent.ArticleNumber in:pulledArticles.keyset() order by parent.ArticleNumber];
            system.debug('votStat  '+votStat.size());
            Decimal finalScore;
            for(Knowledge__VoteStat vot:votStat){
                if(!articeToScore.containskey(vot.parent.ArticleNumber)){
                    articeToScore.put(vot.parent.ArticleNumber,new scoreWrapper(vot.parent.ArticleNumber,0.0));
                }
                finalScore=articeToScore.get(vot.parent.ArticleNumber).score+
                    vot.NormalizedScore.setscale(2, RoundingMode.FLOOR);
                articeToScore.get(vot.parent.ArticleNumber).score=finalScore;
                
            }
            system.debug('articeToScore '+ articeToScore);
            }
            else{
                decimal d=0.0;
                for(string name: pulledArticles.keyset()){
                    d=d+1.0;
                    articeToScore.put(name,new scoreWrapper(name,d));
                }
                
            }
            
            list<scoreWrapper> wrapList = new list<scoreWrapper>(); 
            for(scoreWrapper sc:articeToScore.values()){
                wrapList.add(sc);
            }
            decimal sc;
            string an;
            for (integer i = 0; i <wrapList.size(); ++i) 
            {
                for (integer j = i + 1; j < wrapList.size(); ++j) 
                {
                    if (wrapList[i].score < wrapList[j].score) 
                    {
                        sc = wrapList[i].score;
                        an= wrapList[i].articleNumber;
                        wrapList[i].score = wrapList[j].score;
                        wrapList[i].articleNumber=wrapList[j].articleNumber;
                        wrapList[j].score = sc;
                        wrapList[j].articleNumber=an;
                    }
                }
            }
            
            if(wrapList.size()>0){
                integer i=0;
                for(scoreWrapper w:wrapList){
                    i=i+1;
                    relevantArticles.add(pulledArticles.get(w.articleNumber));
                    if(i==10)
                        break;
                }
            }
            
        }
        
        
        return relevantArticles; 
    }
    
     @AuraEnabled
    public static DS_Product__c updateUserCurrentAppId(String appId){
        System.debug('appId: '  + appId);
        DS_Product__c[] defaultProduct = [ SELECT Id,Name FROM DS_Product__c WHERE Legacy_ID__c = 'DD'];
        DS_Product__c[] selectedProduct = new DS_Product__c[]{};
        User u = [ SELECT Id, Name, ContactId, Most_Recent_App_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
        Contact con = u.ContactId != null ? [ SELECT Id, Name, Most_Recent_App_ID__c FROM Contact WHERE Id = :u.ContactId ] : null;
        System.debug(JSON.serialize(con));
        selectedProduct = [SELECT Id,name FROM DS_Product__c WHERE Legacy_ID__c = :appId];
        if(u.Most_Recent_App_ID__c != appId){
            u.Most_Recent_App_ID__c = appId;
            
            try{
                update u;
            }catch (DmlException e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        if(con != null && con.Most_Recent_App_ID__c != appId){
            try{
                con.Most_Recent_App_ID__c = appId;
                update con;
            }catch (DmlException e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        if(selectedProduct.size() == 0){
            return defaultProduct[0];
        }
        return selectedProduct[0];
    }
    
    public class scoreWrapper{
        public decimal score;
        public string articleNumber;
        public scoreWrapper(string articleNumber,decimal score){
            this.articleNumber=articleNumber;
            this.score=score;
        }
        
    }
}