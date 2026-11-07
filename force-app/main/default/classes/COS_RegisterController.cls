public without sharing class COS_RegisterController {
    
    // Form Fields
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public String password { get; set; }
    
    // UI Messages
    public String errorMessage { get; set; }
    public String successMessage { get; set; }
    
    public COS_RegisterController() {
    }
    
    // Generate random username
    private String generateUsername() {
        
        String first = firstName.trim().toLowerCase();
        String last  = lastName.trim().toLowerCase();
        
        // Randomly choose first or last name
        Integer randomChoice = Math.mod(
            Math.abs(Crypto.getRandomInteger()),
        2
            );
        
        Boolean useFirst = (randomChoice == 0);
        
        String baseName = useFirst ? first : last;
        String secondName = useFirst ? last : first;
        
        // Random prefix length
        Integer prefixLength = Math.mod(
            Math.abs(Crypto.getRandomInteger()),
        secondName.length()
            ) + 1;
        
        String suffix = secondName.substring(0, prefixLength);
        
        return baseName + suffix;
    }
    
    // generate unique username
    private String generateUniqueUsername() {
        String username;
        
        while (true) {
            username = generateUsername();
            
            Integer countUser = [
                SELECT COUNT()
                FROM COS_Registration__c
                WHERE Username__c = :username
            ];
            
            if (countUser == 0) {
                break;
            }
        }
        
        return username;
    }
    
    public PageReference register() {
        
        // Clear previous messages
        errorMessage = null;
        successMessage = null;
        
        firstName = firstName != null ? firstName.trim() : null;
        lastName  = lastName != null ? lastName.trim() : null;
        email     = email != null ? email.trim() : null;
        
        if (String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(email) || String.isBlank(password)) {
            errorMessage = 'All fields are required.';
            return null;
        }
        System.debug('Name entered = ' + firstName + ' '+ lastName);
        System.debug('Email entered = ' + email);
        
        try {
            // Check duplicate email contact
            List<COS_Registration__c> existingContact = [SELECT Id FROM COS_Registration__c WHERE Email__c = :email LIMIT 1];
            
            System.debug('Duplicate Count = ' + existingContact.size());
            
            if(!existingContact.isEmpty()){
                errorMessage = 'Email already exists';
                System.debug('Duplicate email found');
                return null;
            }
            
            // Create COS registration
            COS_Registration__c newUser = new COS_Registration__c();
            newUser.First_Name__c = firstName;
            newUser.Last_Name__c = lastName;
            newUser.Email__c = email;
            newUser.Password__c = password;
            newUser.Username__c = generateUniqueUsername();
            newUser.Registration_Date__c = Date.today();
            newUser.Status__c = 'Registered';
            
            insert newUser;
            
            // Success
            successMessage = 'Registration Successfull';
            
            //Redirect to Login Page
            PageReference page = new PageReference('/apex/COS_Login');
            page.getParameters().put('msg', 'registered');
            page.setRedirect(true);
            return page;
            
            // return null;
            
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
            return null;
        }
        
    }
}