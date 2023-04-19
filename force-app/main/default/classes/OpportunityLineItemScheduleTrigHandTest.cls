@isTest
public with sharing class OpportunityLineItemScheduleTrigHandTest {
    public opportunityLineItemScheduleTrigHandTest() {

    }
    @testSetup static void opportunityLineItemScheduleTestSetup() {
        TestUtility.createTriggerSettings();
        Opportunity getOpportunityObj = TestUtility.createOpportunity();
        System.assertEquals(getOpportunityObj.Name ,'Test Opportunity');
        OpportunityLineItem opportunityLineItemObject =  TestUtility.createOpportunityLineItem(getOpportunityObj);

        OpportunityLineItemSchedule opportunityLineItemScheduleObject = new OpportunityLineItemSchedule();

        opportunityLineItemScheduleObject.OpportunityLineItemId = opportunityLineItemObject.Id;
        opportunityLineItemScheduleObject.ScheduleDate = System.today();
        opportunityLineItemScheduleObject.Revenue = 5000;
        opportunityLineItemScheduleObject.Type = 'Revenue';
        insert opportunityLineItemScheduleObject;
    }
    @isTest 
    static void testUpdateOpportunityLineItemSchedule(){
        OpportunityLineItemSchedule opportunityLineItemScheduleObject = [SELECT Id,Revenue FROM OpportunityLineItemSchedule LIMIT 1];
        System.assertNotEquals(opportunityLineItemScheduleObject, null);
        opportunityLineItemScheduleObject.Revenue = 10000;
        update opportunityLineItemScheduleObject;

    }
    @isTest 
    static void testDeleteOpportunityLineItemSchedule(){
        OpportunityLineItemSchedule opportunityLineItemScheduleObject = [SELECT Id,Revenue FROM OpportunityLineItemSchedule LIMIT 1];
        System.assertNotEquals(opportunityLineItemScheduleObject, null);
        delete opportunityLineItemScheduleObject;

    }
}