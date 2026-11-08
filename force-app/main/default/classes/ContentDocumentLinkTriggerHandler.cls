public with sharing class ContentDocumentLinkTriggerHandler {
    
    public static void updateArticle(List<ContentDocumentLink> newLinks) {

        Set<Id> articleIds = new Set<Id>();

        for (ContentDocumentLink link: newLinks){
            if(link.LinkedEntityId != null && link.LinkedEntityId.getSObjectType() == Article__c.SObjectType){
                articleIds.add(link.LinkedEntityId);
            }
        }

        if(articleIds.isEmpty()){
            return;
        }

        Map<Id, Id> articleFieldMap = new Map<Id, Id>();
        List<ContentDocumentLink> links = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in :articleIds ORDER BY SystemModstamp DESC];

        for(ContentDocumentLink link: links){
            if(!articleFieldMap.containsKey(link.LinkedEntityId)){
                articleFieldMap.put(link.LinkedEntityId, link.ContentDocumentId);
            }
        }

        List<Article__c> articlesToUpdate = new List<Article__c>();
        for (Id articleId : articleFieldMap.keySet()) {
            Article__c newArticle = new Article__c(Id = articleId, Primary_Attachment__c = String.valueof(articleFieldMap.get(articleid)));
            articlesToUpdate.add(newArticle);
        }

        if(!articlesToUpdate.isEmpty()){
            update articlesToUpdate;
        }
    }

}