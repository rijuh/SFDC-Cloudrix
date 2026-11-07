trigger NewHireTrigger on New_Hire__c (after insert) {
    NewHireTriggerHandler.afterInsert(Trigger.new);
}