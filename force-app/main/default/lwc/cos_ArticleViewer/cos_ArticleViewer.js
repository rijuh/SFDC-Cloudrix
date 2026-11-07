
import { LightningElement } from 'lwc';

export default class Cos_ArticleViewer extends LightningElement {

    articleId = 'a05dM00000kgDEUQA2';

    get previewUrl() {
        return 'https://wise-impala-52dm6v-dev-ed--c.trailblaze.vf.force.com/apex/COS_ArticleAttachmentPortal?id='
            + encodeURIComponent(this.articleId);
    }
}
