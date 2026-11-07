public with sharing class NewHireModuleController {
    
    public List<Workday__c> workdayRecords { get; private set; }
    public Workday__c selectedWorkday { get; private set; }
    
    public Boolean isDetailView { get; private set; }
    public Boolean isHiredList { get; private set; }
    
    public List<SelectOption> usernameOptions { get; private set; }
    public String selectedUsername { get; set; }
    
    
    // CONSTRUCTOR
    public NewHireModuleController() {
        workdayRecords = new List<Workday__c>();
        usernameOptions = new List<SelectOption>();
        
        String recordId = ApexPages.currentPage()
            .getParameters()
            .get('id');
        
        String listView = ApexPages.currentPage()
            .getParameters()
            .get('list');
        
        isDetailView = String.isNotBlank(recordId);
        isHiredList = listView == 'hired';
        
        if (isDetailView) {
            List<Workday__c> records = [
                SELECT Id, Name, Employee_Number__c, Employee_Status__c,
                       First_Name__c, Middle_Name__c, Last_Name__c,
                       Phone__c, Job_Title__c, Birthdate__c,
                       Street__c, City__c, State__c,
                       Postal_Code__c, Country__c,
                       Start_Date__c, Term_Date__c
                FROM Workday__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            
            if (!records.isEmpty()) {
                selectedWorkday = records[0];
                generateUsernameOptions();
            }
        } else {
            loadWorkdayRecords();
        }
    }
    
    
    // LOAD HIRING OR HIRED LIST
    private void loadWorkdayRecords() {
        if (isHiredList) {
            workdayRecords = [
                SELECT Id, Name
                FROM Workday__c
                WHERE Employee_Status__c = 'Hired'
                ORDER BY Name
                LIMIT 200
            ];
        } else {
            workdayRecords = [
                SELECT Id, Name
                FROM Workday__c
                WHERE Employee_Status__c = 'Not Hired'
                   OR Employee_Status__c = null
                ORDER BY Name
                LIMIT 200
            ];
        }
    }
    
    
    // GENERATE ONE USERNAME FROM FIRST AND LAST NAME
    private String generateUsername() {
        if (selectedWorkday == null ||
            String.isBlank(selectedWorkday.First_Name__c) ||
        String.isBlank(selectedWorkday.Last_Name__c)) {
            return null;
        }
        
        String firstName = selectedWorkday.First_Name__c
            .trim()
            .toLowerCase()
            .replaceAll('[^a-z]', '');
        
        String lastName = selectedWorkday.Last_Name__c
            .trim()
            .toLowerCase()
            .replaceAll('[^a-z]', '');
        
        if (String.isBlank(firstName) || String.isBlank(lastName)) {
            return null;
        }
        
        // Randomly choose which name to shorten.
        Boolean reduceFirstName = randomIndex(2) == 0;
        
        String nameToReduce = reduceFirstName
            ? firstName
            : lastName;
        
        String fullName = reduceFirstName
            ? lastName
            : firstName;
        
        // Choose a prefix length from 1 through the selected name's length.
        Integer reducedNameLength =
            randomIndex(nameToReduce.length()) + 1;
        
        String reducedNamePart = nameToReduce.substring(
            0,
        reducedNameLength
            );
        
        // Randomly choose the order of the name parts.
        Boolean reducedNameFirst = randomIndex(2) == 0;
        
        String username = reducedNameFirst
            ? reducedNamePart + fullName
            : fullName + reducedNamePart;
        
        return username;
    }
    
    
    // RETURN RANDOM INTEGER FROM 0 TO upperBound - 1
    private Integer randomIndex(Integer upperBound) {
        if (upperBound == null || upperBound <= 0) {
            return 0;
        }
        
        return (Integer)(Math.random() * upperBound);
    }
    
    
    // GENERATE AND ADD UP TO FIVE UNIQUE USERNAME OPTIONS
    private void generateUsernameOptions() {
        usernameOptions = new List<SelectOption>();
        selectedUsername = null;
        
        if (selectedWorkday == null ||
            String.isBlank(selectedWorkday.First_Name__c) ||
        String.isBlank(selectedWorkday.Last_Name__c)) {
            return;
        }
        
        Set<String> candidateUsernames = new Set<String>();
        Integer attempts = 0;
        Integer maxAttempts = 200;
        
        // Generate a pool of candidate usernames.
        while (candidateUsernames.size() < 100 &&
        attempts < maxAttempts) {
            attempts++;
            
            String username = generateUsername();
            
            if (String.isNotBlank(username)) {
                candidateUsernames.add(username.trim().toLowerCase());
            }
        }
        
        if (candidateUsernames.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
            'Unable to generate username suggestions. Please check the employee names.'
                ));
            return;
        }
        
        // Build the email addresses that would be assigned to Contacts.
        Set<String> candidateEmails = new Set<String>();
        
        for (String username : candidateUsernames) {
            candidateEmails.add(username + '@cloudrix.com');
        }
        
        // Query matching Contact emails in one operation.
        Set<String> existingEmails = new Set<String>();
        
        for (Contact con : [
            SELECT Email
            FROM Contact
            WHERE Email IN :candidateEmails
        ]) {
            if (String.isNotBlank(con.Email)) {
                existingEmails.add(con.Email.trim().toLowerCase());
            }
        }
        
        // Add only candidates that are not already used or repeated.
        Set<String> addedUsernames = new Set<String>();
        
        for (String username : candidateUsernames) {
            if (isUniqueUsername(
                username,
            existingEmails,
            addedUsernames
            )) {
                addedUsernames.add(username);
                
                usernameOptions.add(
                    new SelectOption(username, username)
                    );
                
                if (usernameOptions.size() == 5) {
                    break;
                }
            }
        }
        
        if (!usernameOptions.isEmpty()) {
            selectedUsername = usernameOptions[0].getValue();
        } else {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
            'Unable to generate unique username suggestions. Please try again.'
                ));
        }
    }
    
    
    // CHECK WHETHER A USERNAME IS UNIQUE
    private Boolean isUniqueUsername(
        String username,
    Set<String> existingEmails,
    Set<String> addedUsernames
    ) {
        if (String.isBlank(username)) {
            return false;
        }
        
        String normalizedUsername = username.trim().toLowerCase();
        String contactEmail = normalizedUsername + '@cloudrix.com';
        
        // Check whether this suggestion has already been added.
        if (addedUsernames.contains(normalizedUsername)) {
            return false;
        }
        
        // Check whether a Contact already uses the email.
        if (existingEmails.contains(contactEmail)) {
            return false;
        }
        
        return true;
    }
    
    
    // HIRE EMPLOYEE: CREATE CONTACT AND UPDATE WORKDAY STATUS
    public PageReference hire() {
        if (selectedWorkday == null) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
            'No employee record is selected.'
                ));
            return null;
        }
        
        if (selectedWorkday.Employee_Status__c == 'Hired') {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
            'This employee has already been hired.'
                ));
            return null;
        }
        
        if (String.isBlank(selectedWorkday.Last_Name__c)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
            'The employee must have a last name before creating a Contact.'
                ));
            return null;
        }
        
        if (String.isBlank(selectedUsername)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
            'Please select a username before hiring the employee.'
                ));
            return null;
        }
        
        String normalizedUsername = selectedUsername.trim().toLowerCase();
        String contactEmail = normalizedUsername + '@cloudrix.com';
        
        // Check availability again before inserting the Contact.
        List<Contact> existingContacts = [
            SELECT Id
            FROM Contact
            WHERE Email = :contactEmail
            LIMIT 1
        ];
        
        if (!existingContacts.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
            'This username is already in use. Refresh the page and select another one.'
                ));
            return null;
        }
        
        Savepoint sp = Database.setSavepoint();
        
        List<String> contactType = new List<String>{
            'Case Owner',
            'Lead Owner',
            'Opportunity Owner'
        };
        
        try {
            Contact newContact = new Contact();
            
            newContact.FirstName = selectedWorkday.First_Name__c;
            newContact.LastName = selectedWorkday.Last_Name__c;
            newContact.Phone = selectedWorkday.Phone__c;
            newContact.Title = selectedWorkday.Job_Title__c;
            newContact.Birthdate = selectedWorkday.Birthdate__c;
            newContact.Username__c = selectedUsername;
            newContact.Email = selectedUsername + '@cloudrix.com';
            newContact.AccountId = '001dM00003h235q';
            
            newContact.Contact_Type__c = contactType[randomIndex(3)];
            
            newContact.MailingStreet = selectedWorkday.Street__c;
            newContact.MailingCity = selectedWorkday.City__c;
            newContact.MailingState = selectedWorkday.State__c;
            newContact.MailingPostalCode = selectedWorkday.Postal_Code__c;
            newContact.MailingCountry = selectedWorkday.Country__c;
            
            newContact.Employee_Number__c = selectedWorkday.Employee_Number__c;
            newContact.Employee_Status__c = 'Hired';
            newContact.Start_Date__c = Date.today();
            
            // Create the Contact.
            insert newContact;
            
            // Update the Workday record's hiring status.
            Workday__c workdayToUpdate = new Workday__c(
                Id = selectedWorkday.Id,
            Employee_Status__c = 'Hired',
            Start_Date__c = Date.today()
                );
            
            update workdayToUpdate;
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.CONFIRM,
            'Contact created and employee status updated to Hired.'
                ));
            
            // Update the in-memory record for the current page.
            selectedWorkday.Employee_Status__c = 'Hired';
            
        } catch (DmlException e) {
            Database.rollback(sp);
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
            'Hiring failed: ' + e.getDmlMessage(0)
                ));
        }
        
        return null;
    }
    
    
    // CHECK WHETHER THE LIST VIEW HAS RECORDS
    public Boolean getHasRecords() {
        return workdayRecords != null &&
            !workdayRecords.isEmpty();
    }
}