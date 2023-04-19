public with sharing class OpportunityProductSearch_c {
    public OpportunityProductSearch_c() {

    }
      /**
    * @description create product search table column header
	*/
    @AuraEnabled
    public static OpportunityProductSearch_c.FieldDetails getCoulmnNames(String oppId,String sObjectName){
        List<String> fieldNames = new List<String>();
        Map<string,String> mapFieldLabelWithType = new Map<string,String>();
        Map<string,String> mapFieldLabelWithApi = new Map<string,String>();
        Opportunity opp = [SELECT Id,RecordTypeId FROM Opportunity WHERE Id =: oppId LIMIT 1]; 
        Map<Id, Schema.RecordTypeInfo> recordTypeIdByInfo = Utility.getRecordTypeInfoById();
        String recordTypeDeveloperName = recordTypeIdByInfo.get(opp.RecordTypeId).getDeveloperName();
        Field_Map__mdt metadata = [SELECT Id,Label,SearchProductsColumns__c FROM Field_Map__mdt WHERE Label=: recordTypeDeveloperName LIMIT 1];

        fieldNames = metadata.SearchProductsColumns__c.split(',');

        Map<String,String> coulmnLabel = Utility.getFieldLabel(fieldNames,sObjectName);
        Map<String,String> coulmnType = Utility.getFieldType(fieldNames,sObjectName);
        OpportunityProductSearch_c.FieldDetails Wrapper= new OpportunityProductSearch_c.FieldDetails();
       
        
        for(String fieldName : fieldNames){
            mapFieldLabelWithType.put(coulmnLabel.get(fieldName),coulmnType.get(fieldName));
            mapFieldLabelWithApi.put(coulmnLabel.get(fieldName),fieldName);
        }
        Wrapper.mapFieldLabelWithType = mapFieldLabelWithType;
        Wrapper.mapFieldLabelWithApi = mapFieldLabelWithApi;
        return Wrapper;
    }

    /**
    * @description get product records for search filters
	*/
    @AuraEnabled
    public static List<Product2> getProductList(String oppId,
                                                String productFamilyValue, 
                                                String typeValue, 
                                                String subtypeValue, 
                                                String productNameValue,
                                                String productRegionValue)
    {    
        Opportunity opp = [SELECT Id,pricebook2Id, CurrencyIsoCode from Opportunity where id=: oppId  LIMIT 1];
        String pricebook2Id;
        String opportunityCurrency;
        if(opp.pricebook2Id != null && opp.CurrencyIsoCode != null){
            pricebook2Id = opp.pricebook2Id;
            opportunityCurrency = opp.CurrencyIsoCode;
        }
        System.debug('@@@ ===opportunityCurrency  '+opportunityCurrency);
        List<Product2> listProduct = new List<Product2>();

        if(String.isBlank(productFamilyValue) && 
            String.isBlank(typeValue) && 
            String.isBlank(subtypeValue) && 
            String.isBlank(productNameValue)&& 
            String.isBlank(productRegionValue))
        {
            return listProduct;
        }

        String query = 'SELECT ID,Name,ProductCode,Family,Description,Type__c,Sub_Type__c,CM_Discount__c,Rate_Type__c,Region__c FROM Product2 WHERE IsActive = true AND ';
        
        if(String.isNotBlank(productFamilyValue)){
            query += ' Family = :productFamilyValue AND';
        }
        if(String.isNotBlank(productRegionValue)){
            query += ' Region__c = :productRegionValue AND';
        }

        if(String.isNotBlank(typeValue)){
            query += ' Type__c= :typeValue AND';
        }

        if(String.isNotBlank(subtypeValue)){
            query += ' Sub_Type__c= :subtypeValue AND';
        }
        

        if(String.isNotBlank(productNameValue)){
            string tempInput = '%'+ productNameValue + '%';
            query += ' Name LIKE : tempInput AND';
        }
      
        query += ' Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =: pricebook2Id and CurrencyIsoCode =: opportunityCurrency)';
                
        listProduct = Database.query(query);
        return listProduct;
    }

    public class FieldDetails{
        @AuraEnabled
        public Map<string,String> mapFieldLabelWithType{get;set;}
        @AuraEnabled
        public Map<string,String> mapFieldLabelWithApi{get;set;}
    }
}