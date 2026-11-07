public with sharing class NewHireQueueable implements Queueable {

    private Set<Id> hireIds;

    public NewHireQueueable(Set<Id> hireIds) {
        this.hireIds = hireIds;
    }

    public void execute(QueueableContext qc) {

        List<New_Hire__c> hires = [
            SELECT Id,
                   First_Name__c,
                   Last_Name__c,
                   Email__c,
                   Username__c,
                   Profile__c,
                   Role__c,
                   Status__c
            FROM New_Hire__c
            WHERE Id IN :hireIds
        ];

        List<Database.SaveResult> results =
            UserService.createUsersFromNewHires(hires);

        List<New_Hire__c> updates = new List<New_Hire__c>();

        for(Integer i = 0; i < hires.size(); i++) {

            if(results[i].isSuccess()) {

                updates.add(new New_Hire__c(
                    Id = hires[i].Id,
                    Status__c = 'Created'
                ));

            } else {

                updates.add(new New_Hire__c(
                    Id = hires[i].Id,
                    Status__c = 'Failed'
                ));
            }
        }

        if(!updates.isEmpty()) {
            update updates;
        }
    }
}