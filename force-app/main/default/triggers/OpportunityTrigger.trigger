trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    System.debug('OpportunityTrigger executing');
    TriggerDispatcher.Run(new OpportunityTriggerHandler());
}