public with sharing class TaskTriggerHandler {

    public static void LeadScoring(List<Task> tasks){
        
        Set<Id> leadIds = new Set<Id>();

        for(Task t: tasks){
            if(t.WhoId != null && t.WhoId.getSObjectType() == Lead.SObjectType){
                leadIds.add(t.WhoId);
            }
        }

        if(leadIds.isEmpty()){
            return;
        }

        List<Lead> leads = [SELECT Id, Email, Company, Lead_Score__c FROM Lead WHERE Id IN :leadIds];

        update leads;
    }
}