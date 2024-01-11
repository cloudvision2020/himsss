global class UpdateContactBatchClass implements Database.Batchable<SObject> {

    global Set<Id> contactIds;
    global Set<Id> deleteSubscriptionIds;
    global Set<Id> deleteTermIds;
    global UpdateContactBatchClass(Set<Id> ids, Set<Id> dsIds, Set<Id> dtIds) {
    //global UpdateContactBatchClass(Set<Id> ids) {
        system.debug('ids : '+ids);
        contactIds = ids;
        deleteSubscriptionIds = dsIds;
        deleteTermIds = dtIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // The start method is used to return the query locator for the records you want to process.
        // In this example, we are querying a custom object named MyObject__c.
        String query = 'SELECT Id, Name FROM contact where Id In: contactIds';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        system.debug('contactList execute : '+scope);
        /*
        if(scope.size() > 0){
        	update scope;    
        }
        */
        if(scope.size() > 0 && deleteSubscriptionIds == null && deleteTermIds == null){
        	update scope;    
        }
        if(scope.size() > 0 && deleteSubscriptionIds.size() > 0 && deleteTermIds.size() > 0){
        	List<OrderApi__Renewal__c> terms = [Select Id from OrderApi__Renewal__c Where Id In: deleteTermIds];
            List<OrderApi__Subscription__c> subs = [Select Id from OrderApi__Subscription__c Where Id In: deleteSubscriptionIds];
            if(terms.size() > 0 && subs.size() > 0){
                //delete terms;
                //delete subs;
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Renewal__c', true);
                    delete terms;
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Renewal__c', false);
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', true);
                    delete subs;
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', false);
            }    
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        // The finish method is called after all batches have been processed.
        // You can perform any final cleanup or logging here.
    }
}