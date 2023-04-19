import { LightningElement, api, track } from 'lwc';
import getProductList from '@salesforce/apex/OpportunityProductList_c.getProductList';
import { NavigationMixin } from 'lightning/navigation';
export default class OpportunityProductRelatedListMobile extends NavigationMixin(LightningElement) {
    @api prop2;
    @api prop3;
    @api prop1;
    @api recordId;
    @track productWithCount;
    @track productData = [];

    connectedCallback() {
        getProductList({ oppId: this.recordId, sObjectName: 'OpportunityLineItem' })
            .then(result => {
                result.products.forEach(element => {
                    var Details = [];
                    var columnsCount = 0;
                    for (var a in result.mapFieldLabelWithApi) {
                        columnsCount++
                        /*
                        if (columnsCount === 6) {
                            break;
                        }*/
                        Details.push({ Lable: a, Value: element[result.mapFieldLabelWithApi[a]] });
                    }
                    this.productData.push({
                        Id: element.Id,
                        oliName: element.Product2.Name,
                        url: '/' + element.Id,
                        "Details": Details
                    });

                });
                this.productWithCount = 'Products (' + this.productData.length + ')';
            })

    }
}