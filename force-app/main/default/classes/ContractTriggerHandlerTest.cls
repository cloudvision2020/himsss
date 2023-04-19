@isTest
public class ContractTriggerHandlerTest {
    @testSetup static void  contractTestSetup() {
        TestUtility.createTriggerSettings();

        Opportunity getOpportunityObj = TestUtility.createOpportunity();
        System.assertEquals(getOpportunityObj.Name ,'Test Opportunity');

        OpportunityLineItem opportunityLineItemObj =  TestUtility.createOpportunityLineItem(getOpportunityObj);
        System.assertEquals(opportunityLineItemObj.Quantity ,5);

        Id contractHimssMediaRecordId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('HIMSS_Media').getRecordTypeId(); 
       
        Contract contractObj = new Contract();
        contractObj.AccountId = getOpportunityObj.AccountId;
        contractObj.ContractTerm = 1;
        contractObj.Opportunity__c = getOpportunityObj.Id;
        contractObj.StartDate = System.today();
        contractObj.RecordTypeId = contractHimssMediaRecordId;
        insert contractObj;

        System.assertEquals(contractObj.ContractTerm ,1);
        
        

    }
    @isTest 
    static void testContract(){
        Opportunity oportunityObj = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Id contractHimssMediaRecordId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('HIMSS_Media').getRecordTypeId(); 
       
        Contract contractObj = new Contract();
        contractObj.AccountId = oportunityObj.AccountId;
        contractObj.ContractTerm = 1;
        contractObj.Opportunity__c = oportunityObj.Id;
        contractObj.StartDate = System.today();
        contractObj.RecordTypeId = contractHimssMediaRecordId;
        try {
            insert contractObj;
        } catch(Exception error) {
            
            System.assert(error.getMessage().contains(Label.Single_Contract_Under_Opportunity_Error));
        }
    }
}