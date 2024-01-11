trigger Fon_SubscriptionLineTriggerDomain on OrderApi__Subscription_Line__c (after insert) {
    //TriggerDispatcher.Run(new Fon_SubscriptionLineTriggerhandler());
    system.debug('***Fon_SubscriptionLineTriggerDomain***Fon_SubscriptionLineTriggerDomain');
    /*
    if(!Fon_SubscriptionLineTriggerhandler.runOnce){
        Fon_SubscriptionLineTriggerhandler.runOnce = true;
        Fon_SubscriptionLineTriggerhandler.updateSubscriptionLine(trigger.New);
    }
    */
}