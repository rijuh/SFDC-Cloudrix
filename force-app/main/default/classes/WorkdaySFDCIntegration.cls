public with sharing class WorkdaySFDCIntegration {

    public static Integer fetchAndInsertWorkday() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:https://dummyjson.com/users');
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(20000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            throw new CalloutException(
                'API request failed. HTTP status: ' + res.getStatusCode()
            );
        }

        Map<String, Object> responseData =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        List<Object> users = (List<Object>) responseData.get('users');
        List<Workday__c> recordsToInsert = new List<Workday__c>();

        if (users == null || users.isEmpty()) {
            return 0;
        }

        for (Object userItem : users) {
            Map<String, Object> person =
                (Map<String, Object>) userItem;

            Map<String, Object> address =
                (Map<String, Object>) person.get('address');

            Map<String, Object> company =
                (Map<String, Object>) person.get('company');

            Workday__c workday = new Workday__c();

            workday.First_Name__c =
                valueAsString(person.get('firstName'));

            workday.Middle_Name__c =
                valueAsString(person.get('maidenName'));

            workday.Last_Name__c =
                valueAsString(person.get('lastName'));

            workday.Name =
                valueAsString(person.get('firstName')) + ' ' +
                valueAsString(person.get('lastName'));

            workday.Phone__c =
                valueAsString(person.get('phone'));

            workday.Birthdate__c =
                parseBirthdate(valueAsString(person.get('birthDate')));

            if (address != null) {
                workday.Street__c =
                    valueAsString(address.get('address'));
                workday.City__c =
                    valueAsString(address.get('city'));
                workday.State__c =
                    valueAsString(address.get('state'));
                workday.Postal_Code__c =
                    valueAsString(address.get('postalCode'));
                workday.Country__c =
                    valueAsString(address.get('country'));
            }

            if (company != null) {
                workday.Job_Title__c =
                    valueAsString(company.get('title'));
            }

            recordsToInsert.add(workday);
        }

        insert recordsToInsert;
        return recordsToInsert.size();
    }

    private static String valueAsString(Object value) {
        return value == null ? null : String.valueOf(value);
    }

    private static Date parseBirthdate(String birthdateText) {
        if (String.isBlank(birthdateText)) {
            return null;
        }

        List<String> parts = birthdateText.split('-');

        if (parts.size() != 3) {
            throw new CalloutException(
                'Unexpected birthDate format: ' + birthdateText
            );
        }

        return Date.newInstance(
            Integer.valueOf(parts[0]),
            Integer.valueOf(parts[1]),
            Integer.valueOf(parts[2])
        );
    }
}