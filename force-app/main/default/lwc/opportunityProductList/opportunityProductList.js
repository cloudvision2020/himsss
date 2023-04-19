import { LightningElement,track,wire,api } from 'lwc';
import getProductList from '@salesforce/apex/OpportunityProductList_c.getProductList';
import deleteProduct from '@salesforce/apex/OpportunityProductList_c.deleteProduct';
import On_Hover_Red_Light from '@salesforce/label/c.On_Hover_Red_Light';
import On_Hover_Geen_Light from '@salesforce/label/c.On_Hover_Geen_Light';
import On_Hover_Greyed_out_OLI_on_modal from '@salesforce/label/c.On_Hover_Greyed_out_OLI_on_modal';
import On_Hover_Indicator_Flag from '@salesforce/label/c.On_Hover_Indicator_Flag';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import opportunityRecordType_HIMSS_Media from '@salesforce/label/c.OpportunityRecordType_HIMSS_Media';

export default class OpportunityProductList extends LightningElement {
    @api recordid;
    @track columns = [];
    @track productdata=[];
    @track isData = false;
    @track sortDirection;
    @track sortBy;
    @api showLoading = false;
    @api contractstatus;
    

    connectedCallback(){
        this.refreshData();
        
    }

    refreshData(){
        getProductList({oppId:this.recordid, sObjectName : 'OpportunityLineItem'})
        .then(result => {
            
            var conts = result.mapFieldLabelWithType;
            var tableColumns = [];
            var fieldNameList =[];
            this.showLoading = false;
            tableColumns.push({
                label: 'Action',
                type: 'button-icon',
                initialWidth: 65,
                typeAttributes: {
                    
                    iconName: {fieldName : 'deleteButton'},
                    title: {fieldName: 'deleteHover'},//'Delete',
                    variant: 'border-filled',
                    alternativeText: 'Delete',
                    disabled: {fieldName: 'disabledValue'}
                }
            });
                if(result.recordTypeName === opportunityRecordType_HIMSS_Media){
                    tableColumns.push({
                        fieldName: '',
                        label: '',
                        type: 'button-icon',
                        initialWidth : 50,
                        typeAttributes: {
                        
                            iconName: {fieldName : 'dynamicIcon'},
                            title: {fieldName: 'dynamicIconHover'},//'Delete',
                            variant:'container',
                            
                        },
                        cellAttributes: {
                            class:{fieldName: 'showClass'} }
                    });
                    
                    for(var i=0;i<result.products.length;i++){
                    
                        if(result.products[i].Product2.IsActive === false){
                        
                            tableColumns.push({
                                fieldName: '',
                                label: '',
                                type: 'button-icon',
                                initialWidth : 50,
                                typeAttributes: {
                                    
                                    iconName: {fieldName : 'dynamicIconFlag'},
                                    title: {fieldName: 'flagHover'},//'Delete',
                                    variant:'container',
                                    
                                },
                                cellAttributes: {
                                    class:'slds-icon-text-error'
                                    }
                            });
                            break;
                        }
                    }
                }
                
                tableColumns.push({
                    label: 'Product Name',
                    fieldName: 'nameUrl',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'ProductName' },
                     
                    },
                    cellAttributes: {
                        class:'slds-text-color_error'
                    },
                    sortable: true
                });
            
            var percentFields =[];
            for(var a in conts){
                var dataType = conts[a].toLowerCase();
                if(dataType === 'date'){
                    dataType = 'date-local'; 
                }
                if(dataType === 'percent'){
                    percentFields.push(result.mapFieldLabelWithApi[a]);
                }
                tableColumns.push({label: a, fieldName: result.mapFieldLabelWithApi[a],type:dataType,cellAttributes:{style:'color:red;'}, sortable : 'true'});
                fieldNameList.push(result.mapFieldLabelWithApi[a]);
            }
            let currentData = [];
                var indexNo = 0;
                //Updating records count
                var recordsDetail = {recordsCount:result.products.length};
                const selectedEvent = new CustomEvent('recordscountupdate', { detail: recordsDetail });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);

                result.products.forEach(row => {
                    let rowdata={};
                    fieldNameList.push('Id');
                    for(var i=0;i<fieldNameList.length;i++){
                        if(fieldNameList[i].indexOf('.') !== -1){
                            
                            var splitString = fieldNameList[i].split('.');
                            
                            rowdata[fieldNameList[i]] = row[splitString[0]][splitString[1]];
                        }
                        else{
                            
                            if(percentFields.includes(fieldNameList[i])){
                                rowdata[fieldNameList[i]] = row[fieldNameList[i]]/100;
                            }
                            else{
                                rowdata[fieldNameList[i]] = row[fieldNameList[i]];
                            }
                            
                        } 
                    }
                    rowdata['nameUrl'] = '/' + row['Id'];
                    rowdata['ProductName'] = row['Product2']['Name'];
                    rowdata['index'] = indexNo;



                    if(result.recordTypeName === opportunityRecordType_HIMSS_Media){
                        var today = new Date();
                        var dd = today.getDate();
                        var mm = today.getMonth()+1; //As January is 0.
                        var yyyy = today.getFullYear();
        
                        if(dd<10) dd='0'+dd;
                        if(mm<10) mm='0'+mm;
                        var todayDate = (yyyy+'-'+mm+'-'+dd);
                        
                            if(this.contractstatus === 'Activated' && row.End_Date__c < todayDate
                            && row.Contract_Line_Item__c ){
                            
                                rowdata['deleteButton'] = 'utility:delete';
                                rowdata['disabledValue'] = true;
                                rowdata['deleteHover'] = On_Hover_Greyed_out_OLI_on_modal;
                            }
                            else{
                                rowdata['deleteButton'] = 'utility:delete';
                                rowdata['deleteHover'] = 'Delete';
                            }
                        
                    }
                    else{
                        rowdata['deleteButton'] = 'utility:delete';
                        rowdata['deleteHover'] = 'Delete';
                    }



                    
                    if(row.Contract_Line_Item__c){
                        rowdata['showClass'] = (row.Contract_Line_Item__c !== null ? 'greencolor' : 'redcolor');
                        rowdata['dynamicIcon'] = 'action:approval';
                        rowdata['dynamicIconHover'] = On_Hover_Geen_Light;
                    }
                    else{
                        rowdata['showClass'] = (row.Contract_Line_Item__c === null ? 'redcolor' : 'greencolor');
                        rowdata['dynamicIcon'] = 'utility:error';
                        rowdata['dynamicIconHover'] =On_Hover_Red_Light;
                    }
                    
                    if(row.Product2.IsActive === false){
                        rowdata['dynamicIconFlag'] = 'utility:priority';
                        rowdata['flagHover'] = On_Hover_Indicator_Flag;
                        
                    }
                    rowdata['fillcolor'] = "fillcolor";
                    
                    currentData.push(rowdata);
                    indexNo ++;
                }); 
            
            this.columns = tableColumns;
        
            this.productdata = currentData;
            if(this.productdata.length > 0){
                this.isData = true;
            }
            else{
                this.isData = false;
            }
        })
        .catch(error => {
            console.log('error-->' , error);
        });
        
    }
    @api refreshList(){
        this.refreshData();
        this.showLoading = !this.showLoading;
    }
    // Row Action event to show the details of the record
    handleRowAction(event) {
        if(event.detail.action.title.fieldName === 'deleteHover'){
            this.showLoading = !this.showLoading;
            const row = event.detail.row;
                        
            try{
                var rowIndex = parseInt(row.index);
                
                    this.deleteRow(row.Id, row);
                
                
            }catch(excp){
                console.log('exp-->' + excp);
            }
        }
    }

    deleteRow(rowId, row){
        var rowDelete; 
        deleteProduct({oppId :this.recordid, rowId :rowId})
        .then(result => {
            //rowDelete =JSON.stringify(result);
            console.log('Result  --- > '+result);
            if(result === 'Deleted'){
                this.refreshData();
                eval("$A.get('e.force:refreshView').fire();");
            }
            else{
                this.showLoading = !this.showLoading;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: 'Active Contract in place, can not make changes/delete this line item as end date is in the past',
                        variant: 'error'
                    })
                );    
            }            
        })
        .catch(error => {
            this.showLoading = !this.showLoading;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
        /*
        console.log('rowDelete ---- >>> '+rowDelete);
        if(rowDelete === 'Delete'){
            deleteRecord(rowId)
                .then(() => {
                    this.refreshData();
                    eval("$A.get('e.force:refreshView').fire();");
                    
                
                })
                .catch(error => {
                    this.showLoading = !this.showLoading;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error deleting record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: 'Active contact not Delete',
                    variant: 'error'
                })
            );

        }
        */
    }

    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.productdata));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.productdata = [...parseData];

    }
}