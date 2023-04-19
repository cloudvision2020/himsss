@isTest
public with sharing class OpportunityProductSearch_t {
   @testSetup static void  testSetupData() {

    TestUtility.createTriggerSettings();
    Opportunity opportunityObj =  TestUtility.createOpportunity();
    TestUtility.createOpportunityLineItem(opportunityObj);

    }
    @isTest
    public static void testGetCoulmnNames(){

        Opportunity opportunityObj = [SELECT Id FROM Opportunity LIMIT 1];
        System.assertNotEquals(opportunityObj, null);
        OpportunityProductSearch_c.getCoulmnNames(opportunityObj.Id, 'product2');
    }
    @isTest
    public static void testGetProductList(){
         Opportunity opportunityObj = [SELECT Id FROM Opportunity LIMIT 1];
         System.assertNotEquals(opportunityObj, null);
         OpportunityProductSearch_c.getProductList(opportunityObj.Id,'test','test','test','test','test');
    }
    
}