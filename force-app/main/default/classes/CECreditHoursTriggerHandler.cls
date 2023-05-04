/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CECreditHoursTriggerHandler implements TriggerHandlerInterface{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public Boolean IsDisabled(){
        System.debug('CECreditHoursTriggerHandler.IsDisabled executing');
        if (TriggerSettings__c.getInstance('CE_Hours__c').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<SObject> newItems) {
    }
     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        
        updateSubscriptions((Map<Id, CE_Hours__c>)newItems);
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    /**
    * @description after CE Hours 
	*/
    private void updateSubscriptions(Map<Id, CE_Hours__c> newItems){
        

        // Turn OFF Subscription Routing Rule
        Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', true);

        Set<Id> setCEHours = new Set<Id>();
        
        for(CE_Hours__c cEHours : [Select Id, Term__c from CE_Hours__c where Id=:newItems.keyset()]){
            setCEHours.add(cEHours.Term__c);
        }

        List<OrderApi__Subscription__c> lstSub = new List<OrderApi__Subscription__c>();

        for(OrderApi__Renewal__c term: [Select Id, OrderApi__Subscription__c, (Select Id, Activity_Type__c, Education_Provider__c, Number_Of_Credits__c from CE_Hours__r) from OrderApi__Renewal__c where Id=:setCEHours ]){
            if(term.CE_Hours__r.size() > 0){
                OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
                sub.Id = term.OrderApi__Subscription__c;
                Decimal approvedHours = 0;
                Decimal nonApprovedHours = 0;
                Decimal noEthics = 0;

                for(CE_Hours__c cEHours : term.CE_Hours__r){
                    if(cEHours.Education_Provider__c == 'NON-HIMSS'){
                        nonApprovedHours = nonApprovedHours + cEHours.Number_Of_Credits__c;
                    }else{
                        approvedHours = approvedHours + cEHours.Number_Of_Credits__c;
                    }
                    if(cEHours.Activity_Type__c == 'Ethics'){
                        noEthics = noEthics + cEHours.Number_Of_Credits__c;
                    }
                }
                sub.Active_Term_Approved_HIMSS_CE_Hours__c =  approvedHours;
                sub.Active_Term_Non_Approved_CE_Hours__c = nonApprovedHours;
                sub.Active_Term_CE_Hours__c = nonApprovedHours + approvedHours;
                sub.No__c = noEthics;
                lstSub.add(sub);
            }
        }

        if(lstSub.size() > 0){
            update lstSub;
        }

        // Turn ON Subscription Routing Rule
        Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription__c', false);
    }
    
}