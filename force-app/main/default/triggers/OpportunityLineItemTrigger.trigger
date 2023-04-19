trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    System.debug('OpportunityLineItemTrigger executing');
    TriggerDispatcher.Run(new OpportunityLineItemTriggerHandler());
}