/**
* Domain class for the FON_ContactAssignmentTriggerService SObjectType
**/
global class Fon_ContactTriggerDomain extends Framework.Domain{

    global Fon_ContactTriggerDomain(List<Contact> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<sObject> sObjectList) {
            return new Fon_ContactTriggerDomain(sObjectList);
        }
    }

    /**************************************************************************************
    ** Author      :  Vikas Rajput 
    ** Param       :   
    ** Returns     :   
    ** Description :  This domain class will help to call trigger service class. this (FON_ContactAssignmentTriggerService) will create chapter order.
    **************************************************************************************/
    global override void afterUpdate(Map<Id,sObject> oldMap){
        system.debug('***Fon_ContactTriggerDomain afterUpdate***');
        if(!FON_ContactAssignmentTriggerService.runOnce){
            FON_ContactAssignmentTriggerService.runOnce = true;
            FON_ContactAssignmentTriggerService.createChapterSubscription((List<Contact>)Trigger.new, (Map<Id,Contact>)oldMap);
        }
    }
    
    global override void beforeUpdate(Map<Id,sObject> oldMap){
        system.debug('***Fon_ContactTriggerDomain beforeUpdate***');
        FON_ContactAssignmentTriggerService.updateContactOpOutChapterMembership((List<Contact>)Trigger.new, (Map<Id,Contact>)oldMap);
    }
    
    
}