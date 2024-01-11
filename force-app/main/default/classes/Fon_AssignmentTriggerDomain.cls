/**
* Domain class for the Fon_AssignmentTriggerService SObjectType
**/
global class Fon_AssignmentTriggerDomain extends Framework.Domain{

    global Fon_AssignmentTriggerDomain(List<OrderApi__Assignment__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<sObject> sObjectList) {
            return new Fon_AssignmentTriggerDomain(sObjectList);
        }
    }

    /**************************************************************************************
    ** Author      :  Mayur 
    ** Param       :   
    ** Returns     :   
    ** Description :  This domain class will help to call trigger service class. this (Fon_AssignmentTriggerService) will create chapter order.
    **************************************************************************************/
    global override void afterUpdate(Map<Id,sObject> oldMap){
        system.debug('***Fon_AssignmentTriggerDomain afterUpdate***');
        
        if(!Fon_AssignmentTriggerService.runOnce){
            Fon_AssignmentTriggerService.runOnce = true;
            Fon_AssignmentTriggerService.createSubscriptionAfterUpdate((Map<Id,OrderApi__Assignment__c>)Trigger.newMap, (Map<Id,OrderApi__Assignment__c>)oldMap);
        }
		
    }
    public override void afterInsert(){
        Framework.Log.push(Fon_AssignmentTriggerService.class.getName(),'afterInsert');
        System.debug('Fon_AssignmentTriggerService :: afterInsert');
        
        if(!Fon_AssignmentTriggerService.runOnce){
            Fon_AssignmentTriggerService.runOnce = true;
            Fon_AssignmentTriggerService.createSubscriptionAfterInsert((Map<Id,OrderApi__Assignment__c>)Trigger.newMap);
        }
		
        Framework.Log.pop();
    }
    
    global override void beforeUpdate(Map<Id,sObject> oldMap){}
    
    
}