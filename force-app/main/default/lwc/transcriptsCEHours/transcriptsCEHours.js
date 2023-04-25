import { LightningElement,wire,track,api } from 'lwc';
import fetchCEHoursActive from '@salesforce/apex/TranscriptCEHoursController.fetchCEHoursActive';  
import fetchCEHoursInActive from '@salesforce/apex/TranscriptCEHoursController.fetchCEHoursInActive';  
import deleteSelectedRecord from '@salesforce/apex/TranscriptCEHoursController.deleteSelectedRecord';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import submitText from '@salesforce/label/c.HIMSS_Submit';
import isrenewal from '@salesforce/label/c.HIMSS_Renewal';
import isrenewalSuccess from '@salesforce/label/c.HIMSS_Success';
import processSubscription from '@salesforce/apex/TranscriptCEHoursController.processSubscription';
import { NavigationMixin } from "lightning/navigation";


import { refreshApex } from '@salesforce/apex'

const actions = [

    { label: 'Edit', name: 'edit' },

    { label: 'Delete', name: 'delete' },

];
const COLUMNS = [  
    { label: 'Name', fieldName: 'Name'},  
    { label: 'Credit Date', fieldName: 'Credit_Date__c' },  
    { label: 'Number Of Credits', fieldName: 'Number_Of_Credits__c'},
    { label: 'Program Title', fieldName: 'Program_Title__c'},
    { label: 'Activity Type', fieldName: 'Activity_Type__c'},
    { label: 'Education Provider', fieldName: 'Education_Provider__c'},
    { type: 'action',typeAttributes: { rowActions: actions }}];

const COLUMNS1 = [  
    { label: 'Name', fieldName: 'Name'},  
    { label: 'Credit Date', fieldName: 'Credit_Date__c' },  
    { label: 'Number Of Credits', fieldName: 'Number_Of_Credits__c'},
    { label: 'Program Title', fieldName: 'Program_Title__c'},
    { label: 'Activity Type', fieldName: 'Activity_Type__c'},
    { label: 'Education Provider', fieldName: 'Education_Provider__c'}];


export default class TranscriptsCEHours extends NavigationMixin(LightningElement) {
    
    label = {
        submitText,
        isrenewal,
        isrenewalSuccess
    };
    
    columns = COLUMNS; 
    columns1 = COLUMNS1; 
    error;
    showNewActive = false; 
    showNewInActive = false; 
    isSubmit = false;
    ceHoursActive;
    ceHoursInactive
    @track termId;
    @track inActivetermId;
    @track recordToDelete;
    @track isLoading = false;
    ceHourSelected;
    wiredData;
    wiredData2;

    @track showDeleteModal = false;
    @track header = 'Delete Record';
    @track bodyText = 'Are you sure you want to delete the record?';
    @track cancelButtonLabel = 'Cancel';
    @track confirmButtonLabel = 'Ok';
    @track confirmButtonVariant = 'brand';
    @api subscriptionId;
    @api soEncryptId;

    activeSections = ['A', 'C'];
    activeSectionsMessage = '';

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }
    
    @wire(fetchCEHoursActive,{ isActive: true }) wiredCallbackResult1(result){
        this.wiredData = result;
        if(result.data){
            this.ceHoursActive = result.data;
            //this.termId = this.ceHoursActive[0].subscription.OrderApi__Renewals__r[0].Id;
            this.subscriptionId = this.ceHoursActive[0].subscription.Id;
        }
    }
    @wire(fetchCEHoursInActive,{ isActive: false }) wiredCallbackResult2(result){
        this.wiredData2 = result;
        if(result.data){
            this.ceHoursInactive = result.data;
            console.log('result of data'+ JSON.stringify(result.data));
            //this.inActivetermId = this.ceHoursInactive[0].subscription.OrderApi__Renewals__r[0].Id;
        }
    }
    @track isModalOpen = false;
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }

    cancel() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    
    @track isModalOpen2 = false;
    closeSubmit() {
        // to open modal set isModalOpen tarck value as true
        
        this.isModalOpen = false;
        this.isLoading = true;
        processSubscription({
            subId: this.subscriptionId
        })  
        .then(result => {
            this.isLoading = false;
            if(result != null){
                this.soEncryptId = result;
                const evt = new ShowToastEvent({
                    title: 'Success Message',
                    message: isrenewalSuccess,
                    variant: 'success',
                    mode:'dismissible'
                });
                this.dispatchEvent(evt);
                this.isModalOpen2 = true;
                
            }else{
                const evt = new ShowToastEvent({
                    title: 'Success Message',
                    message: 'Something went wrong.',
                    variant: 'error',
                    mode:'dismissible'
                });
                this.dispatchEvent(evt);
            }
            
           
        })
        .catch(error => {
            console.log('Error processing subscription:', error);
        });
    }
    cancelRenewal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen2 = false;
    }
    
    closeRenewal() {
        this.isModalOpen2 = false;
        window.open('/Himss/s/store#/store/checkout/'+ this.soEncryptId, "_self");
    }
        
    openPopup1(event){
        this.ceHourSelected = null;
        this.termId = event.target.dataset.id;
        this.showNewActive = true; 
    }
  
    cloesePopup1(event){
        this.showNewActive = false; 
        this.ceHourSelected = null;
        this.termId = null;
    }
 
    handleSubmit(event){
        event.preventDefault(); 
        const fields = event.detail.fields;
        //fields.Term__c = this.ceHoursInactive[0];
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.showNewActive = false; 
        this.ceHourSelected = null;
    }
    handleRefresh(event) {                  
        refreshApex(this.wiredData);
        refreshApex(this.wiredData2);
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':

                this.showDeletePopup(row.Id);

                break;

            case 'edit':

                this.editRecordDetail(row.Id);

                break;

            default:
        }   

    }
    showDeletePopup(recordIdToDelete) {
        this.showDeleteModal = true;
        this.recordToDelete = recordIdToDelete;
    }
    closeDeletePopup(){
        this.showDeleteModal = false;
        this.recordToDelete = null;
    }
    editRecordDetail(rowId){
        this.ceHourSelected = rowId;
        this.showNewActive = true; 
    }
    handleDeleteRow() {
        this.showDeleteModal = false;
        if(this.recordToDelete){
            deleteSelectedRecord({selectedId:this.recordToDelete})
            .then(result =>{
                //this.showLoadingSpinner = false;
                if(result==null){
                    const evt = new ShowToastEvent({
                        title: 'Success Message',
                        message: 'Record deleted successfully ',
                        variant: 'success',
                        mode:'dismissible'
                    });
                    this.dispatchEvent(evt);
                    this.handleRefresh();
                }
                else{
                    this.showError(result);
                }
            } )
            .catch(error => {
                this.error = error;
                this.showError(error);
            });
        }
        else{
            this.showError('Failed to delete the record');
        }

    }
    showError(message){
        const evt = new ShowToastEvent({
            title: 'Error Message',
            message: message,
            variant: 'error',
            mode:'dismissible'
        });
        this.dispatchEvent(evt);
    }
    

}