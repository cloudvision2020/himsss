/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SalesOrderLineTriggerHandler implements TriggerHandlerInterface{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getInstance('OrderApi__Sales_Order_Line__c').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<SObject> newItems) {}
     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        List<OrderApi__Sales_Order__c> updateSalesOrder = new List<OrderApi__Sales_Order__c>();

        for(OrderApi__Sales_Order_Line__c salesOrderline : [Select Id, OrderApi__Sales_Order__c, OrderApi__Item__r.Is_Entity__c from OrderApi__Sales_Order_Line__c where Id=:newItems.keyset()]) {
            if(salesOrderline.OrderApi__Item__r.Is_Entity__c){
                OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
                salesOrder.OrderApi__Entity__c = 'Account'; 
                salesOrder.Id = salesOrderline.OrderApi__Sales_Order__c;
                updateSalesOrder.add(salesOrder);
            }
        }

        if(updateSalesOrder.size() > 0){
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Sales_Order__c', true);
                update updateSalesOrder;
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Sales_Order__c', false);
        }
        
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
   
    
}