import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CosPageContent extends LightningElement {
    pageName = '';
    pageDescription = '';
    isCreateCasePage = false;
    submitted = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (!currentPageReference) {
            return;
        }

        const path = window.location.pathname;
        this.isCreateCasePage = path.includes('create-case') || path.includes('submit-case');

        if (this.isCreateCasePage) {
            this.pageName = 'Create a Case';
            this.pageDescription = 'Tell us how we can help and our support team will follow up.';
        } else if (path.includes('view-cases')) {
            this.pageName = 'View Cases';
            this.pageDescription = 'Track all submitted support cases.';
        } else {
            this.pageName = 'Home';
            this.pageDescription = 'Welcome to Cloudrix Online Support.';
        }
    }

    handleSuccess(event) {
        this.submitted = true;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Case submitted',
            message: `Your case was submitted successfully. Record ID: ${event.detail.id}`,
            variant: 'success'
        }));
    }

    handleError(event) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Unable to submit case',
            message: event.detail?.message || 'Please try again or contact support.',
            variant: 'error'
        }));
    }

    handleSubmitAgain() {
        this.submitted = false;
    }
}
