trigger ContactTrigger on Contact (after insert, after update) {

    if(Trigger.isInsert && Trigger.isAfter){

        // CREATE USER ON CONTACT CREATION
        ContactTriggerHandler.createUserOnContact(Trigger.new);
    }
}
