public with sharing class NotificationServices {

    // GENERATE NOTIFICATION FROM TEMPLATE
    private static String replacePlaceholders(
        String template,
        Map < String, String > values
    ) {

        if (String.isBlank(template) || values == null || values.isEmpty()) {
            return template;
        }

        for (String key: values.keySet()) {
            template = template.replace(
                '{' + key + '}',
                values.get(key) == null ? '' : values.get(key)
            );
        }

        return template;
    }

    // TO CREATE SINGLE NOTIFICATION
    public static void createNotification(String notificationType, Map<String, String> values, Id relatedRecordId) {

        Notification_Template__mdt template = Notification_Template__mdt.getInstance(notificationType);

        if (template == null || !template.Active__c) {
            return;
        }

        String title = replacePlaceholders(template.Title_Template__c, values);
        String message = replacePlaceholders(template.Message_Template__c, values);

        Notification__c notify = new Notification__c();

        notify.Title__c = title;
        notify.Message__c = message;
        notify.Status__c = 'Unread';

        insert notify;
    }

    // FETCH ALL NOTIFICATIONS
    @AuraEnabled(cacheable = true)
    public static List < Notification__c > getNotifications() {
        return [
            SELECT Name,
            Title__c,
            Message__c,
            Status__c,
            CreatedDate
            FROM Notification__c
            ORDER BY CreatedDate DESC
        ];
    }
}