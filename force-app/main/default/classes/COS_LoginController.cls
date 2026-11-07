public with sharing class COS_LoginController {

    public String username { get; set; }
    public String password { get; set; }
    public String successMessage { get; set; }

    public COS_LoginController() {
        String msg = ApexPages.currentPage().getParameters().get('msg');

        if(msg == 'registered'){
            successMessage = 'Registration successful';
        }
    }

    public PageReference login() {

        if(String.isBlank(username) || String.isBlank(password)){
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Username and Password are required.'
                )
            );
            return null;
        }

        return null;
    }

}