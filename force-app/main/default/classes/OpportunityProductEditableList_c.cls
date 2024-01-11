public with sharing class OpportunityProductEditableList_c {
    public OpportunityProductEditableList_c() {

    }
     /**
    * @description retrieve product column header details for ediatble table 
	*/
    @AuraEnabled
    public static OpportunityProductEditableList_c.toDisplayWrapper getCoulmnNames(String oppId){
        Opportunity opp = [SELECT Id,RecordTypeId,Pricebook2Id,CurrencyIsoCode FROM Opportunity WHERE Id =: oppId LIMIT 1]; 
        Map<Id, Schema.RecordTypeInfo> recordTypeIdByInfo = Utility.getRecordTypeInfoById();
        String recordTypeDeveloperName = recordTypeIdByInfo.get(opp.RecordTypeId).getDeveloperName();
        String opportunityCurrency;
        if(opp != null && opp.CurrencyIsoCode != null){
            opportunityCurrency = opp.CurrencyIsoCode;
        }
        List<PricebookEntry> listPBE = [SELECT Id,Product2Id,Pricebook2Id,UnitPrice,IsActive FROM PricebookEntry WHERE Pricebook2Id =: opp.Pricebook2Id AND CurrencyIsoCode=:opportunityCurrency];
        
        Map<Id,Decimal> mapProductWithUnitPrice = new Map<Id,Decimal>();
        for(PricebookEntry PBE : listPBE){
            if(PBE.IsActive && !mapProductWithUnitPrice.containsKey(PBE.Product2Id)){
                mapProductWithUnitPrice.put(PBE.Product2Id, PBE.UnitPrice);
            }
        }
        List<Discount_Setting__mdt> discountSettingMeta = [SELECT Id,Discount_Percentage__c,FieldName__c,FieldValue__c,RecordType__c FROM Discount_Setting__mdt WHERE RecordType__c=:recordTypeDeveloperName];
        List<Selected_Product_Field_Mappings__mdt> metadata = [SELECT Id,Field_Name__c,isRequired__c,IsEditable__c,RecordType__c,Field_Order__c,isVisible__c,defaultValue__c FROM Selected_Product_Field_Mappings__mdt WHERE RecordType__c=: recordTypeDeveloperName ORDER BY Field_Order__c ASC];
        List<String> fieldNames = new List<String>();
        Map<String,Selected_Product_Field_Mappings__mdt> mapFieldNameWithMetaRecord = new Map<String,Selected_Product_Field_Mappings__mdt>();
        fieldNames.add('Product2.Name');
        for(Selected_Product_Field_Mappings__mdt metaObj : metadata){
            fieldNames.add(metaObj.Field_Name__c);
            mapFieldNameWithMetaRecord.put(metaObj.Field_Name__c,metaObj);
        }
        Map<String,Decimal> mapHaDiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHaOaDiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHa_S_R_DiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHa_S_M_DiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHa_S_M_Y_3_DiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHa_Vendor_DiscountWithPercent = new Map<String,Decimal>();
        for(Discount_Setting__mdt discountMetaObj : discountSettingMeta){
            if(discountMetaObj.FieldName__c == 'HA_Discount_Type__c'){
                mapHaDiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_OA_Discount_Type__c'){
                mapHaOaDiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_S_R_Disc__c'){
                mapHa_S_R_DiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_S_M_Disc__c'){
                mapHa_S_M_DiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_M_Y_3_Y_M_D__c'){
                mapHa_S_M_Y_3_DiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_Disc__c'){
                mapHa_Vendor_DiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            
        }
        
        Map<String,String> controllerField = new Map<String,String>();
        Map<String,String> coulmnLabel = Utility.getFieldLabel(fieldNames,'OpportunityLineItem');
        Map<String,String> coulmnType = Utility.getFieldType(fieldNames,'OpportunityLineItem');
        Map<String,Boolean> isUpdateable = Utility.getFieldIsUpdateableInfo(fieldNames,'OpportunityLineItem');
        
        OpportunityProductEditableList_c.ToDisplayWrapper toDisplayWrapper = new OpportunityProductEditableList_c.ToDisplayWrapper();
        List<OpportunityProductEditableList_c.FieldDetails> listWrapper= new List<OpportunityProductEditableList_c.FieldDetails>();
            toDisplayWrapper.prodId = null;
            toDisplayWrapper.mapProductWithUnitPrice = mapProductWithUnitPrice;
            toDisplayWrapper.recordTypeName = recordTypeDeveloperName;
            toDisplayWrapper.mapHaOaDiscountWithPercent = mapHaOaDiscountWithPercent;
            toDisplayWrapper.mapHaDiscountWithPercent = mapHaDiscountWithPercent;
            toDisplayWrapper.mapHa_S_R_DiscountWithPercent = mapHa_S_R_DiscountWithPercent;
            toDisplayWrapper.mapHa_S_M_DiscountWithPercent = mapHa_S_M_DiscountWithPercent;
            toDisplayWrapper.mapHa_S_M_Y_3_DiscountWithPercent = mapHa_S_M_Y_3_DiscountWithPercent;
            toDisplayWrapper.mapHa_Vendor_DiscountWithPercent = mapHa_Vendor_DiscountWithPercent;
            toDisplayWrapper.isRowEditable = true;

            for(String finame: fieldNames){
                OpportunityProductEditableList_c.FieldDetails Wrapper= new OpportunityProductEditableList_c.FieldDetails();
                if(finame.contains('.') == true){
                    List<String> splitStrings = finame.split('\\.');
                    String fieldNameToGet = splitStrings[1];
                    Wrapper.fieldLabel = coulmnLabel.get(finame);
                    Wrapper.fieldName = finame;
                    Wrapper.fieldType = coulmnType.get(finame);
                    Wrapper.isRequired = null;
                    if (finame=='Product2.Name')
                    {
                        Wrapper.isProdcutName = true;
                        Wrapper.isVisible = true;
                    }
                    else {
                        Wrapper.isProdcutName = false;
                        Wrapper.isVisible = mapFieldNameWithMetaRecord.get(finame).isVisible__c;    
                    }                    
                    
                    Wrapper.isEditable = false;
                    Wrapper.fieldValue = null;
                    Wrapper.isUpdateable = false;
                    Wrapper.controllingField = '';
                    Wrapper.Ptype = '';
                    Wrapper.controllingFieldValue = '';
                    

                }
                else{
                    Wrapper.fieldLabel = coulmnLabel.get(finame);
                    Wrapper.fieldName = finame;
                    Wrapper.fieldType = coulmnType.get(finame);
                    Wrapper.isEditable = mapFieldNameWithMetaRecord.get(finame).IsEditable__c;
                    Wrapper.isRequired = mapFieldNameWithMetaRecord.get(finame).isRequired__c;
                    Wrapper.isVisible = mapFieldNameWithMetaRecord.get(finame).isVisible__c;
                    Wrapper.isProdcutName = false;
                    if(mapFieldNameWithMetaRecord.get(finame).defaultValue__c != null){
                        Wrapper.fieldValue = mapFieldNameWithMetaRecord.get(finame).defaultValue__c;
                    }
                    else{
                        Wrapper.fieldValue = null;
                    }
                    Wrapper.isUpdateable = isUpdateable.get(finame);
                    if(coulmnType.get(finame) == 'PICKLIST'){
                        controllerField = Utility.getControllingField(finame,'OpportunityLineItem');
                    }
                    if(controllerField.containsKey(finame)){
                        
                        Wrapper.controllingField = controllerField.get(finame);
                    }
                    else{
                    //Add value
                        Wrapper.controllingField = '';
                        Wrapper.Ptype = '';
                    }
                }
                listWrapper.add(Wrapper);
            }
            toDisplayWrapper.fileDetailWrapper = listWrapper;
        return toDisplayWrapper;
    }
     /**
    * @description retreive existing opportunity product records for the opportunity
	*/
    @AuraEnabled
    public static List<OpportunityProductEditableList_c.toDisplayWrapper> getProductList(String oppId,List<Product2> selectedProducts,String sObjectName){
    
        Opportunity opp = [SELECT Id,RecordTypeId,Pricebook2Id,Contract.Status FROM Opportunity WHERE Id =: oppId LIMIT 1]; 
        Map<Id, Schema.RecordTypeInfo> recordTypeIdByInfo = Utility.getRecordTypeInfoById();
        String recordTypeDeveloperName = recordTypeIdByInfo.get(opp.RecordTypeId).getDeveloperName();

        //List<Discount_Setting__mdt> discountSettingMeta = [SELECT Id,Discount_Percentage__c,FieldName__c,FieldValue__c,RecordType__c FROM Discount_Setting__mdt WHERE RecordType__c=:recordTypeDeveloperName];
        List<Selected_Product_Field_Mappings__mdt> metadata = [SELECT Id,Field_Name__c,isRequired__c,IsEditable__c,RecordType__c,Field_Order__c,isVisible__c,defaultValue__c FROM Selected_Product_Field_Mappings__mdt WHERE RecordType__c=: recordTypeDeveloperName ORDER BY Field_Order__c ASC];
        List<String> fieldNames = new List<String>();
        //List<PricebookEntry> listPBE = [SELECT Id,Product2Id,Pricebook2Id,UnitPrice,IsActive FROM PricebookEntry WHERE Pricebook2Id =: opp.Pricebook2Id];
    
        /*Map<Id,Decimal> mapProductWithUnitPrice = new Map<Id,Decimal>();
        for(PricebookEntry PBE : listPBE){
            if(PBE.IsActive && !mapProductWithUnitPrice.containsKey(PBE.Product2Id)){
                mapProductWithUnitPrice.put(PBE.Product2Id, PBE.UnitPrice);
            }
        }*/

        Map<String,Selected_Product_Field_Mappings__mdt> mapFieldNameWithMetaRecord = new Map<String,Selected_Product_Field_Mappings__mdt>();
        fieldNames.add('Product2.Name');
        for(Selected_Product_Field_Mappings__mdt metaObj : metadata){
            fieldNames.add(metaObj.Field_Name__c);
            mapFieldNameWithMetaRecord.put(metaObj.Field_Name__c,metaObj);
        }
       /*Map<String,Decimal> mapHaDiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHaOaDiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHa_S_R_DiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHa_S_M_DiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHa_S_M_Y_3_DiscountWithPercent = new Map<String,Decimal>();
        Map<String,Decimal> mapHa_Vendor_DiscountWithPercent = new Map<String,Decimal>();
        for(Discount_Setting__mdt discountMetaObj : discountSettingMeta){
            if(discountMetaObj.FieldName__c == 'HA_Discount_Type__c'){
                mapHaDiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_OA_Discount_Type__c'){
                mapHaOaDiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_S_R_Disc__c'){
                mapHa_S_R_DiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_S_M_Disc__c'){
                mapHa_S_M_DiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_M_Y_3_Y_M_D__c'){
                mapHa_S_M_Y_3_DiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            if(discountMetaObj.FieldName__c == 'HA_Disc__c'){
                mapHa_Vendor_DiscountWithPercent.put(discountMetaObj.FieldValue__c,discountMetaObj.Discount_Percentage__c);
            }
            
        }*/
        Map<String,String> controllerField = new Map<String,String>();
        Map<String,String> coulmnLabel = Utility.getFieldLabel(fieldNames,sObjectName);
        Map<String,String> coulmnType = Utility.getFieldType(fieldNames,sObjectName);
        Map<String,Boolean> isUpdateable = Utility.getFieldIsUpdateableInfo(fieldNames,sObjectName);
        
        List<OpportunityLineItem> productList = new List<OpportunityLineItem>();

        String productQuery = 'SELECT Id,OpportunityId,Product2.IsActive,Contract_Line_Item__c,';
        for(String fieldName : fieldNames){
            productQuery += fieldName + ',';
        }
        productQuery = productQuery.removeEnd(',');
        productQuery += ' FROM OpportunityLineItem WHERE OpportunityId=:oppId';
        
        productList = Database.query(productQuery);
        List<OpportunityProductEditableList_c.ToDisplayWrapper> listToDisplayWrapper = new List<OpportunityProductEditableList_c.ToDisplayWrapper>();
        for(OpportunityLineItem prod : productList){
            OpportunityProductEditableList_c.ToDisplayWrapper toDisplayWrapper = new OpportunityProductEditableList_c.ToDisplayWrapper();
            List<OpportunityProductEditableList_c.FieldDetails> listWrapper= new List<OpportunityProductEditableList_c.FieldDetails>();
            if(recordTypeDeveloperName == Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEDEVELOPERNAME){
                if(opp.Contract.Status == 'Activated' && Date.valueof(prod.get('End_Date__c')) < Date.today()
                        && String.valueof(prod.get('Contract_Line_Item__c')) != null){
                            toDisplayWrapper.hideDelete = true;
                        }
                        else{
                            toDisplayWrapper.hideDelete = false;
                        }
            }
            toDisplayWrapper.prodId = prod.Id;
           //toDisplayWrapper.mapProductWithUnitPrice = mapProductWithUnitPrice;
            toDisplayWrapper.recordTypeName = recordTypeDeveloperName;
           // toDisplayWrapper.mapHaOaDiscountWithPercent = mapHaOaDiscountWithPercent;
           // toDisplayWrapper.mapHaDiscountWithPercent = mapHaDiscountWithPercent;
           // toDisplayWrapper.mapHa_S_R_DiscountWithPercent = mapHa_S_R_DiscountWithPercent;
           // toDisplayWrapper.mapHa_S_M_DiscountWithPercent = mapHa_S_M_DiscountWithPercent;
           // toDisplayWrapper.mapHa_S_M_Y_3_DiscountWithPercent = mapHa_S_M_Y_3_DiscountWithPercent;
            //toDisplayWrapper.mapHa_Vendor_DiscountWithPercent = mapHa_Vendor_DiscountWithPercent;
            for(String finame: fieldNames){
                OpportunityProductEditableList_c.FieldDetails Wrapper= new OpportunityProductEditableList_c.FieldDetails();
                if(finame.contains('.') == true){
                    List<String> splitStrings = finame.split('\\.');
                    String fieldNameToGet = splitStrings[1];
                    Wrapper.fieldLabel = coulmnLabel.get(finame);
                    
                    Wrapper.fieldName = finame;
                    Wrapper.fieldType = coulmnType.get(finame);
                    if(recordTypeDeveloperName == Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEDEVELOPERNAME){
                        if(prod.Product2.IsActive == false || (opp.Contract.Status == 'Activated' && Date.valueof(prod.get('End_Date__c')) < Date.today()
                        && String.valueof(prod.get('Contract_Line_Item__c')) != null)){
                            Wrapper.isEditable = false;
                            toDisplayWrapper.isRowEditable = false;
                        }
                        else{
                            Wrapper.isEditable = true;
                            toDisplayWrapper.isRowEditable = true;
                        }
                    }
                    else{
                        Wrapper.isEditable = false;
                        toDisplayWrapper.isRowEditable = true;
                    }
                    
                    
                    
                   
                    Wrapper.isEditable = false;
                    Wrapper.isRequired = true;
                    if (finame=='Product2.Name')
                    {
                        if(recordTypeDeveloperName == Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEDEVELOPERNAME){
                            
                            if ((opp.Contract.Status == 'Activated' && Date.valueof(prod.get('End_Date__c')) < Date.today()
                            && String.valueof(prod.get('Contract_Line_Item__c')) != null)) {
                                Wrapper.title = System.Label.On_Hover_Greyed_out_OLI_on_modal;
                            }
                            else if(prod.Product2.IsActive == false){
                                Wrapper.title = System.Label.On_Hover_Greyout_OLI;
                            }
                        }
                        

                        Wrapper.isProdcutName = true;
                        Wrapper.isEditable = false;
                        Wrapper.isVisible = true;
                        Wrapper.fieldValue = String.valueof(prod.getSobject(splitStrings[0]).get(splitStrings[1]));
                    }
                    else {
                        Wrapper.isProdcutName = false;
                        Wrapper.isVisible = mapFieldNameWithMetaRecord.get(finame).isVisible__c;    
                        Wrapper.fieldValue = String.valueof(prod.getSobject(splitStrings[0]).get(splitStrings[1]));
                    }
                   
                    Wrapper.isUpdateable = false;
                    Wrapper.controllingField = '';
                    Wrapper.Ptype = '';
                    Wrapper.controllingFieldValue = '';
                }
                else{
                    Wrapper.fieldLabel = coulmnLabel.get(finame);
                    Wrapper.fieldName = finame;
                    Wrapper.fieldType = coulmnType.get(finame);
                   
                    if(coulmnType.get(finame) == 'PICKLIST'){
                        controllerField = Utility.getControllingField(finame,sObjectName);
                        
                    }
                    if(controllerField.containsKey(finame)){
                                           
                        Wrapper.controllingField = controllerField.get(finame);
                        Wrapper.controllingFieldValue = String.valueof(prod.get(controllerField.get(finame)));
                    }
                    else{
                        
                        Wrapper.controllingField = '';
                        Wrapper.controllingFieldValue ='';
                    }
                    Wrapper.isProdcutName = false;
                    if(recordTypeDeveloperName == Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEDEVELOPERNAME){
                        if(prod.Product2.IsActive == false || (opp.Contract.Status == 'Activated' && Date.valueof(prod.get('End_Date__c')) < Date.today()
                        && String.valueof(prod.get('Contract_Line_Item__c')) != null)){
                            Wrapper.isEditable = false;
                        }
                        else{
                            Wrapper.isEditable = mapFieldNameWithMetaRecord.get(finame).IsEditable__c;
                        }
                    }
                    else{
                        Wrapper.isEditable = mapFieldNameWithMetaRecord.get(finame).IsEditable__c;  
                    }
                    
                    if(String.isNotBlank(Wrapper.controllingField) && prod.get(Wrapper.controllingField) == null){
            
                        //Wrapper.isEditable = false;
                                              
                    } 
                    
                    Wrapper.isRequired = mapFieldNameWithMetaRecord.get(finame).isRequired__c;
                    Wrapper.isVisible = mapFieldNameWithMetaRecord.get(finame).isVisible__c;
                    if(Wrapper.fieldType == 'DATE' && prod.get(finame)!=null){
                        Wrapper.fieldValue = String.valueof(prod.get(finame)).removeEnd(' 00:00:00'); 
                    }else{
                        
                        Wrapper.fieldValue = String.valueof(prod.get(finame));
                    }
                    
                    Wrapper.isUpdateable = isUpdateable.get(finame);
                    Wrapper.Ptype = '';
                }
                listWrapper.add(Wrapper);
            }
            toDisplayWrapper.fileDetailWrapper = listWrapper;
            listToDisplayWrapper.add(toDisplayWrapper);
        }
        System.debug('List to Display Wrapper---'+listToDisplayWrapper);
        return listToDisplayWrapper;
        
        
    }
   
    public class FieldDetails{
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String fieldType{get;set;}
        @AuraEnabled
        public String fieldLabel{get;set;}
        @AuraEnabled
        public String title{get;set;}
        @AuraEnabled
        public String fieldValue{get;set;}
        @AuraEnabled
        public Boolean isRequired{get;set;}
        @AuraEnabled
        public boolean isEditable{get;set;}
        @AuraEnabled
        public boolean isVisible{get;set;}
        @AuraEnabled
        public boolean isProdcutName{get;set;}
        @AuraEnabled
        public boolean isUpdateable{get;set;}
        @AuraEnabled
        public String controllingField{get;set;}
        @AuraEnabled
        public String pType{get;set;}
        @AuraEnabled
        public String controllingFieldValue{get;set;}
       
        
    }  
    public class toDisplayWrapper{
        @AuraEnabled
        public String prodId{get;set;}
        @AuraEnabled
        public String recordTypeName{get;set;}
        @AuraEnabled
        public boolean hideDelete{get;set;}
        @AuraEnabled
        public boolean isRowEditable{get;set;}
        @AuraEnabled
        public Map<Id,Decimal> mapProductWithUnitPrice{get;set;}
        @AuraEnabled
        public Map<String,Decimal> mapHaOaDiscountWithPercent{get;set;}
        @AuraEnabled
        public Map<String,Decimal> mapHaDiscountWithPercent{get;set;}
        @AuraEnabled
        public Map<String,Decimal> mapHa_S_R_DiscountWithPercent{get;set;}
        @AuraEnabled
        public Map<String,Decimal> mapHa_S_M_DiscountWithPercent{get;set;}
        @AuraEnabled
        public Map<String,Decimal> mapHa_S_M_Y_3_DiscountWithPercent{get;set;}
        @AuraEnabled
        public Map<String,Decimal> mapHa_Vendor_DiscountWithPercent{get;set;}
        @AuraEnabled
        public List<OpportunityProductEditableList_c.FieldDetails> fileDetailWrapper{get;set;}
    }
}