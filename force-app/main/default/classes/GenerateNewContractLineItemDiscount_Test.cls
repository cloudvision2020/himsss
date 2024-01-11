@isTest
public class GenerateNewContractLineItemDiscount_Test {
    
    @TestSetup
    public static void setup(){
        Id devRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        Id devRecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HIMSS Media').getRecordTypeId();
        
        TestUtility.createTriggerSettings();
        
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
        
        Account a = new Account();
        a.Name = 'Test Account for Contract Line Item Creation';
        a.RecordTypeId = devRecordTypeIdAccount;
        a.BillingStreet = 'Test Lane';
        a.BillingCity = 'Test City';
        a.BillingCountry = 'Test';
        Insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test Opportunity for Contract Line Item Creation';
        o.AccountId = a.id;
        o.RecordTypeId = devRecordTypeIdOpportunity;
        o.CloseDate = system.today();
        o.StageName = 'Discussion';
        o.Amount = 100;
        o.Pricebook2Id = pricebookObj.Id;
        Insert o;
        
        Discount_Product__c  dP = new Discount_Product__c();
        dP.Discount_Product_Code__c = 'DISCOUNTCODE';
        dP.Product_Code__c = 'PRODUCTCODE';
        dP.GL_Code__c = 'GL-000';
        dP.Profit_Center__c = '0000';
        insert dP;
        
        Product2 productObj = new Product2();
        productObj.Name = 'Test Product'; 
        productObj.ProductCode = dp.Product_Code__c;
        insert productObj;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productObj.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry pricebookEntryObj = new PricebookEntry();
        pricebookEntryObj.Pricebook2Id = o.Pricebook2Id;
        pricebookEntryObj.UnitPrice = 50;
        pricebookEntryObj.Product2Id = productObj.Id;
        pricebookEntryObj.IsActive = true;        
        insert pricebookEntryObj;
    }
    
    @isTest
    public static void testDiscountedContractLineItemCreated(){
        Opportunity o = [SELECT id,AccountId FROM Opportunity LIMIT 1];
        Product2 p = [SELECT id FROM Product2 LIMIT 1];
        PricebookEntry pBE = [SELECT id FROM PricebookEntry WHERE UnitPrice = 50 LIMIT 1];
        
        OpportunityLineItem opportunityLineItemObj = new OpportunityLineItem();
        opportunityLineItemObj.OpportunityId = o.Id;
        opportunityLineItemObj.Quantity = 5;
        opportunityLineItemObj.TotalPrice = 500;
        opportunityLineItemObj.Product2Id = p.Id;
        opportunityLineItemObj.PricebookEntryId = pBE.Id;
        opportunityLineItemObj.Discount_Percent__c = 50;
        opportunityLineItemObj.Start_Date__c = system.today();
        opportunityLineItemObj.End_Date__c = system.today();
        insert opportunityLineItemObj;
        
        Contract getcontractObj = TestUtility.createContract(o);
        
        List<Contract_Line_Item__c> DiscountCLIs = [SELECT ID,Sales_Price__c FROM Contract_Line_Item__c WHERE is_Discount_Record__c = TRUE];
        List<Contract_Line_Item__c> noneDiscountCLIs = [SELECT ID,Sales_Price__c FROM Contract_Line_Item__c WHERE is_Discount_Record__c = False];
        
        Assert.isTrue(DiscountCLIs.size() > 0);
        Assert.isTrue(noneDiscountCLIs.size() > 0);
        Assert.isTrue(DiscountCLIs[0].Sales_Price__c < 0);
        Assert.isTrue(noneDiscountCLIs[0].Sales_Price__c > 0);
    }
    
    @isTest
    public static void testDiscountContractLineItemNOTCreated(){
        Opportunity o = [SELECT id,AccountId FROM Opportunity LIMIT 1];
        Product2 p = [SELECT id FROM Product2 LIMIT 1];
        PricebookEntry pBE = [SELECT id FROM PricebookEntry WHERE UnitPrice = 50 LIMIT 1];
        
        OpportunityLineItem opportunityLineItemObj = new OpportunityLineItem();
        opportunityLineItemObj.OpportunityId = o.Id;
        opportunityLineItemObj.Quantity = 5;
        opportunityLineItemObj.TotalPrice = 500;
        opportunityLineItemObj.Product2Id = p.Id;
        opportunityLineItemObj.PricebookEntryId = pBE.Id;
        opportunityLineItemObj.Start_Date__c = system.today();
        opportunityLineItemObj.End_Date__c = system.today();
        insert opportunityLineItemObj;
        
        Contract getcontractObj = TestUtility.createContract(o);
        
        List<Contract_Line_Item__c> DiscountCLIs = [SELECT ID,Sales_Price__c FROM Contract_Line_Item__c WHERE is_Discount_Record__c = TRUE];
        List<Contract_Line_Item__c> noneDiscountCLIs = [SELECT ID,Sales_Price__c FROM Contract_Line_Item__c WHERE is_Discount_Record__c = False];
        
        Assert.isTrue(DiscountCLIs.size() == 0);
        Assert.isTrue(noneDiscountCLIs.size() > 0);
    }
    
    @isTest
    public static void testDiscountContractLineItemUpdate(){
        Opportunity o = [SELECT id,AccountId FROM Opportunity LIMIT 1];
        Product2 p = [SELECT id FROM Product2 LIMIT 1];
        PricebookEntry pBE = [SELECT id FROM PricebookEntry WHERE UnitPrice = 50 LIMIT 1];
        
        OpportunityLineItem opportunityLineItemObj = new OpportunityLineItem();
        opportunityLineItemObj.OpportunityId = o.Id;
        opportunityLineItemObj.Quantity = 5;
        opportunityLineItemObj.TotalPrice = 500;
        opportunityLineItemObj.Product2Id = p.Id;
        opportunityLineItemObj.PricebookEntryId = pBE.Id;
        opportunityLineItemObj.Discount_Percent__c = 50;
        opportunityLineItemObj.Start_Date__c = system.today();
        opportunityLineItemObj.End_Date__c = system.today() + 1;
        insert opportunityLineItemObj;
        
        Contract getcontractObj = TestUtility.createContract(o);
        
        List<Contract_Line_Item__c> DiscountCLIsBefore = [SELECT ID,Sales_Price__c,Quantity__c FROM Contract_Line_Item__c WHERE is_Discount_Record__c = TRUE];
        List<Contract_Line_Item__c> noneDiscountCLIsBefore = [SELECT ID,Sales_Price__c,Quantity__c FROM Contract_Line_Item__c WHERE is_Discount_Record__c = False];
        Assert.isTrue(DiscountCLIsBefore[0].Quantity__c == 5);
               
        Test.startTest();
        OpportunityLineItem updateOLI = opportunityLineItemObj;
        updateOLI.Quantity = 10;
        updateOLI.Start_Date__c = system.today();
        update updateOLI;
        
        Map<id, OpportunityLineItem> newMap = new Map<id, OpportunityLineItem>();
        newMap.put(updateOLI.id,updateOLI);
        
        GenerateNewContractLineItemDiscount.recreateDiscountLines(newMap, getcontractObj);
        
        List<Contract_Line_Item__c> DiscountCLIsAfter = [SELECT ID,Sales_Price__c,Quantity__c FROM Contract_Line_Item__c WHERE is_Discount_Record__c = TRUE];
        System.assertEquals(5, DiscountCLIsAfter[0].Quantity__c);
        Test.stopTest();
    }
    
}