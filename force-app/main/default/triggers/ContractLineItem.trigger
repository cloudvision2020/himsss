trigger ContractLineItem on Contract_Line_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    System.debug('ContractLineItemTrigger executing');
    TriggerDispatcher.Run(new ContractLineItemTriggerHandler());
}