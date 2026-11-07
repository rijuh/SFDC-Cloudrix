import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';

import hireUser from '@salesforce/apex/HireUserController.hireUser';

export default class HireButton extends LightningElement {

    @api recordId;

    @api async invoke() {

        try {

            const result = await hireUser({
                regId: this.recordId
            });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: result,
                    variant: 'success'
                })
            );

            // Reload / refresh record page
            this.dispatchEvent(new RefreshEvent());

        } catch(error) {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error?.body?.message || 'Error occurred',
                    variant: 'error'
                })
            );
        }
    }
}