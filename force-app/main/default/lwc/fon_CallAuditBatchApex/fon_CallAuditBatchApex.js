import { LightningElement,api,wire,track } from 'lwc';
import searchSubscriptionList from '@salesforce/apex/Fon_callBatchApexController.searchSubscriptionsList';
import executeBatchJob from '@salesforce/apex/Fon_callBatchApexController.executeBatchJob';
import getBatchJobStatus from '@salesforce/apex/Fon_callBatchApexController.getBatchJobStatus';
import { CloseActionScreenEvent } from 'lightning/actions';
import AuditSubscriptionList from '@salesforce/label/c.Number_Of_Active_Audit_Subscriptions';
import SubscriptionList from '@salesforce/label/c.Number_Of_Active_Subscriptions';
import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';



export default class Fon_CallAuditBatchApex extends LightningElement {
    @api recordId;
    @track auditSubscriptionLst;
    @track subscriptionLst;
    @track eligibleSubscriptions;
    @track showButton=false;
    @track processStatus = 'In Progress';
    @track processedPercent;
    @track progress = 0;
    @track ButtonName = 'auditSubscriptions';
    @track BatchName;
    @track areDetailsVisible = false;
    @track _interval;
    @track isData=true;

    
    label = {
        AuditSubscriptionList,
        SubscriptionList
    };

    handleBatchClass(){
        this.isData=false;
        this.areDetailsVisible = true;
        this.showButton= true;
        executeBatchJob({ itemId: this.recordId,eligibleSubscriptions:this.eligibleSubscriptions})
        .then(result =>{
            this.BatchName = result
            this.processedPercent = 0;
            
            this._interval = setInterval(() => {
                getBatchJobStatus({ jobID: this.BatchName})
                .then(result =>{
                    
                    if(result.JobItemsProcessed != 0){
                        
                        this.processedPercent = (result.JobItemsProcessed / result.TotalJobItems) * 100;
                    
                    }
                    this.progress = this.processedPercent === 100 ? clearInterval(this._interval) : this.processedPercent;
                    this.processStatus = 'Processing => ' + Math.floor(this.progress) +'/100';
                    if(this.processedPercent === 100) {
                        this.processStatus = 'Completed';
                    }
                    
                })
                .catch(error =>{
                    this.errorMsg = error;
                })

            }, 300);
                
            
        })
        .catch(error =>{
            this.errorMsg = error;
        })
    }
    renderedCallback() {
       if(this.processStatus == 'Completed') {

        this.progress= 100;
        }
    }
    
    @wire(searchSubscriptionList, {itemId:'$recordId'})
    wiredSubscription({data, error}){
        this.showButton=false;
        if(data){ 
            this.subscriptionLst = data.activeSubscriptions;
            this.auditSubscriptionLst = data.auditSubscriptions;
            this.eligibleSubscriptions=data.eligibleSubscriptions;
            if(this.subscriptionLst==0 || this.eligibleSubscriptions<1){
                this.showButton=true;
            }
        }
        else if(!data){
            this.subscriptionLst = 0;
            this.auditSubscriptionLst = 0;
            this.showButton=true;
        }
        else if (error) {
            
        }
    }
    handleCancel(event) {
        // Add your cancel button implementation here
        this.dispatchEvent(new CloseActionScreenEvent());
     }
 
    }