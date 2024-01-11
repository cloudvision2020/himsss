public class Fon_SubscriptionLineTriggerhandler {
    public static Boolean runOnce = false;
    public static void updateSubscriptionLine(List<OrderApi__Subscription_Line__c> subsLines){
        system.debug('***updateSubscription***');
        Set<Id> subsLineIds = new Set<Id>();
        Map<Id,Date> solIdTermGraceDateMap = new Map<Id,Date>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> chapterSubsLine = new Set<Id>();
        
        List<OrderApi__Subscription__c> deleteSubscription = new List<OrderApi__Subscription__c>();
        List<OrderApi__Renewal__c> deleteTerm = new List<OrderApi__Renewal__c>();
        List<OrderApi__Subscription_Line__c> newSubsLines = new List<OrderApi__Subscription_Line__c>();

        Set<Id> deleteSubscriptionIds = new Set<Id>();
        Set<Id> deleteTermIds = new Set<Id>();

        for(OrderApi__Subscription_Line__c subs: subsLines){
            system.debug('subs : '+subs);
            if(subs.Is_Renewal__c == false){
            	subsLineIds.add(subs.Id);    
            }
        }
        
        List<OrderApi__Subscription_Line__c> subsLineList = [SELECT Id,OrderApi__Item__c,OrderApi__Item__r.Name,OrderApi__Item_Class__c,OrderApi__Subscription__c,Is_Renewal__c, 
                                                      	       	OrderApi__Item_Class__r.Name,OrderApi__Subscription__r.OrderApi__Contact__c,OrderApi__Sales_Order_Line__c,
                                                             	OrderApi__Subscription__r.OrderApi__Item__r.Free_Chapter_member_included__c,OrderApi__Term__c,
                                                             	OrderApi__Subscription__r.OrderApi__Contact__r.Chapter_Complimentary_Membership__c,OrderApi__Term__r.OrderApi__Grace_Period_End_Date__c,
                                                             	OrderApi__Subscription__r.OrderApi__Contact__r.Opt_out_of_Chapter_Membership__c
                                                             FROM OrderApi__Subscription_Line__c 
                                                             WHERE Id IN : subsLineIds
                                                             AND OrderApi__Subscription__r.OrderApi__Status__c =: 'Active'
                                                             AND OrderApi__Item__r.Name LIKE '%HIMSS%'
                                                             AND (NOT OrderApi__Item__r.Name LIKE '%Annual Membership%') 
                                                             AND OrderApi__Item_Class__r.Name = 'Chapter Memberships'
                                                             AND OrderApi__Subscription__r.OrderApi__Item_Class__r.Name = 'Chapter Memberships'
                                                             AND Is_Renewal__c = false];
        if(subsLineList.size() > 0){
            system.debug('subsLineList : '+subsLineList);
            system.debug('subsLineList Item Name : '+subsLineList[0].OrderApi__Item__r.Name);
            system.debug('subsLineList Individual : '+subsLineList[0].OrderApi__Subscription__r.OrderApi__Item__r.Free_Chapter_member_included__c);
            system.debug('subsLineList Complimentary Membership : '+subsLineList[0].OrderApi__Subscription__r.OrderApi__Contact__r.Chapter_Complimentary_Membership__c);
            system.debug('subsLineList Opt out : '+subsLineList[0].OrderApi__Subscription__r.OrderApi__Contact__r.Opt_out_of_Chapter_Membership__c);
            for(OrderApi__Subscription_Line__c subs: subsLineList){
                contactIds.add(subs.OrderApi__Subscription__r.OrderApi__Contact__c);
                //chapterSubsLine.add(subs.Id);
            }
            system.debug('contactIds : '+contactIds);
            Map<Id,OrderApi__Subscription__c> mapPrimarySubscription = FON_ContactAssignmentTriggerService.fetchPrimaryMembership(contactIds);
            system.debug('mapPrimarySubscription : '+mapPrimarySubscription);
            
            for(OrderApi__Subscription_Line__c subsLine: subsLineList){
                deleteSubscriptionIds.add(subsLine.OrderApi__Subscription__c);
                deleteTermIds.add(subsLine.OrderApi__Term__c);
                subsLine.OrderApi__Subscription__c = mapPrimarySubscription.get(subsLine.OrderApi__Subscription__r.OrderApi__Contact__c).Id;
                OrderApi__Renewal__c term = mapPrimarySubscription.get(subsLine.OrderApi__Subscription__r.OrderApi__Contact__c).OrderApi__Renewals__r;
                system.debug('term : '+term);
                subsLine.OrderApi__Term__c = term.Id;
                newSubsLines.add(subsLine);
                solIdTermGraceDateMap.put(subsLine.OrderApi__Sales_Order_Line__c,subsLine.OrderApi__Term__r.OrderApi__Grace_Period_End_Date__c);
                
            }
            system.debug('deleteSubscriptionIds : '+deleteSubscriptionIds);
            system.debug('deleteTermIds : '+deleteTermIds);
            system.debug('newSubsLines : '+newSubsLines);
            if(newSubsLines.size() > 0){
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription_Line__c', true);
                    update newSubsLines;
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription_Line__c', false);
                
                List<OrderApi__Badge__c> chapterBadges = [SELECT Id,OrderApi__Contact__c,OrderApi__Is_Active__c,OrderApi__Badge_Type__r.Name,
                                                         	OrderApi__Sales_Order_Line__c,OrderApi__Badge_Type__c,OrderApi__Item__c,OrderApi__Expired_Date__c 
                                                         FROM OrderApi__Badge__c
                                                         WHERE OrderApi__Is_Active__c = true
                                                         AND OrderApi__Sales_Order_Line__c IN : solIdTermGraceDateMap.Keyset()];
                system.debug('chapterBadges : '+chapterBadges);
                
                system.debug('solIdTermGraceDateMap : '+solIdTermGraceDateMap);
                for(OrderApi__Badge__c badge: chapterBadges){
                    if(solIdTermGraceDateMap.containsKey(badge.OrderApi__Sales_Order_Line__c)){
                        system.debug('Term end date : '+solIdTermGraceDateMap.get(badge.OrderApi__Sales_Order_Line__c));
                    	badge.OrderApi__Expired_Date__c = solIdTermGraceDateMap.get(badge.OrderApi__Sales_Order_Line__c);
                        badge.OrderApi__Sales_Order_Line__c = null;
                    }
                }
                
                if(chapterBadges.size() > 0){
                    Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Badge__c', true);
                        update chapterBadges;
                    Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Badge__c', false);
                }
            }
            if(deleteSubscriptionIds.size() > 0 && deleteTermIds.size() > 0){
                deleteRecords(deleteSubscriptionIds, deleteTermIds,contactIds);
            }
        }
        
        
    }
    //@future
    public static void deleteRecords(Set<Id> subscriptionIds, Set<Id> TermIds,Set<Id> contactIds){
        system.debug('***future deleteRecords***');
        List<OrderApi__Subscription__c> subscriptions = fetchActiveSubscriptionWithoutLine(contactIds);
        List<OrderApi__Subscription__c> deleteSubs = new List<OrderApi__Subscription__c>();
        List<OrderApi__Renewal__c> deleteTerms = new List<OrderApi__Renewal__c>();
        
        for(OrderApi__Subscription__c subs: subscriptions){
            system.debug('Subs Line : '+subs.OrderApi__Subscription_Lines__r);
            if(subs.OrderApi__Subscription_Lines__r == null || subs.OrderApi__Subscription_Lines__r.size() == 0){
                deleteSubs.add(subs);
                if(subs.OrderApi__Renewals__r.size() > 0){
                	deleteTerms.addAll(subs.OrderApi__Renewals__r);    
                }
            }
        }
        system.debug('deleteSubs : '+deleteSubs);
        system.debug('deleteTerms : '+deleteTerms);
        
        if(deleteSubs.size() > 0 && deleteTerms.size() > 0){
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Renewal__c', true);
                delete deleteTerms;
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Renewal__c', false);
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', true);
                delete deleteSubs;
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', false);
        }
        /*
        List<OrderApi__Renewal__c> terms = [Select Id from OrderApi__Renewal__c Where Id In: TermIds];
        List<OrderApi__Subscription__c> subs = [Select Id from OrderApi__Subscription__c Where Id In: subscriptionIds];
        
		system.debug('terms : '+terms);
        system.debug('subs : '+subs);
        
        if(terms.size() > 0 && subs.size() > 0){
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Renewal__c', true);
                delete terms;
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Renewal__c', false);
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', true);
                delete subs;
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', false);
        }
		*/
    }
    
    public static List<OrderApi__Subscription__c> fetchActiveSubscriptionWithoutLine(Set<Id> setOfContactId){
        system.debug('***fetchActiveSubscription***');
        List<OrderApi__Subscription__c> lstSubs = [SELECT Id,
                                                   (SELECT Id,OrderApi__Item__c,
                                                    OrderApi__Subscription__r.OrderApi__Contact__c  
                                                    FROM OrderApi__Subscription_Lines__r),
                                                   (SELECT Id,OrderApi__Term_Start_Date__c,OrderApi__Term_End_Date__c,
                                                    OrderApi__Account__c    
                                                    FROM OrderApi__Renewals__r 
                                                    WHERE OrderApi__Is_Active__c = true)  
                                                   FROM OrderApi__Subscription__c   
                                                   WHERE OrderApi__Contact__c IN : setOfContactId 
                                                   AND OrderApi__Status__c =: 'Active'
                                                   AND OrderApi__Item_Class__r.Name = 'Chapter Memberships'];
        system.debug('lstSubs : '+lstSubs);                                        
        return lstSubs;
    }
}