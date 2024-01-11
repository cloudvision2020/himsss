import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import getUserContactId from '@salesforce/apex/UserContactIdController.getUserContactId';

export default class ContactIdUpdater extends NavigationMixin(LightningElement) {
    @track contactId = '';

    connectedCallback() {
        // Get the Contact ID from the Apex controller on page load
        this.contactId = '003P000001aIgQdIAK';
        this.updateURL();
        /*
        
        getUserContactId()
            .then(result => {
                if (result) {
                    this.contactId = result;
                }
            })
            .catch(error => {
                console.error('Error fetching Contact ID:', error);
            });
            */
    }

    handleContactIdChange(event) {
        this.contactId = event.target.value;
        // Update the URL with the new Contact ID
        this.updateURL();
    }

    updateURL() {
        // Update the URL with the new Contact ID
        const url = new URL(window.location.href);
        url.searchParams.set('recordId', this.contactId);
        // Use the NavigationMixin to update the URL without page refresh
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url.toString(),
            },
        });
    }
}