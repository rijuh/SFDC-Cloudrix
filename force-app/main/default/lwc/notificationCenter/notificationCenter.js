import { LightningElement, wire } from 'lwc';
import getNotifications from '@salesforce/apex/NotificationServices.getNotifications';

export default class NotificationCenter extends LightningElement {
    notifications = [];

    @wire(getNotifications)
    wiredNotifications({ data, error }) {
        if (data) {
            this.notifications = data.map(item => ({
                ...item,
                createdDate: new Date(item.CreatedDate).toLocaleString(),
                cardClass: item.Status__c === 'Unread'
                    ? 'notificationCard unread'
                    : 'notificationCard read',
                statusText: item.Status__c === 'Unread'
                    ? '● Unread'
                    : '✓ Read',
                statusClass: item.Status__c === 'Unread'
                    ? 'statusUnread'
                    : 'statusRead'
            }));
        } else if (error) {
            console.error(error);
        }
    }

    refresh() {

    }

    markAllRead() {

    }

    openRecord(event) {
        const recordId = event.currentTarget.dataset.id;
        console.log(recordId);
    }
}