trigger ContractTrigger on Contract (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    System.debug('ContractTrigger executing');
    TriggerDispatcher.Run(new ContractTriggerHandler());
}