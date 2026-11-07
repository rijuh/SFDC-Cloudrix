public with sharing class ArticleAttachmentPortalController {

    public String htmlContent { get; private set; }

    private static final Integer MAX_FILE_SIZE = 500000;

    public ArticleAttachmentPortalController(
        ApexPages.StandardController controller
    ) {

        Id articleId = controller.getId();

        // Find the HTML file linked to this Article
        List<ContentDocumentLink> files = [
            SELECT ContentDocumentId,
                   ContentDocument.Title,
                   ContentDocument.FileExtension
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :articleId
            AND ContentDocument.FileExtension IN ('html', 'htm')
            ORDER BY SystemModstamp DESC
            LIMIT 1
        ];

        if (files.isEmpty()) {
            htmlContent = '<h2>No HTML document found.</h2>';
            return;
        }

        // Get the latest version of the file
        List<ContentVersion> versions = [
            SELECT VersionData, ContentSize
            FROM ContentVersion
            WHERE ContentDocumentId = :files[0].ContentDocumentId
            AND IsLatest = true
            LIMIT 1
        ];

        if (versions.isEmpty()) {
            htmlContent = '<h2>HTML document not found.</h2>';
            return;
        }

        ContentVersion version = versions[0];

        // File size validation
        if (version.ContentSize > MAX_FILE_SIZE) {
            htmlContent = '<h2>HTML document exceeds the preview limit.</h2>';
            return;
        }

        // Read the uploaded HTML file
        htmlContent = version.VersionData.toString();
    }
}