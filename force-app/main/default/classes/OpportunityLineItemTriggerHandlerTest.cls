@isTest
public with sharing class OpportunityLineItemTriggerHandlerTest {
    @testSetup static void  opportunityLineItemTestSetup() {

        TestUtility.createTriggerSettings();
        Opportunity getOpportunityObj = TestUtility.createOpportunity();
       
        TestUtility.createContract(getOpportunityObj);
        OpportunityLineItem opportunityLineItemObj =  TestUtility.createOpportunityLineItem(getOpportunityObj);
       

       
    }
    @isTest
    static void testUpdateOpportunityLineItem(){
        opportunityLineItem opportunityLineItemObj =[SELECT Id,End_Date__c,Start_Date__c FROM OpportunityLineItem LIMIT 1];
        opportunityLineItemObj.End_Date__c = System.today().addDays(10);
        System.assertEquals(opportunityLineItemObj.Start_Date__c ,System.today());
        update opportunityLineItemObj;
       
    }
    @isTest
    static void testDeleteOpportunityLineItem(){
        opportunityLineItem opportunityLineItemObj =[SELECT Id,End_Date__c,Start_Date__c FROM OpportunityLineItem LIMIT 1];
        System.assertEquals(opportunityLineItemObj.Start_Date__c ,System.today());
        delete opportunityLineItemObj;
       
    }
    @isTest
    static void testUpdateAddSizeOpportunityLineItem(){
        opportunityLineItem opportunityLineItemObj =[SELECT Id,End_Date__c,Start_Date__c,Ad_Size2__c FROM OpportunityLineItem LIMIT 1];
        opportunityLineItemObj.Ad_Size2__c = 'Prescroll (1400x500)';
        System.assertEquals(opportunityLineItemObj.Start_Date__c ,System.today());
        update opportunityLineItemObj;
       
    }
    
}