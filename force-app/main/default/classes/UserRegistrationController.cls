public with sharing class UserRegistrationController {
    
    @AuraEnabled
    public static String registerUser(
        String firstName,
    String lastName,
    String role
    ) {
        
        String username = generateUsername(firstName, lastName);
        
        // CHECK USERNAME EXISTS OR NOT
        while (isUsernameExists(username)) {
            username = generateUsername(firstName, lastName);
        }
        
        User_Registration__c userRec = new User_Registration__c();
        
        userRec.Name__c = firstName + ' ' + lastName;
        userRec.First_Name__c = firstName;
        userRec.Last_Name__c = lastName;
        userRec.Role__c = role;
        userRec.Username__c = username;
        userRec.Email__c = username + '@cloudrix.com';
        userRec.Status__c = 'Registered';
        
        insert userRec;
        
        return username;
    }
    
    // GENERATE UNIQUE USERNAME USING FIRST + LAST NAME (NO NUMBER)
    public static String generateUsername(
        String firstName,
    String lastName
    ) {
        
        String fName = firstName == null
            ? ''
            : firstName.trim()
            .replaceAll('\\s+', '')
            .toLowerCase();
        
        String lName = lastName == null
            ? ''
            : lastName.trim()
            .replaceAll('\\s+', '')
            .toLowerCase();
        
        // fallback values
        if (String.isBlank(fName)) {
            fName = 'user';
        }
        
        if (String.isBlank(lName)) {
            lName = 'reg';
        }
        
        Integer choice = getRandomNumber(2);
        
        String username = '';
        
        if (choice == 0) {
            
            // Full first name + random starting letters of last name
            Integer len =
                getRandomNumber(lName.length()) + 1;
            
            username =
                fName +
                lName.left(len);
            
        } else {
            
            // Full last name + random starting letters of first name
            Integer len =
                getRandomNumber(fName.length()) + 1;
            
            username =
                lName +
                fName.left(len);
        }
        
        return username;
    }
    
    // SAFE RANDOM NUMBER
    public static Integer getRandomNumber(
        Integer maxVal
    ) {
        
        Integer num =
            Crypto.getRandomInteger();
        
        if (num < 0) {
            num = num * -1;
        }
        
        return Math.mod(num, maxVal);
    }
    
    // CHECK USERNAME EXISTS OR NOT
    public static Boolean isUsernameExists(
        String username
    ) {
        
        Integer countUser = [
            SELECT COUNT()
            FROM User_Registration__c
            WHERE Username__c = :username
        ];
        
        return countUser > 0;
    }
}