public with sharing class CosBannerController {
    @AuraEnabled(cacheable=true)
    public static String getCosBanner() {
        try {
            return System.Label.COS_Banner;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'CosBannerController.getCosBanner failed: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Unable to load the site banner. Contact your Salesforce administrator.');
        }
    }
}
