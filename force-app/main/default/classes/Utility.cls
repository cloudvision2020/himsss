public class Utility {
    
    /**
    *
    * @description Return the pricebook name, pricebook id from the PriceBook2 object as key value pair
    *
	*/
    public static Map<String, String> getPriceBookNameById(Set<String> pricebookNames)
    {
        Map<String, String> priceBookNameById = new Map<String, String>();
        for(Pricebook2 priceBookObj : [SELECT IsActive, Name, Id FROM Pricebook2 
                                       WHERE Name IN :pricebookNames])
        {
            priceBookNameById.put(priceBookObj.Name, priceBookObj.Id);
        }
        return priceBookNameById;
    }
    
    /**
    *
    * @description Return the record type id by record type info 
    *
	*/
    public static Map<Id,Schema.RecordTypeInfo> getRecordTypeInfoById()
    {
        return Schema.SObjectType.Opportunity.getRecordTypeInfosById();
    }
    
    /**
    *
    * @description Return the opportunity record type name, pricebook name as key value pair from custom metadata types
    *              Note : Metadata's DeveloperName field is having the opportunity record type name
    *  
	*/
    public static Map<String, String> getPriceookNameByOpportunityRecordType()
    {
        Map<String, String> priceBookNameByOpportunityRecordType = new Map<String, String>();
        for(Field_Map__mdt priceBook : [SELECT Id, DeveloperName, Pricebook_Name__c 
                                        FROM Field_Map__mdt])
        {
            priceBookNameByOpportunityRecordType.put(priceBook.DeveloperName, priceBook.Pricebook_Name__c);
        }
        
        return priceBookNameByOpportunityRecordType;
    }

    /**
    *
    * @description Return the sObject field label info 
    *
	*/
    public static Map<String,String> getFieldLabel(List<String> fieldNames,String sObjectName){
        Map<String,String> mapFieldNameWithLabel = new Map<String,String>();

        //get sObject schema map
        String type = sObjectName;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType opportunityLineItemSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = opportunityLineItemSchema.getDescribe().fields.getMap();
            
        for(String fieldName : fieldNames){
            if(fieldName.contains('.') == true){
                List<String> splitString = fieldName.split('\\.');

                //get sObject schema map
                String sObjtype = splitString[0];
                Map<String, Schema.SObjectType> schemasObjectMap = Schema.getGlobalDescribe();
                Schema.SObjectType sObjectSchema = schemasObjectMap.get(sObjtype);
                Map<String, Schema.SObjectField> sObjectFieldMap = sObjectSchema.getDescribe().fields.getMap();
                String sObjectlabel =  sObjectFieldMap.get(splitString[1]).getDescribe().getLabel();//It provides to get the object fields label.
                mapFieldNameWithLabel.put(fieldName,sObjectlabel);
            }
            else{
                String label = fieldMap.get(fieldName).getDescribe().getLabel();
                mapFieldNameWithLabel.put(fieldName,label);
            }
        }
        return mapFieldNameWithLabel;
    }
    /**
    *
    * @description Return the sObject field type info 
    *
	*/
    public static Map<String,String> getFieldType(List<String> fieldNames,String sObjectName){
        Map<String,String> mapFieldNameWithType = new Map<String,String>();

        //get sObject schema map
        String type = sObjectName;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType opportunityLineItemSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = opportunityLineItemSchema.getDescribe().fields.getMap();

        for(String fieldName : fieldNames){
            if(fieldName.contains('.') == true){
                List<String> splitString = fieldName.split('\\.');

                //get sObject schema map
                String sObjtype = splitString[0];
                Map<String, Schema.SObjectType> schemasObjectMap = Schema.getGlobalDescribe();
                Schema.SObjectType sObjectSchema = schemasObjectMap.get(sObjtype);
                Map<String, Schema.SObjectField> sObjectFieldMap = sObjectSchema.getDescribe().fields.getMap();

                Schema.DisplayType sObjectFielddataType = sObjectFieldMap.get(splitString[1]).getDescribe().getType();
                String sObjectfieldType = String.valueOf(sObjectFielddataType);
                if(sObjectfieldType == 'DOUBLE'){
                    sObjectfieldType = 'number';
                }
                mapFieldNameWithType.put(fieldName,sObjectfieldType);
            }
            else{
                Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                String fieldType = String.valueOf(fielddataType);
                if(fieldType == 'DOUBLE'){
                    fieldType = 'number';
                }
                mapFieldNameWithType.put(fieldName,fieldType);
            }  
        }
        return mapFieldNameWithType;
    }

    /**
    *
    * @description Return the sObject field is Updateable info 
    *
	*/
    public static Map<String,Boolean> getFieldIsUpdateableInfo(List<String> fieldNames,String sObjectName){
        Map<String,boolean> mapFieldNameWithIsUpdateable = new Map<String,boolean>();

        //get sObject schema map
        String type = sObjectName;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType opportunityLineItemSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = opportunityLineItemSchema.getDescribe().fields.getMap();

        for(String fieldName : fieldNames){
            if(fieldName.contains('.') == true){
                List<String> splitString = fieldName.split('\\.');

                //get sObject schema map
                String sObjtype = splitString[0];
                Map<String, Schema.SObjectType> schemasObjectMap = Schema.getGlobalDescribe();
                Schema.SObjectType sObjectSchema = schemasObjectMap.get(sObjtype);
                Map<String, Schema.SObjectField> sObjectFieldMap = sObjectSchema.getDescribe().fields.getMap();

                boolean isUpdateable = sObjectFieldMap.get(splitString[1]).getDescribe().isUpdateable();
                
                mapFieldNameWithIsUpdateable.put(fieldName,isUpdateable);
            }
            else{
                boolean isUpdateable = fieldMap.get(fieldName).getDescribe().isUpdateable();
                mapFieldNameWithIsUpdateable.put(fieldName,isUpdateable);
            }  
        }
        return mapFieldNameWithIsUpdateable;
    }

    public static Map<String,String> getControllingField(String fieldName,String sObjectName){
        Map<String,String> mapFieldNameWithControllingField = new Map<String,String>();

        //get sObject schema map
        String type = sObjectName;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType opportunityLineItemSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = opportunityLineItemSchema.getDescribe().fields.getMap();
        Schema.DescribeFieldResult result = fieldMap.get(fieldName).getDescribe();
        if(result.isDependentPicklist()){
            mapFieldNameWithControllingField.put(fieldName,result.getController().getDescribe().getName());
        }
        return mapFieldNameWithControllingField;
    }
    public static  List<Contract_Line_Item__c> getContractLineItems( List<Contract> contracts,  Map<String, List<OpportunityLineItem>> opportunityIdWithOpportunityLineItemsMap){

        List<Contract_Line_Item__c> contractLineItems = new List<Contract_Line_Item__c>();
        for(Contract contractObj : contracts)
        {
            if(opportunityIdWithOpportunityLineItemsMap.containsKey(contractObj.Opportunity__c)){
                
                for(OpportunityLineItem opportunityLineItemObj : opportunityIdWithOpportunityLineItemsMap.get(contractObj.Opportunity__c))
                {
                    Contract_Line_Item__c contractLineItemObj = new  Contract_Line_Item__c();
                                        
                    contractLineItemObj.Contract__c = contractObj.Id;
                    contractLineItemObj.Ad_Size__c = opportunityLineItemObj.Ad_Size2__c;
                    contractLineItemObj.Brand__c = opportunityLineItemObj.Brand__c;
                    contractLineItemObj.CurrencyISOCode = opportunityLineItemObj.CurrencyISOCode;
                    contractLineItemObj.Discount__c = opportunityLineItemObj.Discount_Percent__c;
                    contractLineItemObj.End_Date__c = opportunityLineItemObj.End_Date__c;
                    contractLineItemObj.Line_Description__c = opportunityLineItemObj.Description;
                    contractLineItemObj.List_Price__c = opportunityLineItemObj.ListPrice;
                    contractLineItemObj.Product_Code__c = opportunityLineItemObj.ProductCode;
                    contractLineItemObj.Product_Family__c = opportunityLineItemObj.Product2.Family;
                    contractLineItemObj.Product_Name__c = opportunityLineItemObj.Product2.Name;
                    contractLineItemObj.Quantity__c = opportunityLineItemObj.Quantity;
                    contractLineItemObj.Rate_Type__c = opportunityLineItemObj.Rate_Type__c;
                    contractLineItemObj.Region__c = opportunityLineItemObj.Region__c;
                    contractLineItemObj.Sales_Price__c = opportunityLineItemObj.UnitPrice;
                    contractLineItemObj.Start_Date__c = opportunityLineItemObj.Start_Date__c;
                    contractLineItemObj.Total_Price__c = opportunityLineItemObj.TotalPrice;
                    contractLineItemObj.Opportunity_Line_Item_Id__c = opportunityLineItemObj.Id;
                    
                    contractLineItems.add(contractLineItemObj);
                }
            }
        }
        return contractLineItems;
    }
    
}