public  without sharing class SalesOrderTriggerHandler{
    
    public static Boolean runOnce = false;
    public static void updateNetPayment(List<OrderApi__Sales_Order__c> newItems) {
        system.debug('***SalesOrderTriggerHandler updateNetPayment***');
        Set<Id> accountIds = new Set<Id>();
        for(OrderApi__Sales_Order__c so: newItems){
            if(so.OrderApi__Account__c != null){
                accountIds.add(so.OrderApi__Account__c);
            }
        }
        system.debug('accountIds : '+accountIds);
        
        Map<Id,Account> accMap = new  Map<Id,Account>([Select Id,Fon_Payment_Term__c from Account where Id In: accountIds]);
        system.debug('áccMap : '+accMap);
        
        for(OrderApi__Sales_Order__c so: newItems){
            system.debug('accMap contains : '+accMap.ContainsKey(so.OrderApi__Account__c));
            if(accMap.ContainsKey(so.OrderApi__Account__c)){
                system.debug('Account payment term : '+accMap.get(so.OrderApi__Account__c).Fon_Payment_Term__c);
                if(accMap.get(so.OrderApi__Account__c).Fon_Payment_Term__c != null){
                    so.OrderApi__Payment_Terms__c = accMap.get(so.OrderApi__Account__c).Fon_Payment_Term__c;
                }
            }
        }
    }
}