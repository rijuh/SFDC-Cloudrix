@isTest
public class UserRegistrationControllerTest {
    
    @isTest
    static void testRegisterUser() {
        
        Test.startTest();
        
        String generatedUsername = UserRegistrationController.registerUser(
            'Ankit',
        'Hazra',
        'Developer'
            );
        
        Test.stopTest();
        
        // Verify username returned
        System.assertNotEquals(null, generatedUsername);
        System.assert(generatedUsername.startsWith('USR'));
        
        // Verify record inserted
        User_Registration__c userRec = [
            SELECT Id, Name, Role__c, Username__c
            FROM User_Registration__c
            WHERE Username__c = :generatedUsername
            LIMIT 1
        ];
        
        System.assertEquals('Ankit Hazra', userRec.Name);
        System.assertEquals('Developer', userRec.Role__c);
        System.assertEquals(generatedUsername, userRec.Username__c);
    }
    
    @isTest
    static void testGenerateUsername() {
        
        Test.startTest();
        
        String uname = UserRegistrationController.generateUsername('Ankit', 'Hazra');
        
        Test.stopTest();
        
        System.assertNotEquals(null, uname);
        System.assert(uname.startsWith('USR'));
    }
}