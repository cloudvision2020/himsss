public with sharing class TestUtility {
    public TestUtility() {

    }
    public static void createTriggerSettings(){
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'Opportunity', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);
        
        TriggerSettings__c triggerSettingsObj1 = new TriggerSettings__c(Name = 'OpportunityLineItem', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj1);

        TriggerSettings__c triggerSettingsObj2 = new TriggerSettings__c(Name = 'Contract', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj2);

        TriggerSettings__c triggerSettingsObj3 = new TriggerSettings__c(Name = 'Contract_Line_Item__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj3);
        TriggerSettings__c triggerSettingsObj4 = new TriggerSettings__c(Name = 'OpportunityLineItemSchedule', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj4);
        TriggerSettings__c triggerSettingsObj5 = new TriggerSettings__c(Name = 'Contract_Line_Item_Schedule__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj5);
        insert triggerSettingsList;   

    }
    public static String createAccount(){
        Account accountObj = new Account();
        accountObj.Name = 'Test Account';
        accountObj.No_Known_Address__c =true;
        accountObj.Media_Account_Owner__c=UserInfo.getUserId();
        insert accountObj;
        return accountObj.Id;
    }
    public static Opportunity createOpportunity(){

        Pricebook2  pricebookObj = new Pricebook2 ();
        pricebookObj.Name = 'Healthbox Price Book';
        pricebookObj.IsActive = true;
        insert pricebookObj;
                
        Opportunity opportunityObj = new Opportunity();
        opportunityObj.Name = 'Test Opportunity';
        opportunityObj.RecordTypeId  = Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID;
        opportunityObj.AccountId = createAccount();
        opportunityObj.StageName = 'Proposal';
        opportunityObj.CloseDate = System.today();
        opportunityObj.Pricebook2Id = pricebookObj.Id;
        
       
        insert opportunityObj;
        

        return opportunityObj;
    }

    public static OpportunityLineItem createOpportunityLineItem(Opportunity opportunityObj){
        Product2 productObj = new Product2();
        productObj.Name = 'Test Product';
        productObj.CanUseRevenueSchedule = true;
        
        insert productObj;
		
		PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(), Product2Id = productObj.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry pricebookEntryObj = new PricebookEntry();
        pricebookEntryObj.Pricebook2Id = opportunityObj.Pricebook2Id;
        pricebookEntryObj.UnitPrice = 50;
        pricebookEntryObj.Product2Id = productObj.Id;
        pricebookEntryObj.IsActive = true;
        
        insert pricebookEntryObj;
        
        OpportunityLineItem opportunityLineItemObj = new OpportunityLineItem();
        opportunityLineItemObj.OpportunityId = opportunityObj.Id;
        opportunityLineItemObj.Quantity = 5;
        opportunityLineItemObj.TotalPrice = 500;
        opportunityLineItemObj.Product2Id = productObj.Id;
        opportunityLineItemObj.PricebookEntryId = pricebookEntryObj.Id; 
        opportunityLineItemObj.Start_Date__c = System.today();
        opportunityLineItemObj.End_Date__c = System.today().addDays(5);
        opportunityLineItemObj.Product_Sub_Type__c = 'Banners';
        opportunityLineItemObj.Ad_Size2__c = 'Leaderboard (728x90)';
    
        
        insert opportunityLineItemObj;
         
        return opportunityLineItemObj;
       

    }
    public static Contract createContract(Opportunity oportunityObj){

       
        Contract contractObj = new Contract();
        contractObj.AccountId = oportunityObj.AccountId;
        contractObj.ContractTerm = 1;
        contractObj.Opportunity__c = oportunityObj.Id;
        contractObj.StartDate = System.today();
        contractObj.RecordTypeId = Constants.CONTRACT_HIMSS_MEDIA_RECORDTYPEID;
        insert contractObj;
        return contractObj;

    }

    
}