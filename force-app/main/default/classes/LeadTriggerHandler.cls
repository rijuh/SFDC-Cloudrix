public with sharing class LeadTriggerHandler {
    public static void afterInsert(List<Lead> newLeads){
        for (Lead l : newLeads){
            Map<String,String> values = new Map<String,String>();
            String Name = l.Firstname + ' ' + l.LastName;
            values.put('LeadNumber', l.LeadNumber__c);
            values.put('Name', Name);
            values.put('Email', l.Email);
            values.put('Company', l.Company);
            values.put('Status', l.Status);
            NotificationServices.createNotification(
                'Lead_Created',
            values,
            l.Id
                );
        }
    }
    
    // NEED TO IMPLEMENT DUPLICATE CHECK
    public static void validateLeadFields(List<Lead> leads){
        for(Lead l: leads){
            if(String.isNotBlank(l.Email)){
                l.Email = l.Email.trim().toLowerCase();
            }
        }
    }
    
    public static void calculateLeadScoring(List<Lead> leads){

        // TO CHECK IF ANY TASK EXISTS OR NOT
        Set<Id> leadIds = new Set<Id>();

        for(Lead l: leads){
            leadIds.add(l.Id);
        }

        Set<Id> leadsWithTaks = new Set<Id>();

        if(!leadIds.isEmpty()){
            for(AggregateResult ar: [
                SELECT WhoId FROM TASK
                WHERE WhoId IN :leadIds
                GROUP BY WhoId
            ])

            leadsWithTaks.add((Id) ar.get('WhoId'));
        }

        for(Lead l: leads){
            Integer score = 0;
            Integer flag = 0;
            
            // CONDITION TO SCORE
            if(String.isNotBlank(l.Email)){
                score += 15;
            }
            if(String.isNotBlank(l.Company)){
                score += 15;
            }

            // TASK ADDED
            if(leadsWithTaks.contains(l.Id)){
                score += 30;
            }
            
            if (l.Lead_Score__c != score){
                l.Last_Scored_Date__c = Datetime.now();
            }
            // SCORE ASSIGN
            l.Lead_Score__c = score;
            
            // SCORE RATING AND STATUS
            if(score > 90){
                l.Lead_Rating__c = 'Very Hot';
            } else if (score > 60){
                l.Lead_Rating__c = 'Hot';
            } else if (score > 30){
                l.Lead_Rating__c = 'Warm';
            } else {
                l.Lead_Rating__c = 'Cold';
            }
        }
    }
}