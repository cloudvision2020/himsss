import { LightningElement,wire,track,api } from 'lwc';
import fetchCEHoursActive from '@salesforce/apex/TranscriptCEHoursController.fetchCEHoursActive';  
import fetchCEHoursInActive from '@salesforce/apex/TranscriptCEHoursController.fetchCEHoursInActive';  
import deleteSelectedRecord from '@salesforce/apex/TranscriptCEHoursController.deleteSelectedRecord';
import createCertificate from '@salesforce/apex/TranscriptCEHoursController.createCertificate';
import viewCertificate from '@salesforce/apex/TranscriptCEHoursController.viewCertificate';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import submitText from '@salesforce/label/c.HIMSS_Submit';
import isrenewal from '@salesforce/label/c.HIMSS_Renewal';
import isrenewalSuccess from '@salesforce/label/c.HIMSS_Success';
import isCerttificateText	 from '@salesforce/label/c.isCerttificateText';
import isCerttificate from '@salesforce/label/c.isCerttificate';
import Certification_Eligible from '@salesforce/label/c.Certification_Eligible';
import Certification_Notify from '@salesforce/label/c.Certification_Notify';
import HIMSS_Certification_Period from '@salesforce/label/c.HIMSS_Certification_Period';

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
        isrenewalSuccess,
        isCerttificateText,	
        isCerttificate,
        Certification_Eligible,
        Certification_Notify,
        HIMSS_Certification_Period
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
    closeSubmit(event) {
        // to open modal set isModalOpen tarck value as true
        event.preventDefault();
        this.isModalOpen = false;
        this.isLoading = true;
        processSubscription({
            subId: event.target.dataset.id
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

    @track isCreateCertificate = false;
    
    createCertificate(event){
        event.preventDefault();
        this.isLoading = true;
        this.subscriptionId = event.target.dataset.id;
        createCertificate({
            subId: event.target.dataset.id
        })  
        .then(result => {
            if(result != null){
                const evt = new ShowToastEvent({
                    title: 'Success Message',
                    message: isCerttificate,
                    variant: 'success',
                    mode:'dismissible'
                });
                this.dispatchEvent(evt);
                setTimeout(()=>{
                    this.isLoading = false;
                    this.isCreateCertificate = true;
                }, 12000);
                
                
            }else if(result == 'null'){
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

    viewCertificate(event){
        event.preventDefault();
        viewCertificate({
            subId: this.subscriptionId
        })  
        .then(result => {
            this.isCreateCertificate = false;
            if(result != null){
               window.open('/Himss/servlet/servlet.FileDownload?file='+ result);
            }
        })
        .catch(error => {
            console.log('Error processing subscription:', error);
        });
    }

    closeCertificate(){
        this.isCreateCertificate = false;
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
    
    handleCreditDate(event){
        //alert('ala');
        var selected_Value = event.detail.value;
        //alert(selected_Value);
        


        // var dateval;
        // dateval = new Date().toISOString().substring(0, 10);
        // console.log('dateval '+dateval);
        // var myDate = new Date(dateval);
        // var myDate1 = new Date(event.detail.value);
        // if(myDate1 > myDate){
        //     console.log('error ');

        //     const event = new ShowToastEvent({
        //         title: 'Error',
        //         message: 'Invalid input!',
        //         variant: 'error',
        //     });
        //     this.dispatchEvent(event);
        //     return;

        // }

    }

    handleSubmit(event){
        event.preventDefault(); 
        const fields = event.detail.fields;
        // console.log('fields ' +fields);
        // console.log('fields1 ' +fields.Credit_Date__c);

        // var dateval;
        // dateval = new Date().toISOString().substring(0, 10);
        // console.log('dateval '+dateval);
        // var myDate = new Date(dateval);
        // var myDate1 = new Date(fields.Credit_Date__c);
        // if(myDate1 > myDate){
        //     console.log('error ');

        //     // const form = this.template.querySelector('lightning-record-edit-form');
        //     // if (!form.checkValidity()) {
        //     //     form.reportValidity();
        //     //     return;
        //     // }

        //     const inputField = this.template.querySelector('lightning-input-field');
        //     console.log('inputField '+inputField.fieldName);
        //     inputField.setCustomValidity('Invalid input!');
        //     inputField.reportValidity();
        //     inputField.showHelpMessageIfInvalid();
        //     return;

        // }
        // else{
        //     console.log('success ');
        // }
        

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