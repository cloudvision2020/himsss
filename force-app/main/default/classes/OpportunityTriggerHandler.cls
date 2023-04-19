public class OpportunityTriggerHandler implements TriggerHandlerInterface 
{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
    public static Boolean isBypassTrigger = false;

    
    /**
    * @description Checks if the trigger has been disabled either by custom setting or unit tests
	*/
    public Boolean IsDisabled()
    {
        System.debug('OpportunityTriggerHandler.IsDisabled executing');
        if (TriggerSettings__c.getInstance('Opportunity').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
    
    public void BeforeInsert(List<SObject> newItems) 
    {    
           populatePriceBookId(newItems);     
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(!isBypassTrigger){
            checkValidationAndPopulatePriceBookId((List<Opportunity>)newItems.values(), (Map<Id, Opportunity>)oldItems);    
        } 
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) {}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(!isBypassTrigger){
            isBypassTrigger = true;
            checkForCurrencyUpdate((Map<Id, Opportunity>)newItems, (Map<Id, Opportunity>)oldItems); 
        }   
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    /**
    * @description Checks if the opportunity record type or Pricebook2Id is edited on opportunity. 
    *               - If opportunity record type is edited on opportunity,
    *                   - If true, check if the opportunity has any line items.
    *                       - If there are line items then opportunity record type cannot be modified.
    *                       - If there are no line items then proceed with the opportunity record type update.
    *                           - Update Pricebook2Id on opportunity.
    *               - If Pricebook2Id is directly edited on opportunity,
    *                   - Display an error, as this is not allowed use case. 
	*/
    void checkValidationAndPopulatePriceBookId(List<Opportunity> newOpportunity, Map<Id, Opportunity> oldOpportunityMap)
    {
        List<Opportunity> opportunitiesToPopulatePriceBook = new List<Opportunity>();
        
        for(Opportunity  oppObj : newOpportunity){
           
            //If opportunity record type changed then processing the opportunity
            if(oppObj.RecordTypeId != oldOpportunityMap.get(oppObj.Id).RecordTypeId 
               && oppObj.RecordTypeId != null)
            {
                if(oppObj.HasOpportunityLineItem){
                    
                    // Error if opportunity has line items
                    oppObj.addError(Label.RT_change_on_opportuntiy_error);
                }else{
                    
                    opportunitiesToPopulatePriceBook.add(oppObj);
                }
                
            } 
            else if (oppObj.Pricebook2Id != oldOpportunityMap.get(oppObj.Id).Pricebook2Id
                     && oppObj.Pricebook2Id != null) 
            {
                oppObj.addError(Label.PB_change_on_opportuntiy_error);                  
               
            }
            
        }
        
        //If opportunity is not having line items then updating the Opportunity.Pricebook2Id 
        if(!opportunitiesToPopulatePriceBook.isEmpty()){
            populatePriceBookId(opportunitiesToPopulatePriceBook);
        }
    }
    
    /**
    * @description Populate the Opportunity.Pricebook2Id based on the opportunity recordtype to pricebook mapping maintained in custom metadata type
	*/
    void populatePriceBookId(List<SObject> newItems)
    {    
        //getting record type name with price book name 
        Map<String, String> priceBookNameByOpportunityRecordType = Utility.getPriceookNameByOpportunityRecordType();
        
        //getting price book name with price book id
        Map<String, String> priceBookNameById = Utility.getPriceBookNameById(new Set<String> (priceBookNameByOpportunityRecordType.values()));
        
        //getting record type info by recordtypeid
        Map<Id,Schema.RecordTypeInfo> recordTypeInfoById = Utility.getRecordTypeInfoById();
        
        for(Opportunity  oppObj : (List<Opportunity>)newItems){
            
            String recordTypeName = '';
            String priceBookId = '';
            String priceBookName = '';
            
            if(recordTypeInfoById.containsKey(oppObj.RecordTypeId)){
                recordTypeName = recordTypeInfoById.get(oppObj.RecordTypeId).DeveloperName;
            }
        
            if(priceBookNameByOpportunityRecordType.containsKey(recordTypeName)){
                priceBookName = priceBookNameByOpportunityRecordType.get(recordTypeName);
            }
            
            if(priceBookNameById.containsKey(priceBookName)){
                priceBookId = priceBookNameById.get(priceBookName);
            }
            
            if (String.isNotBlank(priceBookId))
            {
                oppObj.Pricebook2Id = priceBookId; 
            }
        }
    } 

    /**
    * @description Check if the currency on opportunity is modified after creation, 
    *                   -   If yes, populate the Pricebook2Id field and update the opportunity
    * //By default, whenever an opportunity's currency is modified the Pricebook2Id will be removed, hence this method
    * //By default, Opportunity's currency cannot be modified if there are line items on Opportunity
    */
    void checkForCurrencyUpdate(Map<Id, Opportunity> newItems, Map<Id, Opportunity> oldItems )
    {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Map<String,String> opportunityIdWithPriceBook2Id = new Map<String,String>();
        // Check if the fields changed
        for(Opportunity oppy : newItems.values())
        {
            if(oppy.CurrencyISOCode != oldItems.get(oppy.Id).CurrencyISOCode
                || oppy.Pricebook2Id == null)
            {
                if(oldItems.get(oppy.Id).PriceBook2Id != null){
                    opportunityIdWithPriceBook2Id.put(oppy.Id , oldItems.get(oppy.Id).PriceBook2Id);
                }
            }
        }
        List<Opportunity> opportunityList = [SELECT Id,PriceBook2Id FROM Opportunity WHERE Id =: opportunityIdWithPriceBook2Id.keySet()];
            for(Opportunity opp : opportunityList){
                if(opportunityIdWithPriceBook2Id.containsKey(opp.Id)){
                    opp.PriceBook2Id = opportunityIdWithPriceBook2Id.get(opp.Id);
                }
            }
            isBypassTrigger = true;
            update opportunityList;

       
    }
}