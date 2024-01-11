/**
* Domain class for the Fon_BadgeTriggerHandlerService SObjectType
**/
global class Fon_BadgeTriggerDomain extends Framework.Domain{

    global Fon_BadgeTriggerDomain(List<OrderApi__Assignment__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<sObject> sObjectList) {
            return new Fon_BadgeTriggerDomain(sObjectList);
        }
    }

    /**************************************************************************************
    ** Author      :  Mayur 
    ** Param       :   
    ** Returns     :   
    ** Description :  This domain class will help to call trigger Fon_BadgeTriggerHandlerService service class.
    **************************************************************************************/
    global override void afterUpdate(Map<Id,sObject> oldMap){
        Framework.Log.push(Fon_BadgeTriggerHandlerService.class.getName(),'afterUpdate');
        system.debug('***Fon_BadgeTriggerDomain afterUpdate***');
        
        if(!Fon_BadgeTriggerHandlerService.runOnce){
            Fon_BadgeTriggerHandlerService.runOnce = true;
            Fon_BadgeTriggerHandlerService.AfterUpdate((Map<Id,OrderApi__Badge__c>)Trigger.newMap, (Map<Id,OrderApi__Badge__c>)oldMap);
        }
		
    }
    public override void afterInsert(){
        Framework.Log.push(Fon_BadgeTriggerHandlerService.class.getName(),'afterInsert');
        System.debug('Fon_BadgeTriggerDomain :: afterInsert');
        
        if(!Fon_BadgeTriggerHandlerService.runOnce){
            Fon_BadgeTriggerHandlerService.runOnce = true;
            //Fon_BadgeTriggerHandlerService.BeforeInsert((List<OrderApi__Badge__c>)Trigger.new);
            Fon_BadgeTriggerHandlerService.AfterInsert((Map<Id,OrderApi__Badge__c>)Trigger.newMap);
        }
		
        Framework.Log.pop();
    }
    global override void BeforeInsert(){
        Framework.Log.push(Fon_BadgeTriggerHandlerService.class.getName(),'beforeInsert');
        system.debug('***Fon_BadgeTriggerDomain BeforeInsert***');
        //Fon_BadgeTriggerHandlerService.BeforeInsert((List<OrderApi__Badge__c>)Trigger.new);
    }
    
    global override void beforeDelete(){
        Framework.Log.push(Fon_BadgeTriggerHandlerService.class.getName(),'beforeDelete');
        system.debug('***Fon_BadgeTriggerDomain beforeDelete***');
        Fon_BadgeTriggerHandlerService.BeforeDelete((Map<Id,OrderApi__Badge__c>)Trigger.oldMap);
    }
    
    
}