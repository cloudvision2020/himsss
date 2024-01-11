trigger BadgeTrigger on OrderApi__Badge__c (after insert, after update, before delete,before insert) {
    TriggerDispatcher.Run(new BadgeTriggerHandler());
}