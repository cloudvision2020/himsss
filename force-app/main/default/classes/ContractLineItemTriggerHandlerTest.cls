@isTest
public with sharing class ContractLineItemTriggerHandlerTest {
    @testSetup static void dataSetup(){
        TestUtility.createTriggerSettings();
        Opportunity getOportunityObj = TestUtility.createOpportunity();
       
        OpportunityLineItem opportunityLineItemObj =  TestUtility.createOpportunityLineItem(getOportunityObj);

        Contract getcontractObj = TestUtility.createContract(getOportunityObj);

        Contract_Line_Item__c contractLineItemObj = new  Contract_Line_Item__c();           
        contractLineItemObj.Contract__c = getcontractObj.Id;
        contractLineItemObj.Opportunity_Line_Item_Id__c = opportunityLineItemObj.Id;

        insert contractLineItemObj;


    }
    @isTest
    static void testUpdateContractLineItemTrigger(){
        Contract_Line_Item__c contractLineItemObj =[SELECT Id FROM Contract_Line_Item__c LIMIT 1];
        System.assertNotEquals(contractLineItemObj, null);
        update contractLineItemObj;

    }
    @isTest
    static void testDeleteContractLineItemTrigger(){
        Contract_Line_Item__c contractLineItemObj =[SELECT Id FROM Contract_Line_Item__c LIMIT 1];
        System.assertNotEquals(contractLineItemObj, null);
        delete contractLineItemObj;

    }
}