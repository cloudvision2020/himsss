trigger AssignmentTriggerNew on OrderApi__Assignment__c (before insert, after insert, after update) {
    system.debug('***AssignmentTrigger***');
    TriggerDispatcher.Run(new AssignmentTriggerHandler());
}