import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import USER_REGISTRATION_OBJECT from '@salesforce/schema/User_Registration__c';
import ROLE_FIELD from '@salesforce/schema/User_Registration__c.Role__c';

import registerUser from '@salesforce/apex/UserRegistrationController.registerUser';

export default class UserRegistrationForm extends LightningElement {

    firstName = '';
    lastName = '';
    selectedRole = '';
    roleOptions = [];

    // Get Object Info
    @wire(getObjectInfo, { objectApiName: USER_REGISTRATION_OBJECT })
    objectInfo;

    // Get Picklist Values
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: ROLE_FIELD
    })
    wiredRoles({ data, error }) {
        if (data) {
            this.roleOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    handleFirstName(event) {
        this.firstName = event.target.value;
    }

    handleLastName(event) {
        this.lastName = event.target.value;
    }

    handleRoleChange(event) {
        this.selectedRole = event.detail.value;
    }

    registerUser() {

        registerUser({
            firstName: this.firstName,
            lastName: this.lastName,
            role: this.selectedRole
        })

            .then(result => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Registration Successful',
                        variant: 'success'
                    })
                );

                // alert('Registration Successful!\nGenerated Username: ' + result);

                // Clear Form
                this.firstName = '';
                this.lastName = '';
                this.selectedRole = '';

                this.template.querySelectorAll('lightning-input').forEach(item => {
                    item.value = '';
                });

                this.template.querySelector('lightning-combobox').value = '';

            })

            .catch(error => {

                console.error('Full Error => ', error);

                let errorMessage = 'Registration Failed';

                if (error.body) {

                    if (error.body.message) {
                        errorMessage = error.body.message;
                    }
                    else if (
                        error.body.pageErrors &&
                        error.body.pageErrors.length > 0
                    ) {
                        errorMessage = error.body.pageErrors[0].message;
                    }
                    else if (error.body.fieldErrors) {
                        errorMessage = JSON.stringify(error.body.fieldErrors);
                    }
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );

                // alert(errorMessage);
            });
    }
}