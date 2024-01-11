global class Fon_SubscriptionLineTriggerDomain extends Framework.Domain {
    public Fon_SubscriptionLineTriggerDomain(List<OrderApi__Subscription_Line__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_SubscriptionLineTriggerDomain(sObjectList);
        }
    }
	
    public override void afterInsert(){
        Framework.Log.push(Fon_SubscriptionLineTriggerDomain.class.getName(),'afterInsert');
        System.debug('Fon_SubscriptionLineTriggerDomain :: afterInsert');
        if(!Fon_SubscriptionLineTriggerhandler.runOnce){
            Fon_SubscriptionLineTriggerhandler.runOnce = true;
            Fon_SubscriptionLineTriggerhandler.updateSubscriptionLine((OrderApi__Subscription_Line__c[]) records);
        }
        Framework.Log.pop();
    }
    
}