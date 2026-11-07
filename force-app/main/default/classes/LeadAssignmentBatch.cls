public with sharing class LeadAssignmentBatch implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id, Assigned_To__c, Assignment_Status__c
            FROM Lead
            WHERE Assigned_To__c = NULL OR Assignment_Status__c = false
        ]);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Contact> leadOwners = [
            SELECT Id
            FROM Contact
            WHERE Contact_Type__c = 'Lead Owner'
            ORDER BY CreatedDate ASC, Id ASC
        ];

        List<Id> leadOwnersContactId = new List<Id>();

        if (leadOwners.isEmpty()) {
            leadOwnersContactId.add('003dM00002R6bdr');
        } else {
            for (Contact con : leadOwners) {
                leadOwnersContactId.add(con.Id);
            }
        }

        Integer countLeadOwners = leadOwnersContactId.size();
        Integer i = 0;
        List<Lead> leadsToUpdate = new List<Lead>();

        for (SObject record : scope) {
            Lead l = (Lead) record;
            l.Assigned_To__c = leadOwnersContactId[i];
            if(l.Assigned_To__c != '003dM00002R6bdr'){
                l.Assignment_Status__c = true;
            }
            leadsToUpdate.add(l);
            i++;
            if(i >= countLeadOwners){
                i = 0;
            }
        }

        update leadsToUpdate;
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Hourly Lead assignment batch completed.');
    }
}