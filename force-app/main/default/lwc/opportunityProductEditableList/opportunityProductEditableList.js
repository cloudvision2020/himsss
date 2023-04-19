import { LightningElement, api, track } from "lwc";
import getProductList from "@salesforce/apex/OpportunityProductEditableList_c.getProductList";
import getCoulmnNames from "@salesforce/apex/OpportunityProductEditableList_c.getCoulmnNames";
import { deleteRecord } from "lightning/uiRecordApi";
import opportunityRecordType_HIMSS_Analytics_Provider from "@salesforce/label/c.OpportunityRecordType_HIMSS_Analytics_Provider";
import opportunityRecordType_HIMSS_Analytics_Vendor from "@salesforce/label/c.OpportunityRecordType_HIMSS_Analytics_Vendor";
import opportunityRecordType_HIMSS_Analytics_Reseller from "@salesforce/label/c.OpportunityRecordType_HIMSS_Analytics_Reseller";
import opportunityRecordType_HIMSS_North_America_Corp_Membership from "@salesforce/label/c.OpportunityRecordType_HIMSS_North_America_Corp_Membership";
import opportunityRecordType_HIMSS_North_America_Sales from "@salesforce/label/c.OpportunityRecordType_HIMSS_North_America_Sales";
import opportunityRecordType_HIMSS_PCHA from "@salesforce/label/c.OpportunityRecordType_HIMSS_PCHA";
import opportunityRecordType_HIMSS_Media from "@salesforce/label/c.OpportunityRecordType_HIMSS_Media";
import opportunityRecordType_HIMSS_International from "@salesforce/label/c.OpportunityRecordType_HIMSS_International";
import opportunityRecordType_HIMSS_HGP from "@salesforce/label/c.OpportunityRecordType_HIMSS_HGP";
import opportunityRecordType_HBX_Consulting from "@salesforce/label/c.OpportunityRecordType_HBX_Consulting";
import opportunityRecordType_HBX_DaVita_Investing from "@salesforce/label/c.OpportunityRecordType_HBX_DaVita_Investing";
import opportunityRecordType_HBX_Innovation_Fund from "@salesforce/label/c.OpportunityRecordType_HBX_Innovation_Fund";
import opportunityRecordType_HIMSS_HA from "@salesforce/label/c.OpportunityRecordType_HIMSS_HA";

export default class OpportunityProductEditableList extends LightningElement {
    @api recordid;
    @api contractstatus;
    @track recordTypeName;
    @track prductRecords = [];
    @track initialPrductRecords = [];
    @track coulmnNames = [];
    @track showList = false;
    @track newRecord;
    @api coulmnnamesresult = [];
    @track showLoading = false;

    connectedCallback() {
        this.showLoading = true;
        this.newRecord = this.coulmnnamesresult;
        this.recordTypeName = this.coulmnnamesresult.recordTypeName;
        this.coulmnnamesresult.fileDetailWrapper.forEach((element) => {
            if (element.isVisible === true) {
                this.coulmnNames.push({ fieldName: element.fieldName, fieldLabel: element.fieldLabel });
            }
        });
        console.log("connected:", this.coulmnnamesresult);
        /*getCoulmnNames({ oppId: this.recordid })
            .then(result => {
                this.newRecord = result;
                this.recordTypeName = result.recordTypeName;
                result.fileDetailWrapper.forEach(element => {
                    if (element.isVisible === true) {
                        this.coulmnNames.push({ fieldName: element.fieldName, fieldLabel: element.fieldLabel });
                    }

                });
            })
            .catch(error => {
                console.log('error-->' + JSON.stringify(error));
            });*/

        getProductList({ oppId: this.recordid, productIds: null, sObjectName: "OpportunityLineItem" })
            .then((result) => {
                this.prductRecords = result;
                console.log("ProductList:", this.prductRecords);
                this.initialPrductRecords = result;
                if (this.prductRecords.length > 0) {
                    this.showList = true;
                }
                this.showLoading = false;
                const resultCompletevent = new CustomEvent("resultcompletevent", {
                    detail: this.prductRecords
                });
                this.dispatchEvent(resultCompletevent);
            })
            .catch((error) => {
                this.showLoading = false;
                const resultCompletevent = new CustomEvent("resultcompletevent", {
                    detail: this.prductRecords
                });
                this.dispatchEvent(resultCompletevent);
                console.log("error-->" + JSON.stringify(error));
            });
    }
    handleSubTypeChange(event) {
        this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
            if (row.fieldName === event.detail.name) {
                row.fieldValue = event.detail.value;
            }
            if (row.controllingField === event.detail.name && event.detail.name === "Product_Sub_Type__c") {
                row.isEditable = false;
            }
        });
    }
    handleFieldChange(event) {
        this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
            if (row.fieldName === event.detail.name) {
                row.fieldValue = event.detail.value;
            }
        });

        if (event.detail.name === "HA_Reseller_Annual_Healthcare_Revenue__c") {
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (
                    row.fieldName === "HA_List_Price__c" ||
                    row.fieldName === "HA_Standard_Reseller_Discount_Amount__c" ||
                    row.fieldName === "HA_Price__c"
                ) {
                    row.fieldValue = null;
                }
            });
        }
        if (event.detail.name === "HA_Co_Healthcare_Prov_Rev_Gross_An__c") {
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (
                    row.fieldName === "HA_List_Price_Based_on_Gross_Annual__c" ||
                    row.fieldName === "HA_Sales_Price__c"
                ) {
                    row.fieldValue = null;
                }
            });
        }
        this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((ele) => {
            if (ele.controllingField !== "" && ele.controllingField === event.detail.name) {
                var dependentField = ele.fieldName;
                this.template.querySelectorAll("c-input-fields").forEach((element) => {
                    if (element.prodid === event.detail.Key && element.field.fieldName === dependentField) {
                        ele.isEditable = true;
                        element.handlePicklistDependency(event.detail.value);
                    }
                });
            }
        });

        if (this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HIMSS_Analytics_Provider) {
            console.log("settingValueForHA1");
            this.setValuesForAnalyticsProvider(event);
        }
        if (this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HIMSS_HA) {
            console.log("settingValueForHA");
            //done
            this.setValuesForHA(event);
        }
        if (this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HIMSS_Analytics_Vendor) {
            console.log("settingValueForHAVendor");
            this.setValuesForAnalyticsVendor(event);
        }
        if (this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HIMSS_Analytics_Reseller) {
            console.log("settingValueForHAReseller");
            this.setValuesForAnalyticsReseller(event);
        }
        if (
            this.prductRecords[event.detail.Key].recordTypeName ===
                opportunityRecordType_HIMSS_North_America_Corp_Membership ||
            this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HIMSS_North_America_Sales
        ) {
            this.setValuesForNA(event);
        }
        if (this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HIMSS_PCHA) {
            this.setValuesForPCHA(event);
        }
        if (this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HIMSS_Media) {
            this.setValuesForMedia(event);
        }
        if (
            this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HIMSS_International ||
            this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HIMSS_HGP ||
            this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HBX_Consulting ||
            this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HBX_DaVita_Investing ||
            this.prductRecords[event.detail.Key].recordTypeName === opportunityRecordType_HBX_Innovation_Fund
        ) {
            this.setValuesForOtherBu(event);
        }

        if (this.recordTypeName === opportunityRecordType_HIMSS_Media) {
            var productSubTypeValue;
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row.fieldName === "TotalPrice" && row.fieldValue === 0) {
                    this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((ele) => {
                        if (ele.fieldName === "Make_Good_Value_Add__c") {
                            ele.isRequired = true;
                        }
                    });
                }
                if (row.fieldName === "TotalPrice" && row.fieldValue > 0) {
                    this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((ele) => {
                        if (ele.fieldName === "Make_Good_Value_Add__c") {
                            ele.isRequired = false;
                        }
                    });
                }
                if (row.pType === "Global Conference") {
                    this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((ele) => {
                        if (ele.fieldName === "Global_Conference_Timing__c") {
                            ele.isRequired = true;
                        }
                    });
                }
                if (row.fieldName === "Product_Sub_Type__c") {
                    productSubTypeValue = row.fieldValue;
                }
            });

            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((ele) => {
                if (ele.controllingField !== "" && ele.controllingField === "Product_Sub_Type__c") {
                    var dependentField = ele.fieldName;
                    this.template.querySelectorAll("c-input-fields").forEach((element) => {
                        if (element.prodid === event.detail.Key && element.field.fieldName === dependentField) {
                            console.log("calll handlePicklistDependency 2");
                            element.handlePicklistDependency(productSubTypeValue);
                        }
                    });
                }
            });
        }

        const saveRecords = new CustomEvent("saverecords", {
            detail: this.prductRecords
        });
        this.dispatchEvent(saveRecords);
    }

    setValuesForAnalyticsReseller(event) {
        var HA_Price__c_Value;
        var HA_Sales_Price__c_Value;
        var HA_Mgmt_Approved_Discount_Percent__c_Value;
        var HA_Multi_Year_3_Yr__c_Value;
        var HA_Additional_Cost__c_Value;
        var HA_Mgmt_Approved_Disc_Amount_Reseller__c_Value = 0;
        var HA_Total_Discount_Amount_Reseller__c_Value = 0;
        var HA_Standard_Reseller_Discount_Amount__c_Value = 0;
        var HA_Term_Yrs__c_Value;
        var TotalPrice_Value = 0;
        var HA_1_Yr_Rev__c_Value;
        let HA_List_Price__c_Value = 0;
        let basePrice = 0;

        console.log("eventDetailName");
        console.log(event.detail.name);
        if (
            event.detail.name === "HA_Price__c" ||
            event.detail.name === "HA_Sales_Price__c" ||
            event.detail.name === "HA_Mgmt_Approved_Discount_Percent__c" ||
            event.detail.name === "HA_Multi_Year_3_Yr__c" ||
            event.detail.name === "HA_Additional_Cost__c" ||
            event.detail.name === "HA_Term_Yrs__c"
        ) {
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row["fieldValue"] !== null) {
                    console.log("currentFieldName");
                    console.log(row.fieldName);
                    if (row.fieldName === "HA_Price__c") {
                        HA_Price__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Sales_Price__c") {
                        HA_Sales_Price__c_Value = row.fieldValue || 0;
                        if (HA_Sales_Price__c_Value != null && HA_Sales_Price__c_Value != "") {
                            basePrice = row.fieldValue;
                        }
                    }
                    if (row.fieldName === "HA_Mgmt_Approved_Discount_Percent__c") {
                        HA_Mgmt_Approved_Discount_Percent__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Multi_Year_3_Yr__c") {
                        HA_Multi_Year_3_Yr__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Additional_Cost__c") {
                        HA_Additional_Cost__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Term_Yrs__c") {
                        HA_Term_Yrs__c_Value = row.fieldValue;
                    }

                    if (row.fieldName == "ListPrice") {
                        HA_List_Price__c_Value = parseInt(row.fieldValue) || 0;
                        console.log("currentBPrice2");
                        console.log(basePrice);
                        if (basePrice == 0 || basePrice == null) {
                            basePrice = row.fieldValue;
                        }
                    }
                }
            });

            if (basePrice == null || basePrice == "") {
                basePrice = HA_List_Price__c_Value;
            }

            if (
                (HA_Sales_Price__c_Value === null || HA_Sales_Price__c_Value === undefined) &&
                HA_Price__c_Value !== null &&
                HA_Price__c_Value !== undefined
            ) {
                HA_Sales_Price__c_Value = HA_Price__c_Value.replace("$", "").replace(",", "");
            }

            if (
                HA_Mgmt_Approved_Discount_Percent__c_Value != null &&
                HA_Mgmt_Approved_Discount_Percent__c_Value != undefined &&
                HA_Sales_Price__c_Value != null &&
                HA_Sales_Price__c_Value != undefined
            ) {
                if (HA_Mgmt_Approved_Discount_Percent__c_Value > 0) {
                    HA_Mgmt_Approved_Disc_Amount_Reseller__c_Value =
                        (HA_Sales_Price__c_Value * HA_Mgmt_Approved_Discount_Percent__c_Value) / 100;
                } else {
                    HA_Mgmt_Approved_Disc_Amount_Reseller__c_Value = 0;
                }
            }

            HA_Total_Discount_Amount_Reseller__c_Value =
                parseFloat(HA_Standard_Reseller_Discount_Amount__c_Value) +
                parseFloat(HA_Mgmt_Approved_Disc_Amount_Reseller__c_Value);

            if (HA_Additional_Cost__c_Value === null || HA_Additional_Cost__c_Value === undefined) {
                HA_Additional_Cost__c_Value = 0;
            }

            if (HA_Sales_Price__c_Value !== null || HA_Sales_Price__c_Value !== undefined) {
                if (
                    HA_Multi_Year_3_Yr__c_Value !== null &&
                    HA_Multi_Year_3_Yr__c_Value !== undefined &&
                    HA_Multi_Year_3_Yr__c_Value === "Yes (3X)"
                ) {
                    TotalPrice_Value =
                        3 * (basePrice - HA_Mgmt_Approved_Disc_Amount_Reseller__c_Value) +
                        parseFloat(HA_Additional_Cost__c_Value);
                } else {
                    TotalPrice_Value =
                        basePrice -
                        HA_Mgmt_Approved_Disc_Amount_Reseller__c_Value +
                        parseFloat(HA_Additional_Cost__c_Value);
                }
            }

            if (
                TotalPrice_Value !== null &&
                TotalPrice_Value !== undefined &&
                HA_Term_Yrs__c_Value !== null &&
                HA_Term_Yrs__c_Value !== undefined
            ) {
                HA_1_Yr_Rev__c_Value = TotalPrice_Value / HA_Term_Yrs__c_Value;
            }

            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row.fieldName === "HA_Sales_Price__c" && HA_Sales_Price__c_Value !== undefined) {
                    row.fieldValue = HA_Sales_Price__c_Value;
                }
                if (
                    row.fieldName === "HA_Mgmt_Approved_Disc_Amount_Reseller__c" &&
                    HA_Mgmt_Approved_Disc_Amount_Reseller__c_Value !== undefined
                ) {
                    row.fieldValue = HA_Mgmt_Approved_Disc_Amount_Reseller__c_Value;
                }
                if (
                    row.fieldName === "HA_Total_Discount_Amount_Reseller__c" &&
                    HA_Total_Discount_Amount_Reseller__c_Value !== undefined
                ) {
                    row.fieldValue = HA_Total_Discount_Amount_Reseller__c_Value;
                }
                if (row.fieldName === "HA_Additional_Cost__c" && HA_Additional_Cost__c_Value !== undefined) {
                    row.fieldValue = HA_Additional_Cost__c_Value;
                }
                if (row.fieldName === "TotalPrice" && TotalPrice_Value !== undefined) {
                    row.fieldValue = TotalPrice_Value;
                }
                if (row.fieldName === "HA_1_Yr_Rev__c" && HA_1_Yr_Rev__c_Value !== undefined) {
                    row.fieldValue = HA_1_Yr_Rev__c_Value;
                }
            });
        }
    }
    setValuesForAnalyticsVendor(event) {
        var HA_Term_Yrs__c_Value;
        var HA_Sales_Price__c_Value;
        var HA_S_R_Disc__c_Value;
        var HA_Co_Healthcare_Prov_Rev_Gross_An__c_Value;
        var HA_List_Price_Based_on_Gross_Annual__c_Value;
        var HA_S_M_Disc__c_Value;
        var HA_M_Y_3_Y_M_D__c_Value;
        var HA_Disc__c_Value;
        var HA_Mgmt_Approved_Discount_Percent__c_Value;
        var HA_Additional_Cost__c_Value;
        var HA_S_R_D_Perc__c_Value;
        var HA_S_R_D_Amt__c_Value = 0;
        var HA_S_M_D_Perc__c_Value;
        var HA_S_M_D_Amt__c_Value = 0;
        var HA_P__c_Value;
        var HA_D_Amt__c_Value = 0;
        var HA_C_M_D_Perc__c_Value;
        var HA_C_M_D_Amt__c_Value = 0;
        var HA_Mgmt_Approved_Disc_Amount_Vendor__c_Value = 0;
        var HA_Total_Discount_Amount_Vendor__c_Value = 0;
        var HA_1_Yr_Rev__c_Value;
        var TotalPrice_Value = 0;
        var isValueChange = false;
        let HA_List_Price__c_Value = 0;
        let basePrice = 0;

        if (
            event.detail.name === "HA_Term_Yrs__c" ||
            event.detail.name === "HA_S_R_Disc__c" ||
            event.detail.name === "HA_List_Price_Based_on_Gross_Annual__c" ||
            event.detail.name === "HA_Sales_Price__c" ||
            event.detail.name === "HA_S_M_Disc__c" ||
            event.detail.name === "HA_M_Y_3_Y_M_D__c" ||
            event.detail.name === "HA_Disc__c" ||
            event.detail.name === "HA_Mgmt_Approved_Discount_Percent__c" ||
            event.detail.name === "HA_Additional_Cost__c"
        ) {
            if (event.detail.name === "HA_List_Price_Based_on_Gross_Annual__c") {
                isValueChange = true;
            }

            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row["fieldValue"] !== null) {
                    if (row.fieldName === "HA_Additional_Cost__c") {
                        HA_Additional_Cost__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Mgmt_Approved_Discount_Percent__c") {
                        HA_Mgmt_Approved_Discount_Percent__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Disc__c") {
                        HA_Disc__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_M_Y_3_Y_M_D__c") {
                        HA_M_Y_3_Y_M_D__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_S_M_Disc__c") {
                        HA_S_M_Disc__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Sales_Price__c") {
                        HA_Sales_Price__c_Value = row.fieldValue || 0;
                        if (HA_Sales_Price__c_Value != null && HA_Sales_Price__c_Value != "") {
                            basePrice = row.fieldValue;
                        }
                    }
                    if (row.fieldName === "HA_Term_Yrs__c") {
                        HA_Term_Yrs__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_S_R_Disc__c") {
                        HA_S_R_Disc__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Co_Healthcare_Prov_Rev_Gross_An__c") {
                        HA_Co_Healthcare_Prov_Rev_Gross_An__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_List_Price_Based_on_Gross_Annual__c") {
                        HA_List_Price_Based_on_Gross_Annual__c_Value = row.fieldValue;
                    }
                    if (row.fieldName == "ListPrice") {
                        HA_List_Price__c_Value = parseInt(row.fieldValue) || 0;
                        console.log("currentBPrice2");
                        console.log(basePrice);
                        if (basePrice == 0 || basePrice == null) {
                            basePrice = row.fieldValue;
                        }
                    }
                }
            });

            if (basePrice == null || basePrice == "") {
                basePrice = HA_List_Price__c_Value;
            }

            if (
                isValueChange === true &&
                HA_List_Price_Based_on_Gross_Annual__c_Value !== null &&
                HA_List_Price_Based_on_Gross_Annual__c_Value !== undefined
            ) {
                HA_Sales_Price__c_Value = HA_List_Price_Based_on_Gross_Annual__c_Value.replace("$", "").replace(
                    ",",
                    ""
                );
                isValueChange = false;
            }

            if (HA_S_R_Disc__c_Value !== null && HA_S_R_Disc__c_Value !== undefined) {
                for (var a in this.newRecord.mapHa_S_R_DiscountWithPercent) {
                    if (a === HA_S_R_Disc__c_Value) {
                        HA_S_R_D_Perc__c_Value = this.newRecord.mapHa_S_R_DiscountWithPercent[a];
                    }
                }
            }
            if (HA_S_M_Disc__c_Value !== null && HA_S_M_Disc__c_Value !== undefined) {
                for (var a in this.newRecord.mapHa_S_M_DiscountWithPercent) {
                    if (a === HA_S_M_Disc__c_Value) {
                        HA_S_M_D_Perc__c_Value = this.newRecord.mapHa_S_M_DiscountWithPercent[a];
                    }
                }
            }
            if (HA_M_Y_3_Y_M_D__c_Value !== null && HA_M_Y_3_Y_M_D__c_Value !== undefined) {
                for (var a in this.newRecord.mapHa_S_M_Y_3_DiscountWithPercent) {
                    if (a === HA_M_Y_3_Y_M_D__c_Value) {
                        HA_P__c_Value = this.newRecord.mapHa_S_M_Y_3_DiscountWithPercent[a];
                    }
                }
            }
            if (HA_Disc__c_Value !== null && HA_Disc__c_Value !== undefined) {
                for (var a in this.newRecord.mapHa_Vendor_DiscountWithPercent) {
                    if (a === HA_Disc__c_Value) {
                        HA_C_M_D_Perc__c_Value = this.newRecord.mapHa_Vendor_DiscountWithPercent[a];
                    }
                }
            }
            if (
                HA_Sales_Price__c_Value !== null &&
                HA_Sales_Price__c_Value !== undefined &&
                HA_S_R_D_Perc__c_Value !== null &&
                HA_S_R_D_Perc__c_Value !== undefined
            ) {
                HA_S_R_D_Amt__c_Value = (HA_Sales_Price__c_Value * HA_S_R_D_Perc__c_Value) / 100;
            }
            if (
                HA_Sales_Price__c_Value !== null &&
                HA_Sales_Price__c_Value !== undefined &&
                HA_S_M_D_Perc__c_Value !== null &&
                HA_S_M_D_Perc__c_Value !== undefined
            ) {
                HA_S_M_D_Amt__c_Value = (HA_Sales_Price__c_Value * HA_S_M_D_Perc__c_Value) / 100;
            }
            if (
                HA_Sales_Price__c_Value !== null &&
                HA_Sales_Price__c_Value !== undefined &&
                HA_P__c_Value !== null &&
                HA_P__c_Value !== undefined
            ) {
                HA_D_Amt__c_Value = (HA_Sales_Price__c_Value * HA_P__c_Value) / 100;
            }
            if (
                HA_Sales_Price__c_Value !== null &&
                HA_Sales_Price__c_Value !== undefined &&
                HA_C_M_D_Perc__c_Value !== null &&
                HA_C_M_D_Perc__c_Value !== undefined
            ) {
                HA_C_M_D_Amt__c_Value = (HA_Sales_Price__c_Value * HA_C_M_D_Perc__c_Value) / 100;
            }
            if (
                HA_Mgmt_Approved_Discount_Percent__c_Value !== null &&
                HA_Mgmt_Approved_Discount_Percent__c_Value !== undefined &&
                HA_Sales_Price__c_Value !== null &&
                HA_Sales_Price__c_Value !== undefined
            ) {
                if (HA_Mgmt_Approved_Discount_Percent__c_Value > 0) {
                    HA_Mgmt_Approved_Disc_Amount_Vendor__c_Value =
                        ((HA_Sales_Price__c_Value -
                            HA_S_R_D_Amt__c_Value -
                            HA_S_M_D_Amt__c_Value -
                            HA_D_Amt__c_Value -
                            HA_C_M_D_Amt__c_Value) *
                            HA_Mgmt_Approved_Discount_Percent__c_Value) /
                        100;
                } else {
                    HA_Mgmt_Approved_Disc_Amount_Vendor__c_Value = 0;
                }
            }
            HA_Total_Discount_Amount_Vendor__c_Value =
                parseFloat(HA_S_R_D_Amt__c_Value) +
                parseFloat(HA_S_M_D_Amt__c_Value) +
                parseFloat(HA_D_Amt__c_Value) +
                parseFloat(HA_C_M_D_Amt__c_Value) +
                parseFloat(HA_Mgmt_Approved_Disc_Amount_Vendor__c_Value);
            if (HA_Additional_Cost__c_Value === null || HA_Additional_Cost__c_Value === undefined) {
                HA_Additional_Cost__c_Value = 0;
            }
            if (HA_Sales_Price__c_Value !== null && HA_Sales_Price__c_Value !== undefined) {
                if (
                    HA_M_Y_3_Y_M_D__c_Value !== null &&
                    HA_M_Y_3_Y_M_D__c_Value !== undefined &&
                    HA_M_Y_3_Y_M_D__c_Value === "Yes"
                ) {
                    TotalPrice_Value =
                        3 * (basePrice - HA_Total_Discount_Amount_Vendor__c_Value) +
                        parseFloat(HA_Additional_Cost__c_Value);
                } else {
                    TotalPrice_Value =
                        basePrice - HA_Total_Discount_Amount_Vendor__c_Value + parseFloat(HA_Additional_Cost__c_Value);
                }
                if (
                    TotalPrice_Value !== null &&
                    TotalPrice_Value !== undefined &&
                    HA_Term_Yrs__c_Value !== null &&
                    HA_Term_Yrs__c_Value !== undefined
                ) {
                    HA_1_Yr_Rev__c_Value = TotalPrice_Value / HA_Term_Yrs__c_Value;
                }
            }
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row.fieldName === "HA_Sales_Price__c" && HA_Sales_Price__c_Value !== undefined) {
                    row.fieldValue = HA_Sales_Price__c_Value;
                }
                if (row.fieldName === "HA_S_R_D_Perc__c" && HA_S_R_D_Perc__c_Value !== undefined) {
                    row.fieldValue = HA_S_R_D_Perc__c_Value;
                }
                if (row.fieldName === "HA_S_R_D_Amt__c" && HA_S_R_D_Amt__c_Value !== undefined) {
                    row.fieldValue = HA_S_R_D_Amt__c_Value;
                }
                if (row.fieldName === "HA_S_M_D_Perc__c" && HA_S_M_D_Perc__c_Value !== undefined) {
                    row.fieldValue = HA_S_M_D_Perc__c_Value;
                }
                if (row.fieldName === "HA_S_M_D_Amt__c" && HA_S_M_D_Amt__c_Value !== undefined) {
                    row.fieldValue = HA_S_M_D_Amt__c_Value;
                }
                if (row.fieldName === "HA_P__c" && HA_P__c_Value !== undefined) {
                    row.fieldValue = HA_P__c_Value;
                }
                if (row.fieldName === "HA_D_Amt__c" && HA_D_Amt__c_Value !== undefined) {
                    row.fieldValue = HA_D_Amt__c_Value;
                }
                if (row.fieldName === "HA_C_M_D_Perc__c" && HA_C_M_D_Perc__c_Value !== undefined) {
                    row.fieldValue = HA_C_M_D_Perc__c_Value;
                }
                if (row.fieldName === "HA_C_M_D_Amt__c" && HA_C_M_D_Amt__c_Value !== undefined) {
                    row.fieldValue = HA_C_M_D_Amt__c_Value;
                }
                if (
                    row.fieldName === "HA_Mgmt_Approved_Disc_Amount_Vendor__c" &&
                    HA_Mgmt_Approved_Disc_Amount_Vendor__c_Value !== undefined
                ) {
                    row.fieldValue = HA_Mgmt_Approved_Disc_Amount_Vendor__c_Value;
                }
                if (
                    row.fieldName === "HA_Total_Discount_Amount_Vendor__c" &&
                    HA_Total_Discount_Amount_Vendor__c_Value !== undefined
                ) {
                    row.fieldValue = HA_Total_Discount_Amount_Vendor__c_Value;
                }
                if (row.fieldName === "HA_1_Yr_Rev__c" && HA_1_Yr_Rev__c_Value !== undefined) {
                    row.fieldValue = HA_1_Yr_Rev__c_Value;
                }
                if (row.fieldName === "TotalPrice" && TotalPrice_Value !== undefined) {
                    row.fieldValue = TotalPrice_Value;
                }
                if (row.fieldName === "HA_Additional_Cost__c" && HA_Additional_Cost__c_Value !== undefined) {
                    row.fieldValue = HA_Additional_Cost__c_Value;
                }
            });
        }
    }
    setValuesForAnalyticsProvider(event) {
        var HA_Term_Yrs__c_Value;
        var TotalPrice_Value;
        var ListPrice_Value;
        var HA_1_Yr_Rev__c_Value;
        var HA_Sales_Price__c_Value;
        var HA_Discount_Type__c_Value;
        var HA_Discount_Percent__c_Value;
        var HA_Discount_Amount__c_Value = 0;
        var HA_OA_Discount_Type__c_Value;
        var HA_OA_Discount_Percent__c_Value;
        var HA_OA_Discount_Amount__c_Value = 0;
        var HA_Mgmt_Approved_Discount_Percent__c_Value;
        var HA_Mgmt_Approved_Discount_Amount__c_Value = 0;
        var HA_Total_Discount_Amount_Provider__c_Value = 0;
        var HA_Additional_Cost__c_Value;
        var TotalPrice_Value = 0;
        var HA_Term_Yrs__c_Value;
        let HA_List_Price__c_Value = 0;
        let basePrice = 0;

        if (
            event.detail.name === "HA_Term_Yrs__c" ||
            event.detail.name === "HA_Sales_Price__c" ||
            event.detail.name === "HA_Discount_Type__c" ||
            event.detail.name === "HA_OA_Discount_Type__c" ||
            event.detail.name === "HA_Mgmt_Approved_Discount_Percent__c" ||
            event.detail.name === "HA_Additional_Cost__c"
        ) {
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row["fieldValue"] !== null) {
                    if (row.fieldName === "HA_Term_Yrs__c") {
                        HA_Term_Yrs__c_Value = row.fieldValue;
                    }

                    if (row.fieldName === "ListPrice") {
                        ListPrice_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Sales_Price__c") {
                        HA_Sales_Price__c_Value = row.fieldValue || 0;
                        if (HA_Sales_Price__c_Value != null && HA_Sales_Price__c_Value != "") {
                            basePrice = row.fieldValue;
                        }
                    }
                    if (row.fieldName === "HA_Discount_Type__c") {
                        HA_Discount_Type__c_Value = row.fieldValue;
                    }

                    if (row.fieldName === "HA_OA_Discount_Type__c") {
                        HA_OA_Discount_Type__c_Value = row.fieldValue;
                    }

                    if (row.fieldName === "HA_Mgmt_Approved_Discount_Percent__c") {
                        HA_Mgmt_Approved_Discount_Percent__c_Value = row.fieldValue;
                    }
                    if (row.fieldName === "HA_Additional_Cost__c") {
                        HA_Additional_Cost__c_Value = row.fieldValue;
                    }

                    if (row.fieldName === "HA_Term_Yrs__c") {
                        HA_Term_Yrs__c_Value = row.fieldValue;
                    }

                    if (row.fieldName == "ListPrice") {
                        HA_List_Price__c_Value = parseInt(row.fieldValue) || 0;
                        if (basePrice == 0 || basePrice == null) {
                            basePrice = row.fieldValue;
                        }
                    }
                }
            });

            if (basePrice == null || basePrice == "") {
                basePrice = HA_List_Price__c_Value;
            }

            if (
                (HA_Sales_Price__c_Value === null || HA_Sales_Price__c_Value === undefined) &&
                ListPrice_Value !== null
            ) {
                HA_Sales_Price__c_Value = ListPrice_Value;
            }
            if (HA_Discount_Type__c_Value !== null || HA_Discount_Type__c_Value !== undefined) {
                for (var a in this.newRecord.mapHaDiscountWithPercent) {
                    if (a === HA_Discount_Type__c_Value) {
                        HA_Discount_Percent__c_Value = this.newRecord.mapHaDiscountWithPercent[a];
                    }
                }
            }
            if (HA_OA_Discount_Type__c_Value !== null || HA_OA_Discount_Type__c_Value !== undefined) {
                for (var a in this.newRecord.mapHaOaDiscountWithPercent) {
                    if (a === HA_OA_Discount_Type__c_Value) {
                        HA_OA_Discount_Percent__c_Value = this.newRecord.mapHaOaDiscountWithPercent[a];
                    }
                }
            }
            if (
                HA_Sales_Price__c_Value !== null &&
                HA_Sales_Price__c_Value !== undefined &&
                HA_Discount_Percent__c_Value !== null &&
                HA_Discount_Percent__c_Value !== undefined
            ) {
                HA_Discount_Amount__c_Value = (HA_Sales_Price__c_Value * HA_Discount_Percent__c_Value) / 100;
            }
            if (
                HA_Discount_Amount__c_Value !== null &&
                HA_Discount_Amount__c_Value !== undefined &&
                HA_OA_Discount_Percent__c_Value !== null &&
                HA_OA_Discount_Percent__c_Value !== undefined &&
                HA_Sales_Price__c_Value !== null &&
                HA_Sales_Price__c_Value !== undefined
            ) {
                HA_OA_Discount_Amount__c_Value =
                    (HA_OA_Discount_Percent__c_Value / 100) * (HA_Sales_Price__c_Value - HA_Discount_Amount__c_Value);
            }
            if (
                HA_Mgmt_Approved_Discount_Percent__c_Value !== null &&
                HA_Mgmt_Approved_Discount_Percent__c_Value !== undefined
            ) {
                if (HA_Mgmt_Approved_Discount_Percent__c_Value > 0) {
                    HA_Mgmt_Approved_Discount_Amount__c_Value =
                        ((HA_Sales_Price__c_Value - (HA_Discount_Amount__c_Value + HA_OA_Discount_Amount__c_Value)) *
                            HA_Mgmt_Approved_Discount_Percent__c_Value) /
                        100;
                } else {
                    HA_Mgmt_Approved_Discount_Amount__c_Value = 0;
                }
            }

            HA_Total_Discount_Amount_Provider__c_Value =
                HA_Mgmt_Approved_Discount_Amount__c_Value +
                HA_Discount_Amount__c_Value +
                HA_OA_Discount_Amount__c_Value;

            if (HA_Additional_Cost__c_Value === undefined || HA_Additional_Cost__c_Value === null) {
                HA_Additional_Cost__c_Value = 0;
            }
            var add = parseFloat(basePrice) + parseFloat(HA_Additional_Cost__c_Value);
            TotalPrice_Value = add - HA_Total_Discount_Amount_Provider__c_Value;

            if (
                HA_Term_Yrs__c_Value !== null &&
                HA_Term_Yrs__c_Value !== undefined &&
                TotalPrice_Value !== null &&
                TotalPrice_Value !== undefined
            ) {
                HA_1_Yr_Rev__c_Value = TotalPrice_Value / HA_Term_Yrs__c_Value;
            }

            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row.fieldName === "HA_1_Yr_Rev__c") {
                    row.fieldValue = HA_1_Yr_Rev__c_Value;
                }
                if (row.fieldName === "HA_Sales_Price__c") {
                    row.fieldValue = HA_Sales_Price__c_Value;
                }
                if (row.fieldName === "HA_Discount_Percent__c") {
                    row.fieldValue = HA_Discount_Percent__c_Value;
                }
                if (row.fieldName === "HA_Discount_Amount__c") {
                    row.fieldValue = HA_Discount_Amount__c_Value;
                }
                if (row.fieldName === "HA_OA_Discount_Percent__c") {
                    row.fieldValue = HA_OA_Discount_Percent__c_Value;
                }
                if (row.fieldName === "HA_OA_Discount_Amount__c") {
                    row.fieldValue = HA_OA_Discount_Amount__c_Value;
                }
                if (row.fieldName === "HA_Mgmt_Approved_Discount_Amount__c") {
                    row.fieldValue = HA_Mgmt_Approved_Discount_Amount__c_Value;
                }
                if (row.fieldName === "HA_Total_Discount_Amount_Provider__c") {
                    row.fieldValue = HA_Total_Discount_Amount_Provider__c_Value;
                }
                if (row.fieldName === "TotalPrice") {
                    row.fieldValue = TotalPrice_Value;
                }
            });
        }
    }

    setValuesForHA(event) {
        var Quantity_Value = 0;
        var UnitPrice_Value;
        var TotalPrice_Value = 0;
        var Discount_Value = 0;
        var SubTotal_Value = 0;
        var HA_Sales_Price__c_Value = 0;
        var HA_Discount__c_Value = 0;
        let HA_List_Price__c_Value = 0;
        let basePrice = 0;

        console.log("evDetName");
        console.log(event.detail.name);

        if (
            event.detail.name === "Quantity" ||
            event.detail.name === "UnitPrice" ||
            event.detail.name === "HA_Discount__c" ||
            event.detail.name === "HA_Sales_Price__c"
        ) {
            console.log("INSIDE");
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row["fieldValue"] !== null && row["fieldValue"] !== undefined) {
                    console.log("rFieldName");
                    console.log(row.fieldName);

                    if (row.fieldName === "HA_Sales_Price__c") {
                        HA_Sales_Price__c_Value = parseFloat(row.fieldValue) || 0;
                        if (HA_Sales_Price__c_Value != null && HA_Sales_Price__c_Value != "") {
                            basePrice = row.fieldValue;
                        }
                    }
                    if (row.fieldName === "HA_Discount__c") {
                        HA_Discount__c_Value = parseFloat(row.fieldValue) || 0;
                        row.isRequired = false;
                    }

                    if (row.fieldName === "UnitPrice") {
                        UnitPrice_Value = parseFloat(row.fieldValue) || 0;
                    }
                    if (row.fieldName === "Quantity") {
                        Quantity_Value = parseInt(row.fieldValue) || 0;
                    }

                    if (row.fieldName == "ListPrice") {
                        HA_List_Price__c_Value = parseInt(row.fieldValue) || 0;
                        console.log("currentBPrice2");
                        console.log(basePrice);
                        if (basePrice == 0 || basePrice == null) {
                            basePrice = row.fieldValue;
                        }
                    }
                }
            });

            if (basePrice == null || basePrice == "") {
                basePrice = HA_List_Price__c_Value;
            }
            console.log("prices");
            console.log(basePrice);
            console.log(HA_List_Price__c_Value);
            console.log(HA_Discount__c_Value);
            console.log(HA_Sales_Price__c_Value);
            console.log(Quantity_Value);
            //if (HA_Sales_Price__c_Value !== null && HA_Sales_Price__c_Value !== undefined) {
            //SubTotal_Value = HA_Sales_Price__c_Value * Quantity_Value;
            TotalPrice_Value = (basePrice - (HA_Discount__c_Value / 100) * HA_Sales_Price__c_Value) * Quantity_Value;
            //HA_Sales_Price__c_Value = 14;

            //TotalPrice_Value = HA_Sales_Price__c_Value;
            //}
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row.fieldName === "TotalPrice") {
                    row.fieldValue = TotalPrice_Value;
                }
                if (row.fieldName === "Subtotal") {
                    row.fieldValue = SubTotal_Value;
                }
            });
        }
    }

    setValuesForNA(event) {
        var CMDiscount_Value = 0;
        var Quantity_Value = 0;
        var UnitPrice_Value;
        var TotalPrice_Value = 0;
        var Discount_Value = 0;
        let basePrice = 0;

        if (
            event.detail.name === "Quantity" ||
            event.detail.name === "UnitPrice" ||
            event.detail.name === "Corporate_Membership_Discount_Amount__c"
        ) {
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row["fieldValue"] !== null && row["fieldValue"] !== undefined) {
                    if (row.fieldName === "UnitPrice") {
                        UnitPrice_Value = parseFloat(row.fieldValue);
                    }
                    if (row.fieldName === "Corporate_Membership_Discount_Amount__c") {
                        CMDiscount_Value = parseFloat(row.fieldValue);
                    }
                    if (row.fieldName === "Quantity") {
                        Quantity_Value = parseInt(row.fieldValue);
                    }
                }
            });

            if (UnitPrice_Value !== null && UnitPrice_Value !== undefined) {
                if (CMDiscount_Value !== null && CMDiscount_Value !== undefined) {
                    Discount_Value =
                        100 -
                        ((Quantity_Value * UnitPrice_Value - Quantity_Value * CMDiscount_Value) /
                            (Quantity_Value * UnitPrice_Value)) *
                            100;
                }

                TotalPrice_Value = (UnitPrice_Value - (Discount_Value / 100) * UnitPrice_Value) * Quantity_Value;
            }
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row.fieldName === "Corporate_Membership_Discount_Amount__c") {
                    row.fieldValue = CMDiscount_Value;
                }
                if (row.fieldName === "TotalPrice") {
                    row.fieldValue = TotalPrice_Value;
                }
                if (row.fieldName === "Discount") {
                    row.fieldValue = Discount_Value;
                }
            });
        }
    }

    setValuesForPCHA(event) {
        var DiscountPer_Value = 0;
        var DiscountAmt_Value = 0;
        var Quantity_Value = 0;
        var UnitPrice_Value;
        var TotalPrice_Value = 0;
        var Discount_Value = 0;

        if (
            event.detail.name === "Quantity" ||
            event.detail.name === "UnitPrice" ||
            event.detail.name === "Discount_Percent__c" ||
            event.detail.name === "Discount_Amount__c"
        ) {
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row["fieldValue"] !== null && row["fieldValue"] !== undefined) {
                    if (row.fieldName === "UnitPrice") {
                        UnitPrice_Value = parseFloat(row.fieldValue) || 0;
                    }
                    if (row.fieldName === "Discount_Amount__c") {
                        DiscountAmt_Value = parseFloat(row.fieldValue) || 0;
                    }
                    if (row.fieldName === "Discount_Percent__c") {
                        DiscountPer_Value = parseFloat(row.fieldValue) || 0;
                    }
                    if (row.fieldName === "Quantity") {
                        Quantity_Value = parseFloat(row.fieldValue) || 0;
                    }
                }
            });

            if (UnitPrice_Value !== null && UnitPrice_Value !== undefined) {
                var tPrice = Quantity_Value * UnitPrice_Value;

                Discount_Value =
                    100 -
                    ((tPrice - DiscountAmt_Value - (tPrice - DiscountAmt_Value) * (DiscountPer_Value / 100)) / tPrice) *
                        100;

                TotalPrice_Value = (UnitPrice_Value - (Discount_Value / 100) * UnitPrice_Value) * Quantity_Value;
            }
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row.fieldName === "TotalPrice") {
                    row.fieldValue = TotalPrice_Value;
                }
                if (row.fieldName === "Discount") {
                    row.fieldValue = Discount_Value;
                }
            });
        }
    }

    setValuesForMedia(event) {
        var DiscountPer_Value = 0;
        var RateType_Value = "";
        var Quantity_Value = 0;
        var UnitPrice_Value;
        var TotalPrice_Value = 0;
        var Discount_Value = 0;

        if (
            event.detail.name === "Quantity" ||
            event.detail.name === "UnitPrice" ||
            event.detail.name === "Discount_Percent__c"
        ) {
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row["fieldValue"] !== null && row["fieldValue"] !== undefined) {
                    if (row.fieldName === "UnitPrice") {
                        UnitPrice_Value = parseFloat(row.fieldValue) || 0;
                    }
                    if (row.fieldName === "Rate_Type__c") {
                        RateType_Value = row.fieldValue;
                    }
                    if (row.fieldName === "Discount_Percent__c") {
                        DiscountPer_Value = parseFloat(row.fieldValue) || 0;
                    }
                    if (row.fieldName === "Quantity") {
                        Quantity_Value = parseInt(row.fieldValue) || 0;
                    }
                }
            });

            if (
                UnitPrice_Value !== null &&
                UnitPrice_Value !== undefined &&
                Quantity_Value !== 0 &&
                UnitPrice_Value !== 0
            ) {
                var tPrice = Quantity_Value * UnitPrice_Value;

                if (RateType_Value === "CPM") {
                    var amt = tPrice / 1000 - (tPrice / 1000) * (DiscountPer_Value / 100);

                    Discount_Value = 100 - (parseFloat(amt) / parseFloat(tPrice)) * 100;
                } else {
                    Discount_Value = DiscountPer_Value;
                }

                TotalPrice_Value = (UnitPrice_Value - (Discount_Value / 100) * UnitPrice_Value) * Quantity_Value;
            } else {
                TotalPrice_Value = 0;
            }
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row.fieldName === "TotalPrice") {
                    row.fieldValue = TotalPrice_Value;
                }
                if (row.fieldName === "Discount") {
                    row.fieldValue = Discount_Value;
                }
            });
        }
    }

    setValuesForOtherBu(event) {
        var Quantity_Value = 0;
        var UnitPrice_Value;
        var TotalPrice_Value = 0;
        var Discount_Value = 0;
        var SubTotal_Value = 0;

        if (event.detail.name === "Quantity" || event.detail.name === "UnitPrice" || event.detail.name === "Discount") {
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row["fieldValue"] !== null && row["fieldValue"] !== undefined) {
                    if (row.fieldName === "UnitPrice") {
                        UnitPrice_Value = parseFloat(row.fieldValue) || 0;
                    }
                    if (row.fieldName === "Discount") {
                        Discount_Value = parseFloat(row.fieldValue) || 0;
                    }
                    if (row.fieldName === "Quantity") {
                        Quantity_Value = parseInt(row.fieldValue) || 0;
                    }
                }
            });

            if (UnitPrice_Value !== null && UnitPrice_Value !== undefined) {
                SubTotal_Value = UnitPrice_Value * Quantity_Value;
                TotalPrice_Value = (UnitPrice_Value - (Discount_Value / 100) * UnitPrice_Value) * Quantity_Value;
            }
            this.prductRecords[event.detail.Key].fileDetailWrapper.forEach((row) => {
                if (row.fieldName === "TotalPrice") {
                    row.fieldValue = TotalPrice_Value;
                }
                if (row.fieldName === "Subtotal") {
                    row.fieldValue = SubTotal_Value;
                }
            });
        }
    }

    @api checkValidation() {
        var isValid = true;
        var Validation;
        this.template.querySelectorAll("c-input-fields").forEach((element) => {
            Validation = element.checkValidation();
            if (Validation === false) {
                isValid = false;
            }
        });

        return isValid;
    }
    @api checkArraySize() {
        if (this.prductRecords.length > 0) {
            return true;
        } else {
            return false;
        }
    }

    @api handlePrductIdsChange(selectedProducts) {
        var isContains = false;
        var newRecord = JSON.parse(JSON.stringify(this.newRecord));
        console.log(newRecord);
        newRecord.prodId = selectedProducts.Id;
        newRecord.fileDetailWrapper.forEach((element) => {
            if (element.fieldLabel === "Product Name") {
                element.fieldValue = selectedProducts.Name;
            } else if (element.fieldName === "Corporate_Membership_Discount_Amount__c") {
                element.fieldValue = selectedProducts.CM_Discount__c;
            } else if (element.fieldName === "Product_Sub_Type__c") {
                element.fieldValue = selectedProducts.Sub_Type__c;

                if (selectedProducts.Sub_Type__c !== undefined && selectedProducts.Sub_Type__c !== null) {
                    isContains = true;
                }

                this.template.querySelectorAll("c-input-fields").forEach((ele) => {
                    if (ele.field.fieldName === "Product_Sub_Type__c") {
                        ele.options.forEach((row) => {
                            if (row.label === selectedProducts.Sub_Type__c) {
                                //element.fieldValue=selectedProducts.Sub_Type__c;
                                // element.handlePicklistDependency(selectedProducts.Sub_Type__c);
                                //isContains = true;
                            }
                        });
                    }
                });
            } else if (element.fieldName === "Rate_Type__c") {
                element.fieldValue = selectedProducts.Rate_Type__c;
            } else if (element.fieldValue === null) {
                element.fieldValue = null;
            }

            if (element.controllingField !== null && element.controllingField !== "") {
                //element.isEditable = false;
            }

            if (!isContains && element.fieldName === "Ad_Size2__c") {
                element.isEditable = false;
            } else {
                element.controllingFieldValue = selectedProducts.Sub_Type__c;
            }

            if (element.fieldLabel === "List Price" || element.fieldName === "UnitPrice") {
                for (var a in newRecord.mapProductWithUnitPrice) {
                    if (a === selectedProducts.Id) {
                        element.fieldValue = newRecord.mapProductWithUnitPrice[a];
                    }
                }
            }

            element.pType = selectedProducts.Type__c;
        });

        newRecord.fileDetailWrapper.forEach((element) => {
            console.log(element.fieldName);
            console.log(element.fieldValue);
            if (
                (element.fieldName == "HA_Sales_Price__c" || element.fieldName == 'TotalPrice') &&
                (element.fieldValue == undefined || element.fieldValue == null || element.fieldValue == 0.00)
            ) {
                console.log('populating');
                console.log(element.fieldName);
                for (var a in newRecord.mapProductWithUnitPrice) {
                    if (a === selectedProducts.Id) {
                        element.fieldValue = newRecord.mapProductWithUnitPrice[a];
                    }
                }
            }
        });
        this.prductRecords.push(newRecord);
        if (this.prductRecords.length > 0) {
            this.showList = true;
        }
    }
    removeRow(event) {
        var index = event.target.value;

        var id = this.prductRecords[index].prodId;
        if (id.startsWith("00k")) {
            deleteRecord(id)
                .then(() => {
                    this.prductRecords.splice(index, 1);
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error deleting record",
                            message: error.body.message,
                            variant: "error"
                        })
                    );
                });
            const saveRecords = new CustomEvent("saverecords", {
                detail: this.prductRecords
            });
            this.dispatchEvent(saveRecords);
        } else {
            this.prductRecords.splice(index, 1);
            const saveRecords = new CustomEvent("saverecords", {
                detail: this.prductRecords
            });
            this.dispatchEvent(saveRecords);
        }
    }
}