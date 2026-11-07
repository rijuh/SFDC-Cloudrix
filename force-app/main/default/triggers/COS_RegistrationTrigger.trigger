trigger COS_RegistrationTrigger on COS_Registration__c (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        COS_RegistrationTriggerHandler.createContacts(Trigger.new);
    }

}