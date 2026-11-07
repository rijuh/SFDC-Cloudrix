public class COS_RegistrationTriggerHandler {

    public static void createContacts(List<COS_Registration__c> registrations){

        List<Contact> contactsToInsert = new List<Contact>();

        for(COS_Registration__c reg : registrations){

            Contact con = new Contact();

            con.FirstName = reg.First_Name__c;
            con.LastName  = reg.Last_Name__c;
            con.Email = reg.Email__c;
            con.Username__c = reg.Username__c;
            con.COS_Login_Id__c = reg.Username__c;
            con.COS_Registration_Date__c = reg.Registration_Date__c;

            contactsToInsert.add(con);
        }

        if(!contactsToInsert.isEmpty()){
            insert contactsToInsert;
        }

    }

}