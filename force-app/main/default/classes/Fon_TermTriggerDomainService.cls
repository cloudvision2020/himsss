public class Fon_TermTriggerDomainService {
    
      public static void AfterInsert(Map<Id, OrderApi__Renewal__c> newItems) {
        // term inserted
        List<OrderApi__Subscription__c> subscriptionsToUpdate = new List<OrderApi__Subscription__c>();
    
        for (OrderApi__Renewal__c renewalRecord : newItems.values()) {
            // subscription updation
            if (renewalRecord.OrderApi__Subscription__c != null && renewalRecord.OrderApi__Is_Active__c) {
                OrderApi__Subscription__c subscription = new OrderApi__Subscription__c();
                subscription.Id = renewalRecord.OrderApi__Subscription__c;
                subscription.Active_Term_Approved_HIMSS_CE_Hours__c = 0;
                subscription.Active_Term_Non_Approved_CE_Hours__c = 0;
                subscription.Active_Term_CE_Hours__c = 0;
                
                subscriptionsToUpdate.add(subscription);
            }
        }

        // Update sub
        if (!subscriptionsToUpdate.isEmpty()) {
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', true);
            	update subscriptionsToUpdate;
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', false);
        }
    }
    
    public static void afterUpdate(Map<Id, OrderApi__Renewal__c> newItems, Map<Id, OrderApi__Renewal__c> oldTerms) {
        // term inserted
        List<OrderApi__Subscription__c> subscriptionsToUpdate = new List<OrderApi__Subscription__c>();
    
        for (OrderApi__Renewal__c renewalRecord : newItems.values()) {
            OrderApi__Renewal__c renewalRecordOld = oldTerms.get(renewalRecord.Id);
            // subscription updation
            if (renewalRecord.OrderApi__Subscription__c != null && renewalRecord.OrderApi__Is_Active__c && renewalRecord.OrderApi__Is_Active__c != renewalRecordOld.OrderApi__Is_Active__c) {
                OrderApi__Subscription__c subscription = new OrderApi__Subscription__c();
                subscription.Id = renewalRecord.OrderApi__Subscription__c;
                subscription.Active_Term_Approved_HIMSS_CE_Hours__c = 0;
                subscription.Active_Term_Non_Approved_CE_Hours__c = 0;
                subscription.Active_Term_CE_Hours__c = 0;
                
                subscriptionsToUpdate.add(subscription);
            }
        }

        // Update sub
        if (!subscriptionsToUpdate.isEmpty()) {
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', true);
            	update subscriptionsToUpdate;
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', false);
        }
    }
}