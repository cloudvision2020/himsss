import { LightningElement,api,track, wire} from 'lwc';
import getpriceBookName from '@salesforce/apex/OpportunityRelatedProducts_c.getpriceBookName';
import saveProductList from '@salesforce/apex/OpportunityRelatedProducts_c.saveProductList';
import getCoulmnNames from '@salesforce/apex/OpportunityProductEditableList_c.getCoulmnNames';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class OpportunityRelatedProducts extends LightningElement {
    @api prop2;
    @api prop3;
    @api prop1;
    @api recordId;
    @track ShowModal = false;
    @api selectedProducts=[];
    @track resultToShow =[];
    @track oppId;
    @track recordsCount = 0;
    @track pricebookName;
    @track contractStatus;
    @track showList = true;
    @track productList;
    @track error;
    @api coulmnNamesResult =[];
    @api showLoading = false;
    @track showOpportunityProductSearch = false;
    connectedCallback(){
        
        this.oppId = this.recordId;
        getpriceBookName({oppId:this.oppId})
        .then(result => {
            this.pricebookName = result.pricebookName;
            this.contractStatus = result.contractStatus;
            this.getCoulmnNamesData();
        })
        .catch(error => {
            console.log('error-->' , JSON.stringify(error));
        });
    }
    
    getCoulmnNamesData(){
        getCoulmnNames({ oppId:  this.oppId})
        .then(result => {
            this.coulmnNamesResult = result;
        })
        .catch(error => {
            console.log('error-->' , JSON.stringify(error));
        });
    }
    resultCompletEvent(event){
        this.productList = event.detail;
        this.showOpportunityProductSearch = true;
    }
    handleAddProduct() {
         
        // to open modal window set 'ShowModal' tarck value as true
        this.ShowModal = true;
            
    }
 
    closeModal() {    
        // to close modal window set 'ShowModal' tarck value as false
        this.ShowModal = false;
        //window.location.reload();
        eval("$A.get('e.force:refreshView').fire();");
        this.template.querySelector("c-opportunity-product-list").refreshList();
    }

    saveRecords(event){
        //console.log('this.saveRecords-->' + JSON.stringify(event));
        this.productList = event.detail;
    }

    saveProductRecords(){
        var isValid = this.template.querySelector("c-opportunity-product-editable-list").checkValidation();
    
        var ArraySize = this.template.querySelector("c-opportunity-product-editable-list").checkArraySize();
        let oppId = this.recordid;
        //console.log('this.productList-->' + JSON.stringify(this.productList));
        //console.log('this.ArraySize-->' + ArraySize);
        //console.log('this.isValid-->' + isValid);
        var errorRows=[];
        var startDate;
        var endDate;
        for(var i=0;i<this.productList.length;i++){

            this.productList[i].fileDetailWrapper.forEach(element=>{
                
                if(element.fieldName === 'Start_Date__c'){
            
                     startDate = element.fieldValue;
                }
                if(element.fieldName === 'End_Date__c'){
                
                     endDate = element.fieldValue;
                }
            });
            if(endDate < startDate){

                errorRows.push(i);
            }
        }
    
        if(errorRows.length > 0){
            let message = 'Error in row ';
            errorRows.forEach(row=>{
                let rowNo = row + 1;
                message = message + rowNo + ',';
            });
            message=message.slice(0, -1);
            const event = new ShowToastEvent({
                title: 'End Date cannot be before the Start Date',
                message: message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
        else{
            if(isValid === true && ArraySize === true){
                this.showLoading = !this.showLoading;
                //console.log('this.productList  ===  ---- >  '+JSON.stringify(this.productList));
                saveProductList({oppId:this.recordId,prodList:this.productList})
                .then(result => {
                    this.ShowModal = false;
                    this.showList = true;
                    this.showLoading = !this.showLoading;
                    //window.location.reload();
                    eval("$A.get('e.force:refreshView').fire();");
                    this.template.querySelector("c-opportunity-product-list").refreshList();
                })
                .catch(error => {
        
                    this.showLoading = !this.showLoading;
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant : 'error'
                    });
                    this.dispatchEvent(event);
                    
                });
            }
            else{
                if(ArraySize === false){
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Please Add new Product',
                        variant : 'warning'
                    });
                    this.dispatchEvent(event);
                }
            }
        }
        
    }

    hanldeselectedproducts(event){
        this.selectedProducts = event.detail;
        
        const recordid = this.recordId;
        this.template.querySelector("c-opportunity-product-editable-list").handlePrductIdsChange(this.selectedProducts);
   }

   recordsCountUpdate (event){
       this.recordsCount = event.detail.recordsCount;
       if(this.recordsCount === 0){
           this.showList = false;
       }
   }
}