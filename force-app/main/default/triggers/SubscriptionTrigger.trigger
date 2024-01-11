/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
trigger SubscriptionTrigger on OrderApi__Subscription__c (after insert, after update) {
    TriggerDispatcher.Run(new SubscriptionTriggerHandler());
}