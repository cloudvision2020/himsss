public class ContractLineItemTriggerHandler implements TriggerHandlerInterface
{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public Boolean IsDisabled()
    {
        System.debug('ContractLineItemTriggerHandler.IsDisabled executing');
        if (TriggerSettings__c.getInstance('Contract_Line_Item__c').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<SObject> newItems) {}
     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {

        createContractLineItemSchedule((Map<Id, Contract_Line_Item__c>) newItems);
        GenerateNewContractLineItemDiscount.checkIfItemIsDiscounted((Map<Id, Contract_Line_Item__c>) newItems);
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        
        
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    /**
    * @description  Create Contract Line Item Schedule after creating Contract Line Items
	*/
    private void createContractLineItemSchedule(Map<Id, Contract_Line_Item__c> newItems){
        
        Set<String> opportunityLineItemIds = new Set<String>();
        for(Contract_Line_Item__c  contractLineItemObj : newItems.values()){

            opportunityLineItemIds.add(contractLineItemObj.Opportunity_Line_Item_Id__c);
            

        }
        List<OpportunityLineItemSchedule> opportunityLineItemScheduleLIst  =[SELECT Id ,Revenue,  OpportunityLineItem.OpportunityId, OpportunityLineItemId,ScheduleDate, 
                                                                                OpportunityLineItem.UnitPrice,
                                                                                OpportunityLineItem.Rate_Type__c
                                                                                FROM OpportunityLineItemSchedule
                                                                                WHERE OpportunityLineItemId =: opportunityLineItemIds];
        OpportunityLineItemTriggerHandler.createContractLineItemSchedule(newItems.keySet(),opportunityLineItemScheduleLIst);
        
    }
}