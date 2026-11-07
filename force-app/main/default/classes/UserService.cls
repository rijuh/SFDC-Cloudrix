public with sharing class UserService {
    
    // GENERIC USER CREATION
    public static List<Database.SaveResult> createUsers( List<User> usersToInsert ) {
        
        if(usersToInsert == null || usersToInsert.isEmpty()) {
            return new List<Database.SaveResult>();
        }
        
        return Database.insert(usersToInsert, false);
    }
    
    // CREATE USERS FROM NEW HIRE RECORDS
    public static List<Database.SaveResult> createUsersFromNewHires( List<New_Hire__c> hires ) {
        
        List<User> usersToInsert = new List<User>();
        
        if(hires == null || hires.isEmpty()) {
            return new List<Database.SaveResult>();
        }
        
        // GET ALL PROFILES
        Set<String> profileNames = new Set<String>();
        for(New_Hire__c nh : hires) {
            if(!String.isBlank(nh.Profile__c)) {
                profileNames.add(nh.Profile__c);
            }
        }
        Map<String, Id> profileMap = new Map<String, Id>();
        if(!profileNames.isEmpty()) {
            
            for(Profile p : [
                SELECT Id, Name
                FROM Profile
                WHERE Name IN :profileNames
            ]) {
                profileMap.put(p.Name, p.Id);
            }
        }
        
        // GET ALL ROLES
        Set<String> roleNames = new Set<String>();
        for(New_Hire__c nh : hires) {
            if(!String.isBlank(nh.Role__c)) {
                roleNames.add(nh.Role__c);
            }
        }
        Map<String, Id> roleMap = new Map<String, Id>();
        if(!roleNames.isEmpty()) {
            
            for(UserRole ur : [
                SELECT Id, Name
                FROM UserRole
                WHERE Name IN :roleNames
            ]) {
                roleMap.put(ur.Name, ur.Id);
            }
        }
        
        for(New_Hire__c nh : hires) {
            
            if(String.isBlank(nh.Profile__c)) {
                continue;
            }
            
            if(!profileMap.containsKey(nh.Profile__c)) {
                continue;
            }
            
            User u = new User();
            
            u.FirstName = nh.First_Name__c;
            u.LastName = nh.Last_Name__c;
            u.Email = nh.Email__c;
            u.Username = nh.Email__c;
            u.TimeZoneSidKey = 'Asia/Kolkata';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            u.ProfileId = profileMap.get(nh.Profile__c);
            u.UserRoleId = roleMap.get(nh.Role__c);
            String aliasVal = nh.Username__c;
            if(aliasVal.length() > 8){
                aliasVal = aliasVal.substring(0,8);
            }
            u.Alias = aliasVal;
            
            usersToInsert.add(u);
        }
        
        return createUsers(usersToInsert);
    }
}