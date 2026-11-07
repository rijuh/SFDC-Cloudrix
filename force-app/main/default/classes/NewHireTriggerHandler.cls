public with sharing class NewHireTriggerHandler {

    public static void afterInsert(List<New_Hire__c> newHires) {

        if(newHires == null || newHires.isEmpty()) {
            return;
        }

        Set<Id> hireIds = new Set<Id>();

        for(New_Hire__c nh : newHires) {
            hireIds.add(nh.Id);
        }

        System.enqueueJob(new NewHireQueueable(hireIds));
    }
}