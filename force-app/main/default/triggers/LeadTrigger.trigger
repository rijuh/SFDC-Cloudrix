trigger LeadTrigger on Lead (before insert, before update, after insert) {
    if (Trigger.isAfter){
        if (Trigger.isInsert) {
            LeadTriggerHandler.afterInsert(Trigger.new);
        }
    }

    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            LeadTriggerHandler.validateLeadFields(Trigger.new);
            LeadTriggerHandler.calculateLeadScoring(Trigger.new);
        }
    }
}