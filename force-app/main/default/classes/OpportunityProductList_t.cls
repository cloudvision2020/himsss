@isTest
public with sharing class OpportunityProductList_t {
    @testSetup static void  testSetupData() {

        TestUtility.createTriggerSettings();
        Opportunity opportunityObj =  TestUtility.createOpportunity();
        TestUtility.createOpportunityLineItem(opportunityObj);
        

    }
    @isTest
    public static void testGetProductList(){

        Opportunity opportunityObj = [SELECT Id FROM Opportunity LIMIT 1];
        System.assertNotEquals(opportunityObj, null);
        OpportunityProductList_c.getProductList(opportunityObj.Id,'opportunityLineItem');

    }
    @isTest
    public static void testDeleteProduct(){

        Opportunity opportunityObj = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityLineItem opportunityLineItemObj = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        System.assertNotEquals(opportunityObj, null);
        OpportunityProductList_c.deleteProduct(opportunityObj.Id,opportunityLineItemObj.Id);

    }
}