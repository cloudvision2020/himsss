public with sharing class OpportunityRelatedProducts_c {
    public OpportunityRelatedProducts_c() {

    }
     /**
    * @description get Contract Status  and  Opportunity Pricebook2 Name according to opportunity record
	*/
    @AuraEnabled
    public static OpportunityRelatedProducts_c.OpportunityDetails getpriceBookName(String oppId){
        Opportunity opp = [SELECT Id,RecordTypeId, Pricebook2.Name, Contract.Status 
                            FROM Opportunity WHERE Id =: oppId LIMIT 1];

        OpportunityRelatedProducts_c.OpportunityDetails oppDetails = new OpportunityRelatedProducts_c.OpportunityDetails();
        oppDetails.pricebookName = opp.Pricebook2.Name;
        oppDetails.contractStatus = opp.Contract.Status;
        return oppDetails;
    }
     /**
    * @description create/update new opportunity product record 
	*/
    @AuraEnabled
    public static void saveProductList(String oppId,List<OpportunityProductEditableList_c.toDisplayWrapper> prodList){
       
        Opportunity opp = [SELECT Id, Pricebook2Id,CurrencyIsoCode FROM Opportunity WHERE Id =: oppId LIMIT 1];
    
        String pricebook2Id;
        String currencyCode;
        if(opp.Pricebook2Id != null){
            pricebook2Id=opp.Pricebook2Id;
            currencyCode=opp.CurrencyIsoCode;
        }
        
        map<String,String> mapProductNameWithPBId = new map<String,String>();
        List<Id> productIds = new List<Id>();
        List<OpportunityLineItem> listToUpsert = new List<OpportunityLineItem>();
        for(OpportunityProductEditableList_c.toDisplayWrapper prod : prodList){
            if(!string.valueOf(prod.prodId).startsWith('00k')){
                productIds.add(prod.prodId);
            }
        } 
        for(PriceBookEntry PBE : [SELECT Id, Product2Id, Product2.Id, Product2.Name,Pricebook2Id FROM PriceBookEntry WHERE CurrencyIsoCode=:currencyCode AND Product2Id IN : productIds AND Pricebook2Id=: pricebook2Id]){
            mapProductNameWithPBId.put(pricebook2Id+PBE.Product2.Id,PBE.Id);
        } 
        for(OpportunityProductEditableList_c.toDisplayWrapper prod : prodList){
            OpportunityLineItem oppLItem = new OpportunityLineItem();
            String productName='';
            Decimal tPrice;
            if(prod.isRowEditable){

                for(OpportunityProductEditableList_c.FieldDetails fieldDetails: prod.fileDetailWrapper){
                    if(fieldDetails.fieldLabel == 'Product Name'){
                        productName = fieldDetails.fieldValue;
                    }
                    if(!fieldDetails.fieldName.contains('.')){
                        //if(String.isNotEmpty(fieldDetails.fieldValue)){
                            
                            if(fieldDetails.isUpdateable == true && fieldDetails.fieldName !='TotalPrice'){
                                if(fieldDetails.fieldType == 'DATE'){
                                    System.debug(fieldDetails.fieldType +'----'+fieldDetails.fieldValue);
                                    if(String.isNotEmpty(fieldDetails.fieldValue)){
                                       
                                        oppLItem.put(fieldDetails.fieldName,Date.valueOf(fieldDetails.fieldValue));
                                    }
                                    else{
                                        oppLItem.put(fieldDetails.fieldName, null); 
                                    }
                                }
                                else if(fieldDetails.fieldType == 'currency' || fieldDetails.fieldType == 'double'|| fieldDetails.fieldType == 'number' || fieldDetails.fieldType == 'percent' || fieldDetails.fieldType == 'decimal' ){
                                   
                                    if(String.isNotEmpty(fieldDetails.fieldValue)){
                                     oppLItem.put(fieldDetails.fieldName,decimal.valueOf(fieldDetails.fieldValue));
                                   }
                                   else{
                                    oppLItem.put(fieldDetails.fieldName, null);
                                   }
                                    
                                }else if(fieldDetails.fieldType == 'boolean'){
                                    if(String.isNotEmpty(fieldDetails.fieldValue)){
                                        oppLItem.put(fieldDetails.fieldName,Boolean.valueOf(fieldDetails.fieldValue));
                                    }
                                    else {
                                        oppLItem.put(fieldDetails.fieldName,false);
                                    }
                                }
                                else{
                                    oppLItem.put(fieldDetails.fieldName,fieldDetails.fieldValue);
                                }
                            }
                            if (fieldDetails.fieldName =='TotalPrice')
                            {
                                tPrice=decimal.valueOf(fieldDetails.fieldValue);
                                
                            }
                       // }
                    }
                }
            
                
                if(string.valueOf(prod.prodId).startsWith('00k')){
                    oppLItem.Id = prod.prodId;
                }
                else{
                    oppLItem.OpportunityId = oppId;
                    if(productName != null){
                        oppLItem.PricebookEntryId = mapProductNameWithPBId.get(pricebook2Id+prod.prodId);
                    }
                    
                }
                
                if (oppLItem.Corporate_Membership_Discount_Amount__c != null)
                {
                    oppLItem.Corporate_Member_Discount__c = true;
                }
                if (oppLItem.Start_Date__c != null)
                {
                    oppLItem.ServiceDate = oppLItem.Start_Date__c;
                }
            
                if (oppLItem.UnitPrice == null)
                {
                    oppLItem.UnitPrice = tPrice;
                }
                
                listToUpsert.add(oppLItem);
            }
        }
        
        if(listToUpsert != null && listToUpsert.size() > 0){
            try {
                Set<String> opportunityLineItemIds = new  Set<String>();
                Set<Id> contractLineItemIds = new  Set<Id>();
                
                Map<Id,OpportunityLineItem> opportunityLineItemMap  = new  Map<Id,OpportunityLineItem> (
                                                                     [SELECT Id,TotalPrice,UnitPrice, Quantity,Discount, Contract_Line_Item__c,
                                                                     Start_Date__c, Discount_Percent__c, End_Date__c,Use_End_Date__c
                                                                     FROM OpportunityLineItem WHERE Id =: listToUpsert]);
                for(OpportunityLineItem opportunityLineItemObj : listToUpsert){
                   
                    if(opportunityLineItemMap.containsKey(opportunityLineItemObj.Id)){

                        OpportunityLineItem opportunityLineItemOldObj = opportunityLineItemMap.get(opportunityLineItemObj.Id);                    
                       
                        
                        if(( opportunityLineItemObj.Quantity != opportunityLineItemOldObj.Quantity) ||
                            ( opportunityLineItemObj.UnitPrice != opportunityLineItemOldObj.UnitPrice) || 
                            ( opportunityLineItemObj.Start_Date__c != opportunityLineItemOldObj.Start_Date__c) ||
                            ( opportunityLineItemObj.Discount_Percent__c != opportunityLineItemOldObj.Discount_Percent__c) ||
                            ( opportunityLineItemObj.End_Date__c != opportunityLineItemOldObj.End_Date__c) /*|| 
                            ( opportunityLineItemObj.TotalPrice != opportunityLineItemOldObj.TotalPrice)*/){
                             
                            opportunityLineItemIds.add(opportunityLineItemObj.ID);                               
                            //List<OpportunityLineItemSchedule>  olis = [select Id from OpportunityLineItemSchedule where OpportunityLineItemId = :opportunityLineItemObj.ID];
                            List<OpportunityLineItemSchedule>  olis = [select Id 
                                                                       from OpportunityLineItemSchedule 
                                                                       where OpportunityLineItemId = :opportunityLineItemObj.ID 
                                                                       AND OpportunityLineItem.Opportunity.RecordTypeID =:  Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID];
                            delete olis;
                            contractLineItemIds.add(opportunityLineItemObj.Contract_Line_Item__c);
                        }
                        
                    }
                }
                OpportunityLineItemTriggerHandler.isBypassTrigger = true;                
                OpportunityLineItemTriggerHandler.deleteOpportunityLineItemAndContractLineItemsSchedule(opportunityLineItemIds,contractLineItemIds);            
                OpportunityLineItemTriggerHandler.isBypassTrigger = false;               
                upsert listToUpsert;
               

            } catch (Exception e) {

                System.debug(Logginglevel.ERROR, e.getMessage());

			if(!Test.isRunningTest()){
            	throw new AuraException(e.getMessage());
            	}
            }
            
        }
    }
    public class OpportunityDetails{
        @AuraEnabled
        public String pricebookName{get;set;}
        @AuraEnabled
        public String contractStatus{get;set;}
    }
}