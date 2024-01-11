/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SubscriptionTriggerHandler implements TriggerHandlerInterface{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public Boolean IsDisabled(){
        if(TriggerSettings__c.getInstance('OrderApi__Subscription__c') == null){
            return TriggerDisabled;
        }
        if (TriggerSettings__c.getInstance('OrderApi__Subscription__c').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
   /* public Boolean IsDisabled() {
    try {
        TriggerSettings__c triggerSettings = TriggerSettings__c.getInstance('OrderApi__Subscription__c');

        if (triggerSettings != null && triggerSettings.TriggerDisabled__c) {
            return true;
        } else {
            return TriggerDisabled;
        }
    } catch (Exception e) {
        // Log the exception or handle it appropriately
        System.debug('Error in IsDisabled method: ' + e.getMessage());
        return false;
    }
}*/

 
    public void BeforeInsert(List<SObject> newItems) {}
     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        system.debug('***SubscriptionTriggerHandler AfterInsert***');
        if(!SubscriptionTriggerHandlerService.runOnceInsert){
            SubscriptionTriggerHandlerService.runOnceInsert = true;
            SubscriptionTriggerHandlerService.AfterInsert((Map<Id, OrderApi__Subscription__c>) newItems);
        }
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        system.debug('***SubscriptionTriggerHandler AfterUpdate***');
        if(!SubscriptionTriggerHandlerService.runOnce){
            SubscriptionTriggerHandlerService.runOnce = true;
            SubscriptionTriggerHandlerService.AfterUpdate((Map<Id, OrderApi__Subscription__c>) newItems, (Map<Id, OrderApi__Subscription__c>) oldItems);
        }
     }
    
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
   
    
}