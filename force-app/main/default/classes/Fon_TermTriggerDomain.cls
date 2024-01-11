/**
* Domain class for the Fon_TermTriggerDomain SObjectType
**/
global class Fon_TermTriggerDomain extends Framework.Domain{

    global Fon_TermTriggerDomain(List<OrderApi__Renewal__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<sObject> sObjectList) {
            return new Fon_TermTriggerDomain(sObjectList);
        }
    }


    public override void afterInsert(){
        Framework.Log.push(Fon_TermTriggerDomainService.class.getName(),'afterInsert');
        Fon_TermTriggerDomainService.AfterInsert((Map<Id,OrderApi__Renewal__c>)Trigger.newMap);
        Framework.Log.pop();
    }
    
    global override void afterUpdate(Map<Id,sObject> oldMap){
        Framework.Log.push(Fon_TermTriggerDomainService.class.getName(),'afterUpdate');
        Fon_TermTriggerDomainService.AfterUpdate((Map<Id,OrderApi__Renewal__c>)Trigger.newMap, (Map<Id,OrderApi__Renewal__c>)oldMap);
        Framework.Log.pop();
    }
    
}