@isTest
public with sharing class OpportunityProductEditableList_t {
    public OpportunityProductEditableList_t() {

    }
    @testSetup static void dataTestSetup(){

        TestUtility.createTriggerSettings();
        String accountId = TestUtility.createAccount();
       // Opportunity opportunityObj =  TestUtility.createOpportunity();
        // TestUtility.createOpportunityLineItem(opportunityObj);

        Pricebook2  pricebookObj = new Pricebook2 ();
        pricebookObj.Name = 'Healthbox Price Book';
        pricebookObj.IsActive = true;
        insert pricebookObj;

        
        List<Opportunity> opportunityList = new List<Opportunity>();

        Id opportunityHimssMediaRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HIMSS_Media').getRecordTypeId(); 
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.Name = 'Test Opportunity';
        opportunityObj.RecordTypeId  = opportunityHimssMediaRecordId;
        opportunityObj.AccountId = accountId;
        opportunityObj.StageName = 'Proposal';
        opportunityObj.CloseDate = System.today();
        opportunityObj.Pricebook2Id = pricebookObj.Id;
        opportunityList.add(opportunityObj);

        Id opportunityAnalytics_ProviderRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HIMSS_Analytics_Provider').getRecordTypeId(); 
        Opportunity opportunityObj1 = new Opportunity();
        opportunityObj1.Name = 'Test Opportunity';
        opportunityObj1.RecordTypeId  = opportunityAnalytics_ProviderRecordId;
        opportunityObj1.AccountId = accountId;
        opportunityObj1.StageName = 'Proposal';
        opportunityObj1.CloseDate = System.today();
        opportunityObj1.Pricebook2Id = pricebookObj.Id;
        opportunityList.add(opportunityObj1);

        Id opportunityAnalytics_VendorRecordId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HIMSS_Analytics_Vendor').getRecordTypeId(); 
        Opportunity opportunityObj2 = new Opportunity();
        opportunityObj2.Name = 'Test Opportunity';
        opportunityObj2.RecordTypeId  = opportunityAnalytics_VendorRecordId;
        opportunityObj2.AccountId = accountId;
        opportunityObj2.StageName = 'Proposal';
        opportunityObj2.CloseDate = System.today();
        opportunityObj2.Pricebook2Id = pricebookObj.Id;
        opportunityList.add(opportunityObj2);

        insert opportunityList;
        TestUtility.createOpportunityLineItem(opportunityList[0]);
    }
    @isTest
    public static void testGetCoulmnNames(){
        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        System.assertNotEquals(opportunityList, null);
        OpportunityProductEditableList_c.getCoulmnNames(opportunityList[0].Id);
        OpportunityProductEditableList_c.getCoulmnNames(opportunityList[1].Id);
        OpportunityProductEditableList_c.getCoulmnNames(opportunityList[2].Id);

    }
    @isTest
    public static void testGetProductList(){
        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity ];
        List<Product2> ProductObj = [SELECT Id FROM Product2];
        System.assertNotEquals(opportunityList, null);
        System.assertNotEquals(ProductObj, null);
        OpportunityProductEditableList_c.getProductList(opportunityList[0].Id, ProductObj, 'opportunityLineItem');
        OpportunityProductEditableList_c.getProductList(opportunityList[1].Id, ProductObj, 'opportunityLineItem');
        OpportunityProductEditableList_c.getProductList(opportunityList[2].Id, ProductObj, 'opportunityLineItem');
    
    }
}