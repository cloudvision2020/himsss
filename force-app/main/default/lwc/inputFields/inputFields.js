import { LightningElement,track,api,wire } from 'lwc';
import {
    getPicklistValues
} from "lightning/uiObjectInfoApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/OpportunityLineItem';
import opportunityRecordType_HIMSS_North_America_Corp_Membership from '@salesforce/label/c.OpportunityRecordType_HIMSS_North_America_Corp_Membership';
import opportunityRecordType_HIMSS_North_America_Sales from '@salesforce/label/c.OpportunityRecordType_HIMSS_North_America_Sales';
import opportunityRecordType_HIMSS_HGP from '@salesforce/label/c.OpportunityRecordType_HIMSS_HGP';
import opportunityRecordType_HIMSS_PCHA from '@salesforce/label/c.OpportunityRecordType_HIMSS_PCHA';
const FIELD_TYPE_MAP = {
    STRING: "text",
    EMAIL: "email",
    PHONE: "phone",
    PICKLIST: "picklist",
    DATE: "date",
    TEXTAREA: "textarea",
    BOOLEAN: "checkbox",
    boolean: "checkbox",
    FORMULA: "text",
    CURRENCY:"number"
};
export default class InputFields extends LightningElement {
    //our copy of field
    @track _field;

    //field type to render the input field correctly
    @track fieldType;
    @track placeholderText;
    //field api name
    @track fieldApiName;
    @track picklistData;
    //keep track of which type of field to use
    isLightningInput = false;
    isCurrency = false;
    isPicklist = false;
    picklistHasData = false;
    isLookup = false;
    isCheckbox = false;

    //track options for picklist
    @api options=[];
    @track type;
    @track checkboxValue = false;
    @track domId = '';
    @track disablePicklist=false;
    selector = '';
    @api prodid;
    @api recordtypename;
    @api get field() {
        return this._field;
    }
    set field(value) {
        
        this._field = value;
        //console.log(value,this._field.fieldType+' '+ this._field.fieldApiName);
        if (
            FIELD_TYPE_MAP[this._field.fieldType] !== undefined &&
            FIELD_TYPE_MAP[this._field.fieldType] !== null
        ) {
            this.fieldType = FIELD_TYPE_MAP[this._field.fieldType];
        } else {
            this.fieldType = this._field.fieldType;
        }
        //set the object + field name value for picklist retrieval
        this.fieldApiName = "OpportunityLineItem." + value.fieldName;
    
        if (
            value.fieldType === "picklist" || value.fieldType === "PICKLIST" ||
            FIELD_TYPE_MAP[value.type] === "picklist"
        ) {
            this.isPicklist = true;
            this.selector = 'lightning-combobox';
        } else if (
            value.fieldType === "REFERENCE" ||
            FIELD_TYPE_MAP[value.fieldType] === "REFERENCE"
        ) {
            this.isLookup = true;
            this.selector = 'c-custom-lookup';
        } else if (
            value.fieldType === "checkbox" ||
            FIELD_TYPE_MAP[value.fieldType] === "checkbox"
        ) {
            this.isCheckbox = true;
            this.selector = 'lightning-input'; 
        } else if (
            value.fieldType === "CURRENCY" ||
            FIELD_TYPE_MAP[value.fieldType] === "currency"
        )  {
            //console.log('In currency');
            this.isCurrency = true;
            this.selector = 'lightning-input';
        }
        else {
            this.isLightningInput = true;
            this.selector = 'lightning-input';
            if (value.fieldType === "date" || FIELD_TYPE_MAP[value.fieldType] === "date") {
                this.placeholderText = "MM/DD/YYYY";
            }
        }
    }
    @api recordId;
    @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
    objectInfo;
    
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: '$fieldApiName'
    })
    setPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.picklistData = data;
           
            if(this.recordtypename === opportunityRecordType_HIMSS_North_America_Corp_Membership || this.recordtypename === opportunityRecordType_HIMSS_North_America_Sales
            || this.recordtypename === opportunityRecordType_HIMSS_HGP){

                this.options.push({label:'--None--',value:''});
                data.values.forEach(row=>{
                    if(row.label === 'Upgrade' || row.label === 'Downgrade' ||
                    row.label === 'New' || row.label === 'Renew' ){
                        
                        this.options.push(row);
                    }
                });
            }
            else if(this.recordtypename === opportunityRecordType_HIMSS_PCHA){
                this.options.push({label:'--None--',value:''});
                data.values.forEach(row=>{
                    if(row.label === 'Renew' || row.label === 'Join' ||
                    row.label === 'Re-Join'){
                        
                        this.options.push(row);
                        
                    }
                });
            }
            else{
               
                
                if(this._field.controllingField !== "" && this._field.controllingFieldValue !==''){
                    this.options.push({label:'--None--',value:''});
                    let key = this.picklistData.controllerValues[this._field.controllingFieldValue];
                    let typeFieldOption=[];
                    typeFieldOption.push({label:'---None---',value:''});
                    let setTypeFieldOption = this.picklistData.values.filter(opt => opt.validFor.includes(key));
                    setTypeFieldOption.forEach(element=>{
                        typeFieldOption.push(element);
                    });
                    
                    this.options = typeFieldOption;
                } 
                else if(this._field.controllingField !== "" && this._field.controllingFieldValue==='' && this._field.controllingField !=='Product_Sub_Type__c'){
                    
                }
                else{
                    this.options.push({label:'--None--',value:''});
                    var isExist=false;
                    data.values.forEach(row=>{
                      
                        if (this.field.fieldValue===undefined ||  row.value===this.field.fieldValue)
                        {                            
                            isExist=true;
                        } 
                        this.options.push(row);
                     });
                     
                     if (isExist===false)
                     {
                        var newField = {...this._field};
                        newField.fieldValue=''; 
                        this.field=newField;
                        const prodId = this.prodid;
                        const fieldchangeEvent = new CustomEvent("typechange", {
                            detail: {
                                name: this.field.fieldName,
                                type: this.field.fieldType,
                                value: null,
                                title: this.field.fieldValue,
                                Key: prodId
                            }
                        });
                        this.dispatchEvent(fieldchangeEvent);
                     }
                }
                
                          
            }
            
            if(this._field.controllingField !== ""){
                this.disablePicklist = true;
            }
            this.picklistHasData = true;
        
        }
    }
    @api handlePicklistDependency(value){
       
        this.disablePicklist = false;
        
        let key = this.picklistData.controllerValues[value];
        
        let typeFieldOption=[];
        typeFieldOption.push({label:'---None---',value:''});
        let setTypeFieldOption = this.picklistData.values.filter(opt => opt.validFor.includes(key));
        
        setTypeFieldOption.forEach(element=>{
            typeFieldOption.push(element);
        });
       
        this.options = typeFieldOption;
        
    }

    @api checkValidation(){
        var isValid = true;
        var elem = this.template.querySelector("lightning-input");
        if(elem != null){
            if (elem.checkValidity())
        {
            isValid=true;
        }
        else
        {
            isValid=false;
        }
        elem.reportValidity();
        } 
        var elem1 = this.template.querySelector("lightning-combobox");
        if(elem1 != null){
            if (elem1.checkValidity())
        {
            isValid=true;
        }
        else
        {
            isValid=false;
        }
        elem1.reportValidity();
        } 
        return isValid;
    }

    
    
    handleInputChange(event) {
        let value;
        const prodId = this.prodid;
        if (this.fieldType === "checkbox") {
            value = event.target.checked;
        } else {
            value = event.target.value;
        }

        const fieldchangeEvent = new CustomEvent("fieldchange", {
            detail: {
                name: event.target.name,
                type: event.target.type,
                value: value,
                title: event.target.title,
                Key: prodId
            }
        });


        this.dispatchEvent(fieldchangeEvent);
    }
    handlePicklistChange(event) {
        const prodId = this.prodid;
        var details = {
            detail: {
                name: this._field.fieldName,
                type: this._field.type,
                value: event.detail.value,
                title: this.title,
                Key: prodId
            }
        };
        const fieldchangeEvent = new CustomEvent("fieldchange", details);
        this.dispatchEvent(fieldchangeEvent);
    }
    
}