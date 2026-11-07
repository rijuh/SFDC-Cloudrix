public with sharing class COSMenuController {

    @AuraEnabled(cacheable=true)
    public static List<COS_Menu__mdt> getMenus(){
        try {
            return [
                SELECT DeveloperName,
                       Menu_Label__c,
                       Menu_URL__c,
                       Parent_Menu__c,
                       Display_Order__c,
                       Active__c
                FROM COS_Menu__mdt
                WHERE Active__c = true
                ORDER BY Display_Order__c
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'COSMenuController.getMenus failed: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Unable to load the site navigation. Contact your Salesforce administrator.');
        }
    }
}
