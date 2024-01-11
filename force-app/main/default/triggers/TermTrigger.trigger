trigger TermTrigger on OrderApi__Renewal__c (before insert, after update) {
    TriggerDispatcher.Run(new TermTriggerHandler());
}