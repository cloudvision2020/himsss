public with sharing class OpportunityProductList_c {
    public OpportunityProductList_c() {

    }
    @AuraEnabled
    public static String deleteProduct(String oppId, String rowId){
        Opportunity opp = [SELECT Id,RecordTypeId,Contract.Status FROM Opportunity WHERE Id =: oppId LIMIT 1];
        Map<Id, Schema.RecordTypeInfo> recordTypeIdByInfo = Utility.getRecordTypeInfoById();
        String recordTypeDeveloperName = recordTypeIdByInfo.get(opp.RecordTypeId).getDeveloperName();
        String rowDelet = 'Deleted';
        List<OpportunityLineItem> lstToDelete = new List<OpportunityLineItem>();
        for(OpportunityLineItem prod : [SELECT Id,End_Date__c,Contract_Line_Item__c FROM OpportunityLineItem WHERE Id =: rowId]){
            if(recordTypeDeveloperName == Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEDEVELOPERNAME){
                if(opp.Contract.Status == 'Activated' && Date.valueof(prod.get('End_Date__c')) < Date.today()
                        && String.valueof(prod.get('Contract_Line_Item__c')) != null)
                {
                    rowDelet = 'NotDelet'; 
                    return rowDelet;
                }
                else {
                    lstToDelete.add(prod);    
                }
                
            }
            else
            {
                lstToDelete.add(prod);
            }
        }
    if (!lstToDelete.isEmpty()){
            delete  lstToDelete;
        }
            
        return 'Deleted';
    }
     /**
    * @description get existing product records 
	*/
    @AuraEnabled
    public static OpportunityProductList_c.FieldDetails getProductList(String oppId,String sObjectName){
        Opportunity opp = [SELECT Id,RecordTypeId FROM Opportunity WHERE Id =: oppId LIMIT 1]; 
        Map<Id, Schema.RecordTypeInfo> recordTypeIdByInfo = Utility.getRecordTypeInfoById();
        String recordTypeDeveloperName = recordTypeIdByInfo.get(opp.RecordTypeId).getDeveloperName();

        Field_Map__mdt metadata = [SELECT Id,Label,ProductColumns__c FROM Field_Map__mdt WHERE Label=: recordTypeDeveloperName LIMIT 1];
        
        List<String> fieldNames = new List<String>();
        fieldNames = metadata.ProductColumns__c.split(',');

        Map<String,String> coulmnLabel = Utility.getFieldLabel(fieldNames,sObjectName);
        Map<String,String> coulmnType = Utility.getFieldType(fieldNames,sObjectName);
        OpportunityProductList_c.FieldDetails Wrapper= new OpportunityProductList_c.FieldDetails();
       
        Map<string,String> mapFieldLabelWithType = new Map<string,String>();
        Map<string,String> mapFieldLabelWithApi = new Map<string,String>(); 
        for(String fieldName : fieldNames){
            mapFieldLabelWithType.put(coulmnLabel.get(fieldName),coulmnType.get(fieldName));
            mapFieldLabelWithApi.put(coulmnLabel.get(fieldName),fieldName);
        }
        Wrapper.mapFieldLabelWithType = mapFieldLabelWithType;
        Wrapper.mapFieldLabelWithApi = mapFieldLabelWithApi;
        Wrapper.recordTypeName = recordTypeDeveloperName;
        List<OpportunityLineItem> productList = new List<OpportunityLineItem>();
        String productQuery = 'SELECT Id,OpportunityId,Product2.Name,Product2.IsActive,Contract_Line_Item__c, ';
        for(String fieldName : fieldNames){
            productQuery += fieldName + ',';
        }
        productQuery = productQuery.removeEnd(',');
        productQuery += ' FROM OpportunityLineItem WHERE OpportunityId=:oppId';
        productList = Database.query(productQuery);

        Wrapper.products = productList;
        return Wrapper;
    }
    public class FieldDetails{
        @AuraEnabled
        public Map<string,String> mapFieldLabelWithType{get;set;}
        @AuraEnabled
        public Map<string,String> mapFieldLabelWithApi{get;set;}
        @AuraEnabled
        public String recordTypeName{get;set;}
        @AuraEnabled
        public List<OpportunityLineItem> products{get;set;}
    }
}