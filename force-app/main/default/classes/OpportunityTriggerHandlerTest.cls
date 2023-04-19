@isTest
public class OpportunityTriggerHandlerTest 
{
    @testSetup 
    static void dataTestSetup() {
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'Opportunity', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);
        
        TriggerSettings__c triggerSettingsObj1 = new TriggerSettings__c(Name = 'OpportunityLineItem', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj1);
        
        insert triggerSettingsList;
        
        Account accountObj = new Account();
        accountObj.Name = 'Test Account';
        accountObj.No_Known_Address__c =true;        
        accountObj.Media_Account_Owner__c=UserInfo.getUserId();
        insert accountObj;
        
        List<Pricebook2> Pricebooks = new List<Pricebook2>();
        
        Pricebook2  pricebookObj = new Pricebook2 ();
        pricebookObj.Name = 'Healthbox Price Book';
        pricebookObj.IsActive = true;
        Pricebooks.add(pricebookObj);
        
        Pricebook2  pricebookObj1 = new Pricebook2 ();
        pricebookObj1.Name = 'HIMSS North America Price Book';
        pricebookObj1.IsActive = true;
        Pricebooks.add(pricebookObj1);
        
        Pricebooks.add(new Pricebook2(Name = 'HBX Consulting', IsActive = true));
        insert Pricebooks;
        
        Product2 productObj = new Product2();
        productObj.Name = 'Test Product';
        
        insert productObj;
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HBX DaVita Investing').getRecordTypeId();
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.Name = 'Test Opportunity';
        opportunityObj.RecordTypeId  = RecordTypeIdOpportunity;
        opportunityObj.AccountId = accountObj.Id;
        opportunityObj.StageName = 'Proposal';
        opportunityObj.CloseDate = System.today();
        opportunityObj.Pricebook2Id = pricebookObj.Id;
        opportunityObj.CSM_Email_Sent__c = false;
        opportunityList.add(opportunityObj);
        
        Opportunity opportunityObj1 = new Opportunity();
        opportunityObj1.Name = 'Test Opportunity';
        opportunityObj1.RecordTypeId  = RecordTypeIdOpportunity;
        opportunityObj1.AccountId = accountObj.Id;
        opportunityObj1.StageName = 'Proposal';
        opportunityObj1.CloseDate = System.today();
        opportunityObj1.Pricebook2Id = pricebookObj.Id;
        opportunityObj.CSM_Email_Sent__c = false;
        opportunityList.add(opportunityObj1);
        
        insert opportunityList;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productObj.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry pricebookEntryObj = new PricebookEntry();
        pricebookEntryObj.Pricebook2Id = opportunityList[0].Pricebook2Id;
        pricebookEntryObj.UnitPrice = 50;
        pricebookEntryObj.Product2Id = productObj.Id;
        pricebookEntryObj.IsActive = true;
        
        insert pricebookEntryObj;
        
        OpportunityLineItem opportunityLineItemObj = new OpportunityLineItem();
        opportunityLineItemObj.OpportunityId = opportunityList[0].Id;
        opportunityLineItemObj.Quantity = 5;
        opportunityLineItemObj.TotalPrice = 500;
        opportunityLineItemObj.Product2Id = productObj.Id;
        opportunityLineItemObj.PricebookEntryId = pricebookEntryObj.Id; 
        
        insert opportunityLineItemObj;
        
        
        
    }
    
    @isTest 
    static void updateOpportunityRecordType() 
    {
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HBX Consulting').getRecordTypeId();
        List<Opportunity> opportunitys = [SELECT Id,RecordTypeId FROM Opportunity ];
        opportunitys[1].RecordTypeId = RecordTypeIdOpportunity;
        update opportunitys;
    }
    
    @isTest 
    static void updateOpportunityRecordTypeWithOpportunityLineItem() {
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HBX Consulting').getRecordTypeId();
        List<Opportunity> opportunities = [SELECT Id,RecordTypeId FROM Opportunity ];
        
        try {
            opportunities[0].RecordTypeId = RecordTypeIdOpportunity;
            update opportunities;
        } catch(Exception error) {
            
            System.assert(error.getMessage().contains(Label.RT_change_on_opportuntiy_error));
        }
    }
    
    @isTest 
    static void updateOpportunityRecordTypeWithoutLineItem() 
    {
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HBX Consulting').getRecordTypeId();
        List<Opportunity> opportunities = [SELECT Id,RecordTypeId,Pricebook2Id FROM Opportunity WHERE HasOpportunityLineItem = false];
        List<Pricebook2> pricebooks = [SELECT Id FROM Pricebook2 WHERE Name = 'HBX Consulting'];
        
        opportunities[0].RecordTypeId = RecordTypeIdOpportunity;
        update opportunities;
    }
    @isTest 
    static void updateOpportunity() 
    {   
        List<Opportunity> opportunities = [SELECT Id,RecordTypeId,Pricebook2Id,CurrencyISOCode FROM Opportunity WHERE HasOpportunityLineItem = false];
        List<Pricebook2> pricebooks = [SELECT Id FROM Pricebook2 WHERE Name = 'HBX Consulting'];
        opportunities[0].CurrencyISOCode = 'AUD';
        update opportunities;
    }
}