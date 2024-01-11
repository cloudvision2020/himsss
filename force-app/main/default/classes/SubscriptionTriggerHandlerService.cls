public class SubscriptionTriggerHandlerService {
	public static Boolean runOnceInsert = false;
    public static Boolean runOnce = false;
    public static void AfterInsert(Map<Id, OrderApi__Subscription__c> newItems){
        system.debug('***SubscriptionTriggerHandlerService AfterInsert***');
        List<OrderApi__Subscription__c> updateSubscription = new List<OrderApi__Subscription__c>();
        for(OrderApi__Subscription__c sub : [Select Id, OrderApi__Item__r.Is_Entity__c,OrderApi__Entity__c from OrderApi__Subscription__c where Id=:newItems.keyset()]) {
            system.debug('sub : '+sub);
            if(sub.OrderApi__Item__r.Is_Entity__c && sub.OrderApi__Entity__c != 'Account'){
                OrderApi__Subscription__c subNew = new OrderApi__Subscription__c();
                subNew.OrderApi__Entity__c = 'Account'; 
                subNew.Id = sub.Id;
                updateSubscription.add(subNew);
            }
        }

        if(updateSubscription.size() > 0){
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', true);
                update updateSubscription;
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', false);
        }
    }
    
    public static void AfterUpdate(Map<Id, OrderApi__Subscription__c> newItems, Map<Id, OrderApi__Subscription__c> oldItems) {
        system.debug('***SubscriptionTriggerHandlerService AfterUpdate***');
        List<Contact> conList = new List<Contact>();
        Set<Id> contactId = new Set<Id>();
        Set<Id> checkDuplicateContactIds = new Set<Id>();
        Map<Id, Id> mapConAssign = new Map<Id, Id>();
        Map<Id, OrderApi__Subscription__c> mapConSubs = new Map<Id, OrderApi__Subscription__c>();
        Boolean isCorporateMembership = false;
        List<OrderApi__Assignment__c> assignments = new List<OrderApi__Assignment__c>();
        List<OrderApi__Subscription__c> subscriptions = [SELECT Id, OrderApi__Status__c,OrderApi__Contact__c,OrderApi__Item__r.Free_Chapter_member_included__c,OrderApi__Item__r.Individual_Membership__c,OrderApi__Cancelled_Reason__c,
                                                             OrderApi__Contact__r.Opt_out_of_Chapter_Membership__c,OrderApi__Contact__r.Chapter_Complimentary_Membership__c,OrderApi__Cancelled_Date__c,OrderApi__Is_Cancelled__c,
                                                         	(SELECT id,OrderApi__Contact__c, OrderApi__Is_Active__c 
                                                             FROM OrderApi__Assignments__r ) 
                                                         FROM OrderApi__Subscription__c 
                                                         WHERE Id=:newItems.keyset()];
        system.debug('subscriptions : '+subscriptions);
        for(OrderApi__Subscription__c sub : subscriptions) {
        //for(OrderApi__Subscription__c sub : newItems.values()) {
            system.debug('AfterUpdate sub : '+sub);
            if(sub.OrderApi__Status__c == 'Expired' && String.isNotBlank(sub.OrderApi__Contact__r.Chapter_Complimentary_Membership__c)){
                contact con = new contact();
                con.Id = sub.OrderApi__Contact__c;
                con.Chapter_Complimentary_Membership__c = '';
                if(!checkDuplicateContactIds.contains(con.Id)){
                    conList.add(con);
                    checkDuplicateContactIds.add(con.Id);
                }
                
            }
            if(sub.OrderApi__Item__r.Free_Chapter_member_included__c && sub.OrderApi__Status__c == 'Active' &&
              	String.isNotBlank(sub.OrderApi__Contact__r.Chapter_Complimentary_Membership__c) &&
              	sub.OrderApi__Contact__r.Opt_out_of_Chapter_Membership__c == 'No'){
                contactId.add(sub.OrderApi__Contact__c);
            }
            if(sub.OrderApi__Item__r.Individual_Membership__c != null){
                isCorporateMembership = true;
                system.debug('Assignment : '+sub.OrderApi__Assignments__r);
                if(sub.OrderApi__Assignments__r.size() > 0){
                    for(OrderApi__Assignment__c assgn: sub.OrderApi__Assignments__r){
                        mapConAssign.put(assgn.OrderApi__Contact__c,sub.OrderApi__Item__r.Individual_Membership__c);
                        mapConSubs.put(assgn.OrderApi__Contact__c,sub);
                    }
                }
            }
        }
        
        system.debug('conList : '+conList);
        system.debug('contactId : '+contactId);
        system.debug('mapConAssign : '+mapConAssign);
        system.debug('mapConAssign : '+mapConAssign);
        system.debug('isCorporateMembership : '+isCorporateMembership);
        
        // Once individual membership expire removing the chapter reference from the contact
        if(conList.size() > 0){
            update conList;    
        }
        
        // Creating the Chapter Subscription once individual membership created
        if(contactId.size() > 0){
            List<Contact> contactList = [Select Id, Name,AccountId, Chapter_Complimentary_Membership__c, Opt_out_of_Chapter_Membership__c 
                                         from contact
                                        where Id IN: contactId];
            system.debug('contactList : '+contactList);
            Framework.Dispatcher.disableTriggerInContext.put('Contact', true);
            	FON_ContactAssignmentTriggerService.createSalesOrder(contactList,null);
            Framework.Dispatcher.disableTriggerInContext.put('Contact', false);
            
        }
        
        // Cancelled the related Individual Membership by checking the assignments
        if(mapConAssign.size() > 0 && isCorporateMembership && mapConSubs.size() > 0){
            List<OrderApi__Subscription__c> individualSubs = [SELECT Id,OrderApi__Contact__c,OrderApi__Status__c,OrderApi__Cancelled_Date__c,OrderApi__Cancelled_Reason__c,OrderApi__Is_Cancelled__c
                                                FROM OrderApi__Subscription__c
                                               WHERE OrderApi__Contact__c IN: mapConAssign.Keyset()
                                               AND OrderApi__Item__c IN: mapConAssign.values()];
            List<OrderApi__Subscription__c> updateSubscriptions = new List<OrderApi__Subscription__c>();
            if(individualSubs.size() > 0){
                for(OrderApi__Subscription__c sub: individualSubs){
                    if(mapConSubs.containsKey(sub.OrderApi__Contact__c)){
                        OrderApi__Subscription__c corporateSub = mapConSubs.get(sub.OrderApi__Contact__c); 
                    	sub.OrderApi__Status__c = corporateSub.OrderApi__Status__c;
                        sub.OrderApi__Cancelled_Date__c = corporateSub.OrderApi__Cancelled_Date__c;
                        sub.OrderApi__Cancelled_Reason__c = corporateSub.OrderApi__Cancelled_Reason__c;
                        sub.OrderApi__Is_Cancelled__c = corporateSub.OrderApi__Is_Cancelled__c;
                        updateSubscriptions.add(sub);
                    }
                }
                system.debug('updateSubscriptions : '+updateSubscriptions);
                if(updateSubscriptions.size() > 0){
                    Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', true);
                        update updateSubscriptions;
                    Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', false);
                }
            }
        }
    }
    
}