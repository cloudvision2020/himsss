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
        //Added Ram
        TriggerSettings__c triggerSettingsObj6 = new TriggerSettings__c(Name = 'OrderApi__Assignment__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj6);
        TriggerSettings__c triggerSettingsObj7 = new TriggerSettings__c(Name = 'OrderApi__Sales_Order_Line__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj7);
        TriggerSettings__c triggerSettingsObj8 = new TriggerSettings__c(Name = 'OrderApi__Subscription__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj8);
        TriggerSettings__c triggerSettingsObj9 = new TriggerSettings__c(Name = 'OrderApi__Renewal__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj9);
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
    //Added Ram
    
    public static Contact createContact(string AcccountId){
        Contact contactObj = new Contact();
        contactObj.LastName = 'Test Contact';
        contactObj.AccountId = AcccountId;
        contactObj.Email = 'test@mail.com'; 
        insert contactObj;
        return contactObj;
    }
    public static OrderApi__Item__c createItem(){
        OrderApi__Item__c itemObj = new OrderApi__Item__c();
        itemObj.Name = 'Test Item';
        insert itemObj;
        return itemObj;
    }
    
    public static OrderApi__Item__c createItem(string itemId){
        OrderApi__Item__c itemObj = new OrderApi__Item__c();
        itemObj.Name = 'Test Item';
        itemObj.Individual_Membership__c = itemId;
        insert itemObj;
        return itemObj;
    }
    
    public static OrderApi__Item_Class__c createItemClass(String legacyItemClassID){
        OrderApi__Item_Class__c itemClassObj = new OrderApi__Item_Class__c();
        itemClassObj.Name = 'Test Item';
        itemClassObj.Legacy_Item_Class_ID__c = legacyItemClassID;
        insert itemClassObj;
        return itemClassObj;
    }
    
    public static OrderApi__Assignment__c createAssigment(string contactId,string itemId,string itemClassId,string salesOrderLineId){
        OrderApi__Assignment__c AssignmentObj = new OrderApi__Assignment__c();
        AssignmentObj.OrderApi__Contact__c = contactId;
        AssignmentObj.OrderApi__Item__c = itemId;
        AssignmentObj.OrderApi__Item_Class__c = itemClassId;
        AssignmentObj.OrderApi__Is_Active__c = true;
        AssignmentObj.OrderApi__Sales_Order_Line__c = salesOrderLineId;
        insert AssignmentObj;
        return AssignmentObj;
    }
    
    public static OrderApi__Assignment__c createAssigment(string contactId,string itemId,string itemClassId){
        OrderApi__Assignment__c AssignmentObj = new OrderApi__Assignment__c();
        AssignmentObj.OrderApi__Contact__c = contactId;
        AssignmentObj.OrderApi__Item__c = itemId;
        AssignmentObj.OrderApi__Item_Class__c = itemClassId;
        AssignmentObj.OrderApi__Is_Active__c = true;
        insert AssignmentObj;
        return AssignmentObj;
    }
    
    public static OrderApi__Subscription__c createSubscription(){
        OrderApi__Subscription__c subscriptionObj = new OrderApi__Subscription__c();
        insert subscriptionObj;
        return subscriptionObj;
    }
    
    
    public static OrderApi__Sales_Order__c createSalesOrder(){
        OrderApi__Sales_Order__c salesOrderObj = new OrderApi__Sales_Order__c();
        insert salesOrderObj;
        return salesOrderObj;
    }
        
    public static OrderApi__Sales_Order_Line__c createSalesOrderLine(string salesOrderId){
        OrderApi__Sales_Order_Line__c salesOrderLineObj = new OrderApi__Sales_Order_Line__c();
        salesOrderLineObj.OrderApi__Sales_Order__c = salesOrderId;
        insert salesOrderLineObj;
        return salesOrderLineObj;
    }
    
    public static OrderApi__Renewal__c createRenewal(string memberId,string itemId,string orderLineId){
        OrderApi__Renewal__c renewalObj = new OrderApi__Renewal__c();
        renewalObj.OrderApi__Subscription__c = memberId;
        renewalObj.OrderApi__Item__c = itemId;
        renewalObj.OrderApi__Sales_Order_Line__c = orderLineId;
        insert renewalObj;
        return renewalObj;
    }
    
    public static Contact createContactRecord(string AcccountId){
        Contact contactObj = new Contact();
        contactObj.LastName = 'Test Contact';
        contactObj.AccountId = AcccountId;
        contactObj.Email = 'test@mail.com'; 
        
        return contactObj;
    }
    //Ended Ram changes
    
    /*********************Added to cover code coverage*********************/
	
	public static string createBusinessGroup(){
		OrderApi__Business_Group__c bussinessGroup = new OrderApi__Business_Group__c();
		bussinessGroup.Name = 'Default Business Group';
		insert bussinessGroup;
		return bussinessGroup.Id;
	}
	
	public static OrderApi__Item_Class__c createNewItemClass(String legacyItemClassID){
		OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
		itemClass.Name = 'Family Law Class';
		itemClass.OrderApi__Subscription_Plan_Display_Label__c = '';
		itemClass.OrderApi__Is_Subscription__c = true;
		itemClass.OrderApi__Is_Active__c = true;
		itemClass.Legacy_Item_Class_ID__c = legacyItemClassID;
        if(legacyItemClassID == 'CORP' || legacyItemClassID == 'ORG'){
            itemClass.OrderApi__Enable_Assignments__c = true;
        }
		itemClass.OrderApi__Business_Group__c = createBusinessGroup();
		insert itemClass;
		return itemClass;
    }
	
	public static OrderApi__Item__c createNewItem(String itemClassID){
	
		OrderApi__Item__c item = new OrderApi__Item__c();
		item.Name = 'Individual Membership';
		item.OrderApi__Price__c = 480;
		item.OrderApi__Business_Group__c = createBusinessGroup();
		item.OrderApi__Is_Subscription__c = true;
		item.OrderApi__Subscription_Plan_Display_Label__c = 'Test Plan';
		item.OrderApi__Item_Class__c = itemClassID;
		insert item;
		return item;
    }
	
	public static OrderApi__Item__c createNewItem(string itemId, String itemClassID){
		OrderApi__Item__c item = new OrderApi__Item__c();
		item.Name = 'Individual Membership';
		item.OrderApi__Price__c = 480;
		item.OrderApi__Business_Group__c = createBusinessGroup();
		item.OrderApi__Is_Subscription__c = true;
		item.OrderApi__Subscription_Plan_Display_Label__c = 'Test Plan';
		item.OrderApi__Item_Class__c = itemClassID;
		item.Individual_Membership__c = itemId;
		insert item;
		return item;
	}
    public static OrderApi__Assignment_Role__c createAssigmentRole(string itemClassId){
		OrderApi__Assignment_Role__c assignrole = new OrderApi__Assignment_Role__c();
		assignrole.Name = 'Test Assignment';
		assignrole.OrderApi__Item_Class__c = itemClassId;
		assignrole.OrderApi__Is_Active__c = true;
		assignrole.OrderApi__Is_Default__c = true;
		insert assignrole;
		return assignrole;
	}
	
	public static OrderApi__Assignment__c createNewAssigment(string contactId,string itemId, String itemClassID){
		OrderApi__Assignment__c AssignmentObj = new OrderApi__Assignment__c();
		AssignmentObj.OrderApi__Assignment_Role__c = createAssigmentRole(itemClassID).Id;
        AssignmentObj.OrderApi__Contact__c = contactId;
        AssignmentObj.OrderApi__Item__c = itemId;
        AssignmentObj.OrderApi__Item_Class__c = itemClassID;
        AssignmentObj.OrderApi__Is_Active__c = true;
        
        OrderApi__Item_Class__c itemClass = new OrderApi__Item_Class__c();
        itemClass.OrderApi__Enable_Assignments__c = true;
        itemClass.Id = itemClassID;
        update itemClass;
        
        insert AssignmentObj;
        return AssignmentObj;
    }
}