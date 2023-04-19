@isTest
public with sharing class UtilityTest {
    
    @testSetup static void testSetupUtility(){

        TestUtility.createTriggerSettings();
        Opportunity getOportunityObj = TestUtility.createOpportunity();
       
        TestUtility.createContract(getOportunityObj);
        OpportunityLineItem opportunityLineItemObj =  TestUtility.createOpportunityLineItem(getOportunityObj);

    }
    @isTest
    private static void testGetPriceBookNameById(){
        
        Utility.getPriceBookNameById( new Set<String>{'Healthbox Price Book'});
        Utility.getPriceookNameByOpportunityRecordType();

    }
    @isTest
    private static void testGetFieldLabel(){
       
        Utility.getFieldLabel(new List<String>{'LastName','Account.Name'} ,'Contact');

        Utility.getFieldType(new List<String>{'LastName','Account.Name'} ,'Contact');

        Utility.getFieldIsUpdateableInfo(new List<String>{'LastName','Account.Name'} ,'Contact');
        Utility.getControllingField('Name', 'Account');

    }
}