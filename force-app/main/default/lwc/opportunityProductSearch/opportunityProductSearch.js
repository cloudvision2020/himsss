import { LightningElement,track,api,wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import FAMILY_FIELD from '@salesforce/schema/Product2.Family';
import REGION_FIELD from '@salesforce/schema/Product2.Region__c';
import TYPE_FIELD from '@salesforce/schema/Product2.Type__c';
import SUBTYPE_FIELD from '@salesforce/schema/Product2.Sub_Type__c';
import getProductList from '@salesforce/apex/OpportunityProductSearch_c.getProductList';
import getCoulmnNames from '@salesforce/apex/OpportunityProductSearch_c.getCoulmnNames';

export default class OpportunityProductSearch extends LightningElement {
    @api recordid;
    @track selectedProduct;
    @track familyFieldData=[];
    @track regionFieldData=[];
    @track subtypeFieldData;
    @track typeFieldData;
    @track typeFieldOption = [];
    @track subtypeFieldOption = [];
    @track productFamilyValue;
    @track productRegionValue;
    @track typeValue;
    @track subtypeValue;
    @track productNameValue;
    @track searchProductsList=[];
    @track searchProductsCoulmns = [];
    @track showTypeField = false;
    @track showSubtypeField = false;
    @track fieldNameList =[];

    get rowsHasData(){

        if(this.searchProductsList.length > 0){
        
            return true;
        }
    }

    @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
    objectInfo;

    
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: FAMILY_FIELD})
    getFamilyPicklist({ data, error }) {
        if (data){
        
            let familyFieldData=[];
            familyFieldData.push({label:'---None---',value:'---None---'});
            data.values.forEach(element => {
                familyFieldData.push(element);
            });
            this.familyFieldData = familyFieldData;
        }
        if(error){
            console.log('error-->' + error);
        }
    }
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: REGION_FIELD})
    getRegionPicklist({ data, error }) {
        if (data){

            let regionFieldData=[];
            data.values.forEach(element => {
                regionFieldData.push(element);
            });
            this.regionFieldData = regionFieldData;
        } 
        if(error){
            console.log('error-->' + error);
        }  
    }

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD})
    getTypePicklist({ data, error }) {
        if (data){
            this.typeFieldData = data;
        }
        if(error){
            console.log('error-->' + JSON.stringify(error));
            console.log('error-->' + JSON.stringify(TYPE_FIELD));
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SUBTYPE_FIELD})
    getSubtypePicklist({ data, error }) {
        if (data){
            this.subtypeFieldData = data;
        }
        if(error){
            console.log('error-->' + JSON.stringify(error));
        }
    }

    connectedCallback(){
        getCoulmnNames({oppId:this.recordid,sObjectName:'Product2'})
        .then(result => {
            var conts = result.mapFieldLabelWithType;
            var tableColumns = [];
            tableColumns.push({
                label: 'Action', fieldName: 'Action',type: "button",
                fixedWidth: 150,
                typeAttributes: {
                    label: 'Add',
                    title: 'Add',
                    name: 'Add',
                    value: 'Add',
                    variant: 'base',
                    class: 'scaled-down',
                }
            });
            for(var a in conts){
                var dataType = conts[a].toLowerCase();
                tableColumns.push({label: a, fieldName: result.mapFieldLabelWithApi[a],type:dataType,
                wrapText:true});
                this.fieldNameList.push(result.mapFieldLabelWithApi[a]);
            }
            this.searchProductsCoulmns = tableColumns;
        })
        .catch(error => {
            console.log('error-->' + JSON.stringify(error));
            console.log('error-->' + error);
        });

        this.productRegionValue = 'North America';
        this.getProductListonLoad();
    
    }

    getProductListonLoad(){
        var recordId = this.recordid;
        
        getProductList({
            oppId: recordId,
            productFamilyValue: this.productFamilyValue,
            typeValue: this.typeValue,
            subtypeValue: this.subtypeValue,
            productNameValue: this.productNameValue,
            productRegionValue : this.productRegionValue
        })
        .then(result => { 
            
            this.setTableData(result);
            
        })
        .catch(error => {
            console.log('error on load change field-->' + JSON.stringify(error));
            console.log('error-->' + error);
        });
    }

    handleClear(){
        this.searchProductsList=[];
        this.productFamilyValue='';
        this.productRegionValue = '';
        this.typeValue='';
        this.subtypeValue='';
        this.productNameValue='';
        this.subtypeFieldOption = [];
        this.typeFieldOption=[];
        this.showTypeField = false;
        this.showSubtypeField = false;
    }

    handelAddClick(event){
        const row = event.detail.row;
        this.selectedProduct = row;
        const selectedEvent = new CustomEvent("selectedproducts", {
            detail: this.selectedProduct
          });
          this.dispatchEvent(selectedEvent);
    }
    handleRegionChange(event){
         this.productRegionValue = event.target.value;
         var recordId = this.recordid;
        
        getProductList({
            oppId: recordId,
            productFamilyValue: this.productFamilyValue,
            typeValue: this.typeValue,
            subtypeValue: this.subtypeValue,
            productNameValue: this.productNameValue,
            productRegionValue : this.productRegionValue
        })
        .then(result => { 
           
            this.setTableData(result);
            
        })
        .catch(error => {
            console.log('error in field change-->' + JSON.stringify(error));
            console.log('error-->' + error);
        });

    }
    handleFamilyFieldChange(event){
        
        this.subtypeFieldOption = [];
        this.typeFieldOption=[];
        this.typeValue='';
        this.subtypeValue='';
        this.productFamilyValue = event.target.value;
        let key = this.typeFieldData.controllerValues[event.target.value];
        let typeFieldOption=[];
        typeFieldOption.push({label:'---None---',value:'---None---'});
        let setTypeFieldOption = this.typeFieldData.values.filter(opt => opt.validFor.includes(key));
        setTypeFieldOption.forEach(element=>{
            typeFieldOption.push(element);
        });
        this.typeFieldOption = typeFieldOption;
        if(this.typeFieldOption.length > 0 && this.productFamilyValue !== '---None---'){
            this.showTypeField = true;
        }
        else{
            this.showTypeField = false;
        }
        if(this.subtypeFieldOption.length > 0){
            this.showSubtypeField = true;
        }
        else{
            this.showSubtypeField = false;
        }
        if(this.productFamilyValue === '---None---'){
            this.productFamilyValue=''
        }

        getProductList({
            oppId:this.recordid,
            productFamilyValue: this.productFamilyValue,
            typeValue: this.typeValue,
            subtypeValue: this.subtypeValue,
            productNameValue: this.productNameValue,
            productRegionValue : this.productRegionValue
        })
        .then(result => { 
            
            this.setTableData(result);
            
        })
        .catch(error => {
            console.log('error-->' + JSON.stringify(error));
            console.log('error-->' + error);
        });
    
    }

    handleTypeFieldChange(event){
        this.subtypeFieldOption=[];
        this.typeValue = event.target.value;
        let key = this.subtypeFieldData.controllerValues[event.target.value];
        let subtypeFieldOption=[];
        subtypeFieldOption.push({label:'---None---',value:'---None---'})
        let setSubtypeFieldOption = this.subtypeFieldData.values.filter(opt => opt.validFor.includes(key));
        setSubtypeFieldOption.forEach(element=>{
            subtypeFieldOption.push(element);
        });
        this.subtypeFieldOption = subtypeFieldOption;
    
        if(this.subtypeFieldOption.length > 0 && this.typeValue !== '---None---'){
            this.showSubtypeField = true;
        }
        else{
            this.showSubtypeField = false;
        }
        if(this.typeValue === '---None---'){
            this.typeValue = '';
        }
        getProductList({
            oppId:this.recordid,
            productFamilyValue: this.productFamilyValue,
            typeValue: this.typeValue,
            subtypeValue: this.subtypeValue,
            productNameValue: this.productNameValue,
            productRegionValue : this.productRegionValue
        })
        .then(result => { 
            this.setTableData(result);
        })
        .catch(error => {
            console.log('error-->' + JSON.stringify(error));
            console.log('error-->' + error);
        });
    }

    setTableData(result)
    {
        let currentData = [];
            
        result.forEach(row => {
            let rowdata={};
            rowdata.Id = row.Id;
            for(var i=0;i<this.fieldNameList.length;i++){
                if(this.fieldNameList[i].indexOf('.') !== -1){
                    var splitString = this.fieldNameList[i].split('.');
                    rowdata[this.fieldNameList[i]] = row[splitString[0]][splitString[1]];
                }
                else{
                    rowdata[this.fieldNameList[i]] = row[this.fieldNameList[i]];
                } 
            }
            currentData.push(row);
        }); 
           
            this.searchProductsList = currentData;
       
    
    }

    handleSubTypeFieldChange(event){
        this.subtypeValue = event.target.value;
        if(this.subtypeValue === '---None---'){
            this.subtypeValue = '';
        }
        getProductList({
            oppId:this.recordid,
            productFamilyValue: this.productFamilyValue,
            typeValue: this.typeValue,
            subtypeValue: this.subtypeValue,
            productNameValue: this.productNameValue,
            productRegionValue : this.productRegionValue
        })
        .then(result => { 
            this.setTableData(result);
            
        })
        .catch(error => {
            console.log('error-->' + JSON.stringify(error));
            console.log('error-->' + error);
        });
    }

    productNameChange(event){
        this.productNameValue = event.target.value;
        getProductList({
            oppId:this.recordid,
            productFamilyValue: this.productFamilyValue,
            typeValue: this.typeValue,
            subtypeValue: this.subtypeValue,
            productNameValue: this.productNameValue,
            productRegionValue : this.productRegionValue
        })
        .then(result => { 
            this.setTableData(result);
           
        })
        .catch(error => {
            console.log('error-->' + JSON.stringify(error));
            console.log('error-->' + error);
        });
    }
}