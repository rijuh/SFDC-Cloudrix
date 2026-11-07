public with sharing class ContactTriggerHandler {
    public static void createUserOnContact(List<contact> contacts){
        if(contacts.isEmpty()){
            return;
        }

        List<User> newUsersList = new List<User>();

        for (Contact con: contacts){
            User newUser = new User();
            // newUser.ContactId = con.Id; // CAN NOT ASSOCIATE CONTACT WITH CHATTER FREE USER

            newUser.FirstName = con.FirstName;
            newUser.LastName = con.LastName;
            newUser.Alias = con.Employee_Number__c;
            newUser.username = con.Email;
            newUser.Email = con.Email;

            newUser.Title = con.Title;

            newUser.ProfileId = '00edM00000Ow5ZvQAJ'; 

            newUser.Street = con.MailingStreet;
            newUser.State = con.MailingState;
            newUser.PostalCode = con.MailingPostalCode;
            newUser.City = con.MailingCity;
            newUser.Country = con.MailingCountry;
            newUser.Phone = con.Phone;

            newUser.EmailEncodingKey = 'UTF-8';

            newUser.TimeZoneSidKey = 'Asia/Kolkata';
            newUser.LocaleSidKey = 'en_IN';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.CurrencyIsoCode = 'INR';

            newUsersList.add(newUser);
        }

        try {
            insert newUsersList;
        } 
        catch (DmlException e){
            System.debug(e);
        }
    }

}
