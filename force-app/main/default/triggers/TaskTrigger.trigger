trigger TaskTrigger on Task (after insert, after update) {

    if (Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            TaskTriggerHandler.LeadScoring(Trigger.new);
        }
    }
}