/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-12-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger CECreditHoursTrigger on CE_Hours__c  (after insert, after update, before delete) {
    TriggerDispatcher.Run(new CECreditHoursTriggerHandler());
}