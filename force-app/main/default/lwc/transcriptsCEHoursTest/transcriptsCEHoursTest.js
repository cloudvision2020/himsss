import { LightningElement, wire, track, api } from 'lwc';
import fetchCEHoursActive from '@salesforce/apex/TranscriptCEHoursController.fetchCEHoursActive';
import fetchCEHoursInActive from '@salesforce/apex/TranscriptCEHoursController.fetchCEHoursInActive';
import editCEHours from '@salesforce/apex/TranscriptCEHoursController.editCEHours';
import getUserInfo from '@salesforce/apex/TranscriptCEHoursController.getUserInfo';

import deleteSelectedRecord from '@salesforce/apex/TranscriptCEHoursController.deleteSelectedRecord';
import createCertificate from '@salesforce/apex/TranscriptCEHoursController.createCertificate';
import viewCertificate from '@salesforce/apex/TranscriptCEHoursController.viewCertificate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitText from '@salesforce/label/c.HIMSS_Submit';
import isrenewal from '@salesforce/label/c.HIMSS_Renewal';
import isrenewalSuccess from '@salesforce/label/c.HIMSS_Success';
import isCerttificateText from '@salesforce/label/c.isCerttificateText';
import isCerttificate from '@salesforce/label/c.isCerttificate';
import Certification_Eligible from '@salesforce/label/c.Certification_Eligible';
import processSubscription from '@salesforce/apex/TranscriptCEHoursController.processSubscription';
import CEHours_OBJECT from '@salesforce/schema/CE_Hours__c';
import ceHoursId from '@salesforce/schema/CE_Hours__c.Id';
import ceCreditDate from '@salesforce/schema/CE_Hours__c.Credit_Date__c';
import ceNumberOfCredits from '@salesforce/schema/CE_Hours__c.Number_Of_Credits__c';
import ceProgramTitle from '@salesforce/schema/CE_Hours__c.Program_Title__c';
import ceActivityType from '@salesforce/schema/CE_Hours__c.Activity_Type__c';
import ceTermNumber from '@salesforce/schema/CE_Hours__c.Term__c';
import ceEducationProvider from '@salesforce/schema/CE_Hours__c.Education_Provider__c';
import { NavigationMixin } from "lightning/navigation";
import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import isCerttificateTextLabel from '@salesforce/label/c.Certification_Eligible';
import Certification_Notify from '@salesforce/label/c.Certification_Notify';
import getTerm from '@salesforce/apex/TranscriptCEHoursController.getTerm';
import HIMSS_Certification_Period from '@salesforce/label/c.HIMSS_Certification_Period';
import { refreshApex } from '@salesforce/apex';


const actions = [

    { label: 'Edit', name: 'edit' },

    { label: 'Delete', name: 'delete' },

];
const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Credit Date', fieldName: 'Credit_Date__c' },
    { label: 'Number Of Credits', fieldName: 'Number_Of_Credits__c' },
    { label: 'Program Title', fieldName: 'Program_Title__c' },
    { label: 'Activity Type', fieldName: 'Activity_Type__c' },
    { label: 'Education Provider', fieldName: 'Education_Provider__c' },
    { type: 'action', typeAttributes: { rowActions: actions } }];

const COLUMNS1 = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Credit Date', fieldName: 'Credit_Date__c' },
    { label: 'Number Of Credits', fieldName: 'Number_Of_Credits__c' },
    { label: 'Program Title', fieldName: 'Program_Title__c' },
    { label: 'Activity Type', fieldName: 'Activity_Type__c' },
    { label: 'Education Provider', fieldName: 'Education_Provider__c' }];


export default class TranscriptsCEHoursTest extends NavigationMixin(LightningElement) {

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
    creditDate = '';
    numberOfCredits = '';
    programTitle = '';
    activityType = '';
    termId = '';
    educationProvider = '';
    activeSections = ['A', 'C'];
    activeSectionsMessage = '';
    @track selectTermId;
    @track ceHoursId;
    @track creditError = false;
    @track ceHoursDetails;
    @track termStartDate;
    @track termEndDate;
    @track termGracePeriodDate;

    @track ActivityTypeOptions = [
        { label: 'CE Hours', value: 'CE Hours' },
        { label: 'Academic Credits', value: 'Academic Credits' },
        { label: 'Presentation', value: 'Presentation' },
        { label: 'Publications', value: 'Publications' },
        { label: 'Professional Service', value: 'Professional Service' },
        { label: 'Item Writing', value: 'Item Writing' },
        { label: 'Ethics', value: 'Ethics' }
    ];

    @track EducationOptions = [
        { label: 'HIMSS', value: 'HIMSS' },
        { label: 'NON-HIMSS	', value: 'NON-HIMSS' },
        { label: 'HIMSS Chapter	', value: 'HIMSS Chapter' },
        { label: 'Digital Health Canada', value: 'Digital Health Canada'}
    ];

    userInfo;
    activeCertifications;
    inactiveCertifications;
    /*
    @wire(getUserInfo)
    wiredUserInfo({ error, data }) {
        console.log('wiredUserInfo : '+data);
        if (data) {
            this.userInfo = data;
        } else if (error) {
            // Handle error if necessary
        }
    }
    */
    @wire(getUserInfo) wiredCallbackResult3(result) {
        this.userInfo = result;
        console.log('getUserInfo wiredCallbackResult3 : '+result);
        if (result.data) {
            console.log('result.data : '+result.data.Name)
            console.log('>> ' + JSON.stringify(result.data));
            this.userInfo = result.data;
            this.activeCertifications = 'Active Certifications for '+result.data.Name;
            this.inactiveCertifications = 'InActive Certifications for '+result.data.Name;
        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    @track creditError = false;

    /*handleCreditDateChange(event) {
        this.creditDate = event.target.value;
        this.validateCreditDate();
    }*/
    handleCreditDateChange(event) {
        console.log('event.target.value >> '+event.target.value);
        if (event.target.label == 'Credit Date') {
            this.creditDate = event.target.value;
            this.validateCreditDate();
        }
    }
    validateCreditDate() {
        const today = new Date().toISOString().split('T')[0];
        console.log('>>>toISOString ' +this.termStartDate);
        console.log('<<< termEndDate '+this.termEndDate);
        console.log('<<< creditDate '+this.creditDate);
        console.log('<<< credtermGracePeriodDateitDate '+this.termGracePeriodDate);
        this.creditError = true;
        if (this.creditDate >= this.termStartDate && this.creditDate < this.termGracePeriodDate && this.creditDate <= today) {

            this.creditError = false;
            //if (this.creditDate > this.termEndDate && this.creditDate < this.termGracePeriodDate && this.creditDate > today) {
              //  alert('within Grace Period ');
              //  this.creditError = true;
            //}   
        }else{
            this.creditError = true;
        }


    }
    formatDate(dateString) {
        const [month, day, year] = dateString.split('/');
        const formattedMonth = (month.length === 1) ? `0${month}` : month;
        const formattedDay = (day.length === 1) ? `0${day}` : day;
        const formattedYear = year;
        return `${formattedMonth}/${formattedDay}/${formattedYear}`;
    }


    get formattedCreditDate() {
       /* if (this.creditDate) {
             return this.formatDate(this.creditDate);
        }*/
          return '';
    }
    eligibileDate;
    @wire(fetchCEHoursActive, { isActive: true }) wiredCallbackResult1(result) {
        this.wiredData = result;
        if (result.data) {
            console.log('>> ' + JSON.stringify(result.data));
            this.ceHoursActive = result.data;
            //this.termId = this.ceHoursActive[0].subscription.OrderApi__Renewals__r[0].Id;
            this.subscriptionId = this.ceHoursActive[0].subscription.Id;
            //const options = { year: 'numeric', month: 'long', day: 'numeric' };
            
            this.eligibileDate = isCerttificateTextLabel; //+' '+this.ceHoursActive[0].subscription.Recert_Eligible_Date__c;
            //this.eligibileDate = isCerttificateTextLabel+' '+this.ceHoursActive[0].subscription.Recert_Eligible_Date__c.toLocaleDateString('en-US', options);
        }
    }
    @wire(fetchCEHoursInActive, { isActive: false }) wiredCallbackResult2(result) {
        this.wiredData2 = result;
        if (result.data) {
            this.ceHoursInactive = result.data;
            console.log('result of data' + JSON.stringify(result.data));
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
                if (result != null) {
                    this.soEncryptId = result;
                    const evt = new ShowToastEvent({
                        title: 'Success Message',
                        message: isrenewalSuccess,
                        variant: 'success',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(evt);
                    this.isModalOpen2 = true;

                } else {
                    const evt = new ShowToastEvent({
                        title: 'Success Message',
                        message: 'Something isCerttificateTextnt wrong.',
                        variant: 'error',
                        mode: 'dismissible'
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
        window.open('/Himss/s/store#/store/checkout/' + this.soEncryptId, "_self");
    }

    @track isCreateCertificate = false;

    createCertificate(event) {
        event.preventDefault();
        this.isLoading = true;
        this.subscriptionId = event.target.dataset.id;
        createCertificate({
            subId: event.target.dataset.id
        })
            .then(result => {
                if (result != null) {
                    const evt = new ShowToastEvent({
                        title: 'Success Message',
                        message: isCerttificate,
                        variant: 'success',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(evt);
                    setTimeout(() => {
                        this.isLoading = false;
                        this.isCreateCertificate = true;
                    }, 12000);


                } else if (result == 'null') {
                    const evt = new ShowToastEvent({
                        title: 'Success Message',
                        message: 'Something went wrong.',
                        variant: 'error',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                console.log('Error processing subscription:', error);
            });
    }

    viewCertificate(event) {
        event.preventDefault();
        viewCertificate({
            subId: this.subscriptionId
        })
            .then(result => {
                this.isCreateCertificate = false;
                if (result != null) {
                    window.open('/Himss/servlet/servlet.FileDownload?file=' + result);
                }
            })
            .catch(error => {
                console.log('Error processing subscription:', error);
            });
    }

    closeCertificate() {
        this.isCreateCertificate = false;
    }

    openPopup1(event) {
        this.ceHourSelected = null;
        this.termId = event.target.dataset.id;
        this.showNewActive = true;

        // Reset the state variables used in the modal
        this.creditDate = '';
        this.numberOfCredits = null;
        this.programTitle = '';
        this.activityType = '';
        //this.ceHourSelected = false;
        this.educationProvider = '';

        // Clear any error messages or validation states
        this.creditError = '';
        // Additional variables to reset if needed

        // Show the modal
        //  this.showNewActive = true;

        getTerm({ termId: this.termId })
        .then(data => {
            this.termStartDate = data.OrderApi__Term_Start_Date__c;
            this.termEndDate = data.OrderApi__Term_End_Date__c;
            this.termGracePeriodDate = data.OrderApi__Grace_Period_End_Date__c;
            console.log('>>>  ' +this.termStartDate);
            console.log('<<<  '+this.termEndDate);
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }

    cloesePopup1(event) {
        this.showNewActive = false;
        this.ceHourSelected = null;
        this.termId = null;

        this.creditDate = '';
        this.numberOfCredits = null;
        this.programTitle = '';
        this.activityType = '';
        //this.ceHourSelected = false;
        this.educationProvider = '';
    }

    handleCreditDate(event) {
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
    handleRefresh(event) {
        refreshApex(this.wiredData);
        refreshApex(this.wiredData2);
    }


    handleNumberOfCreditsChange(event) {
        if (event.target.label == 'Number of Credits') {
            this.numberOfCredits = event.target.value;
        }
    }

    handleProgramTitleChange(event) {
        if (event.target.label == 'Program Title') {
            this.programTitle = event.target.value;
        }
    }

    handleActivityTypeChange(event) {
        if (event.target.label == 'Activity Type') {
            this.activityType = event.target.value;
        }
    }
    handleEducationProviderChange(event) {
        if (event.target.label == 'Education Provider') {
            this.educationProvider = event.target.value;
        }
    }

    createCehoursAction() {
       // alert('<><> '+ this.creditError);
        if(this.creditError) {
            // Show error toast or perform necessary actions
            // Example: Display a toast notification
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Credit Date Should be within Recertification window.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        console.log('this.termId', this.termId); // Logs the value of selectTermId

        const fields = {};
        fields[ceCreditDate.fieldApiName] = this.creditDate;
        fields[ceNumberOfCredits.fieldApiName] = this.numberOfCredits;
        fields[ceProgramTitle.fieldApiName] = this.programTitle;
        fields[ceActivityType.fieldApiName] = this.activityType;
        fields[ceEducationProvider.fieldApiName] = this.educationProvider;

        

        console.log('fields', fields); // Logs the fields object
        console.log('this.ceHourSelected ', this.ceHourSelected);
        
        if(this.ceHourSelected == null) {

            fields[ceTermNumber.fieldApiName] = this.termId;
            
            console.log('create ');
            const recordInput = { apiName: CEHours_OBJECT.objectApiName, fields };
            console.log('recordInput', recordInput); // Logs the recordInput object
            createRecord(recordInput)
            .then(cehourobj => {
                console.log('cehourobj', cehourobj); // Logs the created CEhours object

                this.ceHoursId = cehourobj.id;
                this.fields = {};

                console.log("CEhours ID: " + this.ceHoursId); // Logs the CEhours ID

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'CEhours created successfully..!',
                        variant: 'success',
                    }),
                );
                this.handleRefresh();
            })
            .catch(error => {
                console.log(error); // Logs the error object

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        }
        console.log('this.ceHourSelected>> ', this.ceHourSelected);
        if(this.ceHourSelected != null) {
            console.log('this ', this.ceHourSelected);
            fields[ceHoursId.fieldApiName] = this.ceHourSelected;

            const recordInput = { fields };
            console.log('recordInput', recordInput); // Logs the recordInput object
            updateRecord(recordInput)
            .then(cehourobj => {
                console.log('cehourobj', cehourobj); // Logs the created CEhours object

                this.ceHoursId = cehourobj.id;
                this.fields = {};

                console.log("CEhours ID: " + this.ceHoursId); // Logs the CEhours ID

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'CEhours updated successfully..!',
                        variant: 'success',
                    }),
                );
                this.handleRefresh();
            })
            .catch(error => {
                console.log(error); // Logs the error object

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        }
        this.showNewActive = false;
        this.ceHourSelected = null;
        this.termId = null;

        this.creditDate = '';
        this.numberOfCredits = null;
        this.programTitle = '';
        this.activityType = '';
        //this.ceHourSelected = false;
        this.educationProvider = '';

    }


    myLookupHandle(event) {
        console.log(event.detail);
        this.termId = event.detail;
    }

    handleSubmit(event) {
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
    /*handleRefresh(event) {                  
        refreshApex(this.wiredData);
        refreshApex(this.wiredData2);
    }*/
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
        this.handleRefresh();
    }
    closeDeletePopup() {
        this.showDeleteModal = false;
        this.recordToDelete = null;
    }
    editRecordDetail(rowId) {
        this.ceHourSelected = rowId;
        this.showNewActive = true;

        editCEHours({subId : this.ceHourSelected})
        .then(result => {
            if (result) {
                this.creditDate = result.creditDate;
                this.numberOfCredits = result.creditNumber;
                this.programTitle = result.programTitle;
                this.activityType = result.activityType;
                this.educationProvider = result.educationProvider;
            }
            else {
                this.showError(result);
            }
        })
        .catch(error => {
            this.error = error;
            this.showError(error);
        });

        this.handleRefresh();
    }
    handleDeleteRow() {
        this.showDeleteModal = false;
        if (this.recordToDelete) {
            deleteSelectedRecord({ selectedId: this.recordToDelete })
                .then(result => {
                    //this.showLoadingSpinner = false;
                    if (result == null) {
                        const evt = new ShowToastEvent({
                            title: 'Success Message',
                            message: 'Record deleted successfully ',
                            variant: 'success',
                            mode: 'dismissible'
                        });
                        this.dispatchEvent(evt);
                        this.handleRefresh();
                    }
                    else {
                        this.showError(result);
                    }
                })
                .catch(error => {
                    this.error = error;
                    this.showError(error);
                });
        }
        else {
            this.showError('Failed to delete the record');
        }

    }
    showError(message) {
        const evt = new ShowToastEvent({
            title: 'Error Message',
            message: message,
            variant: 'error',
            mode: 'dismissible'
        });
        this.dispatchEvent(evt);
    }


}