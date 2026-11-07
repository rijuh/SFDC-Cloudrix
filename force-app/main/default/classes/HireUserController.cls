public with sharing class HireUserController {

    @AuraEnabled
    public static String hireUser(Id regId) {

        User_Registration__c reg = [
            SELECT Id,
                   First_Name__c,
                   Last_Name__c,
                   Username__c,
                   Email__c,
                   Role__c,
                   Status__c
            FROM User_Registration__c
            WHERE Id = :regId
            LIMIT 1
        ];

        // Check already hired
        if(reg.Status__c == 'Hired') {
            throw new AuraHandledException('User already hired');
        }

        New_Hire__c nh = new New_Hire__c();

        nh.First_Name__c = reg.First_Name__c;
        nh.Last_Name__c = reg.Last_Name__c;
        nh.Username__c = reg.Username__c;
        nh.Email__c = reg.Email__c;
        nh.Password__c = generatePassword();
        nh.Role__c = reg.Role__c;
        nh.Status__c = 'Hired';
        nh.Re_Hire__c = false;
        nh.Hiring_Date__c = Date.today();
        nh.Profile__c = 'Standard User';

        try {

            insert nh;

            reg.Status__c = 'Hired';
            update reg;

            return 'User hired successfully';

        } catch(Exception e) {

            reg.Status__c = 'Failed';
            update reg;

            throw new AuraHandledException(e.getMessage());
        }
    }

    // GENERATE RANDOM 8 LENGTH PASSWORD
    public static String generatePassword() {

        String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String lower = 'abcdefghijklmnopqrstuvwxyz';
        String numbers = '0123456789';
        String special = '@#$%&*!';
        String allChars = upper + lower + numbers + special;

        List<String> chars = new List<String>();

        chars.add(getRandomChar(upper));
        chars.add(getRandomChar(lower));
        chars.add(getRandomChar(numbers));
        chars.add(getRandomChar(special));

        for(Integer i = 0; i < 4; i++) {
            chars.add(getRandomChar(allChars));
        }

        String password = '';

        while(chars.size() > 0) {

            Integer pos = getRandomNumber(chars.size());

            password += chars[pos];
            chars.remove(pos);
        }

        return password;
    }

    // GET RANDOM CHARACTER
    public static String getRandomChar(String source) {

        Integer index = getRandomNumber(source.length());

        return source.mid(index, 1);
    }

    // SAFE RANDOM NUMBER
    public static Integer getRandomNumber(Integer maxVal) {

        Integer num = Crypto.getRandomInteger();

        if(num < 0) {
            num = num * -1;
        }

        return Math.mod(num, maxVal);
    }
}