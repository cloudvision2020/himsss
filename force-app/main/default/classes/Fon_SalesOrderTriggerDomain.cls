/**
* Domain class for the Fon_SalesOrderTriggerDomain SObjectType
**/
global class Fon_SalesOrderTriggerDomain extends Framework.Domain{

    global Fon_SalesOrderTriggerDomain(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<sObject> sObjectList) {
            return new Fon_SalesOrderTriggerDomain(sObjectList);
        }
    }

    global override void beforeInsert(){
        if(!SalesOrderTriggerHandler.runOnce){
            SalesOrderTriggerHandler.runOnce = true;
            SalesOrderTriggerHandler.updateNetPayment((List<OrderApi__Sales_Order__c>)Trigger.new);
        }
    }
    
    
}