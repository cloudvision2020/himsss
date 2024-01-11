public class Fon_ContactTriggerHandler implements TriggerHandlerInterface{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public Boolean IsDisabled(){
        system.debug('***Fon_ContactTriggerHandler IsDisabled***');
        if (TriggerSettings__c.getInstance('Contact').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<SObject> newItems) {}
     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        FON_ContactAssignmentTriggerService.updateContactOpOutChapterMembership((List<Contact>)newItems.values(), (Map<Id,Contact>)oldItems);
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
	}
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        system.debug('***Fon_ContactTriggerDomain afterUpdate***');
        if(!FON_ContactAssignmentTriggerService.runOnce){
            FON_ContactAssignmentTriggerService.runOnce = true;
            FON_ContactAssignmentTriggerService.createSalesOrder((List<Contact>)newItems.values(), (Map<Id,Contact>)oldItems);
        }
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    public static void createSubscription(Map<Id, SObject> newItems,Map<Id, SObject> oldItems){
    }

}