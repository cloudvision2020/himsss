trigger OpportunityLineItemScheduleTrigger on OpportunityLineItemSchedule (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
  System.debug('OpportunityLineItemScheduleTrigHandler executing');
  TriggerDispatcher.Run(new OpportunityLineItemScheduleTrigHandler()); 
}