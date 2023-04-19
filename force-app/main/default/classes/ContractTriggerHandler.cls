public class ContractTriggerHandler implements TriggerHandlerInterface
{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public Boolean IsDisabled()
    {
        System.debug('ContractTriggerHandler.IsDisabled executing');
        if (TriggerSettings__c.getInstance('Contract').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<SObject> newItems) {

        validateContract(newItems);
    }
     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {

        CreateContractLineItems((Map<Id, Contract>)newItems);
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    /**
    * @description Only 1 contract is allowed per opportunity, throw error if opportunity already have Contract
	*/
    private void validateContract(List<Contract> contracts){
        
        Set<Id> opportunityIdsToCheck = new Set<Id> ();
        Set<Id> opportunityIdsHavingContractRecord = new Set<Id> ();
        
        for(Contract contractObj : contracts){
            
            if(contractObj.Opportunity__c != null){
                opportunityIdsToCheck.add(contractObj.Opportunity__c);
            }
        }
       
        for(Contract contractObj : [SELECT Id,Opportunity__c FROM Contract
                                    WHERE Opportunity__r.RecordTypeId =: Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID 
                                    AND Opportunity__c 
                                    IN :opportunityIdsToCheck])
        {
            opportunityIdsHavingContractRecord.add(contractObj.Opportunity__c);
        }
        
        for(Contract contractObj : contracts){
            
            if(contractObj.Opportunity__c != null && 
               opportunityIdsHavingContractRecord.contains(contractObj.Opportunity__c))
            {
                // Error if opportunity have Contract
                contractObj.addError(Label.Single_Contract_Under_Opportunity_Error);
            }
        }
        
    }
    /**
    * @description create contract line items after  creating Contract Record
	*/
    private void CreateContractLineItems(Map<Id, Contract> newItems)
    {
        Set<String> opportunityIds = new Set<String>();
        List<Contract> contractToProcess = new List<Contract>();  
        
        for(Contract contractObj : newItems.values())
        {
            if(contractObj.RecordTypeID == Constants.CONTRACT_HIMSS_MEDIA_RECORDTYPEID){
                opportunityIds.add(contractObj.Opportunity__c);
                contractToProcess.add(contractObj);    
            }
        }
        //get fields mapying  from Opportunity Line Item 
        Map<String, List<OpportunityLineItem>> opportunityIdWithOpportunityLineItemsMap = new Map<String, List<OpportunityLineItem>>();
        Map<Id,OpportunityLineItem> opportunityLineItemIdWithopportunityLineItemObjMap = new Map<Id,OpportunityLineItem>(
                                                                                        [SELECT Id, OpportunityId,Name,Ad_Size2__c,Brand__c, CurrencyISOCode, 
                                                                                        Discount_Percent__c,End_Date__c,Description, ListPrice, 
                                                                                        ProductCode, Product2.Family, 
                                                                                        Product2.Name,Quantity,Rate_Type__c, Region__c, UnitPrice, 
                                                                                        Start_Date__c, TotalPrice 
                                                                                        FROM OpportunityLineItem
                                                                                        WHERE OpportunityId =:opportunityIds]
                                                                                    );

        for(OpportunityLineItem opportunityLineItemObj : opportunityLineItemIdWithopportunityLineItemObjMap.values())
        {
            
            if(!opportunityIdWithOpportunityLineItemsMap.containsKey(opportunityLineItemObj.OpportunityId)){
                opportunityIdWithOpportunityLineItemsMap.put(opportunityLineItemObj.OpportunityId, new List<OpportunityLineItem>());
            }
            
            opportunityIdWithOpportunityLineItemsMap.get(opportunityLineItemObj.OpportunityId).add(opportunityLineItemObj);
            
        }
        //get Contract Line Items list with field maping from opportunity Line Items 
        List<Contract_Line_Item__c> contractLineItems = Utility.getContractLineItems(contractToProcess, opportunityIdWithOpportunityLineItemsMap);
       
        if(!contractLineItems.isEmpty()){
            
            insert contractLineItems;
            OpportunityLineItemTriggerHandler.isBypassTrigger = true;
            updateOpportunityLineItems(contractLineItems,opportunityLineItemIdWithopportunityLineItemObjMap);
                       
        }
    }
    
     /**
    * @description update opportunity line items field Name 'Contract_Line_Item__c' when contract line item create
	*/
    private void updateOpportunityLineItems(List<Contract_Line_Item__c> contractLineItems , 
                                                Map<Id,OpportunityLineItem> opportunityLineItemIdWithopportunityLineItemObjMap)
    {
        List<OpportunityLineItem> opportunityLineItems = new  List<OpportunityLineItem>();
        for(Contract_Line_Item__c ContractLineItemObj : contractLineItems){

            if(opportunityLineItemIdWithopportunityLineItemObjMap.containsKey(ContractLineItemObj.Opportunity_Line_Item_Id__c)){
                OpportunityLineItem opportunityLineItemObj = opportunityLineItemIdWithopportunityLineItemObjMap.get(ContractLineItemObj.Opportunity_Line_Item_Id__c);
                opportunityLineItemObj.Contract_Line_Item__c = ContractLineItemObj.Id;
                opportunityLineItems.add(opportunityLineItemObj);

            }

        }
        if(!opportunityLineItems.isEmpty()){
        
            update opportunityLineItems;
        }
    }
    
}