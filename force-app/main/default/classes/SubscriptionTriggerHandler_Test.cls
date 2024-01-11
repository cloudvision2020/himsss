@isTest
public class SubscriptionTriggerHandler_Test {
    
    @isTest
    public static void TestSubscriptionTriggerHandler(){
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'OrderApi__Subscription__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);

        insert triggerSettingsList;
        
        //insert Account
        Account accountObj = new Account();
        	
        	accountObj.Name = 'Test Account';
        	accountObj.No_Known_Address__c =true;        
        	accountObj.Media_Account_Owner__c=UserInfo.getUserId();
        
        insert accountObj;

        //insert Contact
        Contact newValidContactToInsert = new Contact(FirstName = 'Test Valid',
                                                      LastName = 'Contact',
                                                      Chapter_Complimentary_Membership__c = 'Alabama Chapter',
                                                      AccountId = accountObj.Id);

        insert newValidContactToInsert;
        
        OrderApi__Item_Class__c itmcl = new OrderApi__Item_Class__c();
        	itmcl.Name = 'Certification';
        insert itmcl;

        //insert Item
        OrderApi__Item__c itm =new OrderApi__Item__c();
        	itm.name='Certification';
        	itm.Is_Entity__c = true;
        	itm.OrderApi__Is_Subscription__c = true;
        	itm.OrderApi__Is_Active__c = true;
        	itm.OrderApi__Item_Class__c = itmcl.Id;
        insert itm;
        
        //insert Subscriptions
        OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
        
            sub.OrderApi__Account__c = accountObj.Id;
            sub.OrderApi__Contact__c = newValidContactToInsert.Id;
            sub.OrderApi__Entity__c ='Account';
            sub.OrderApi__Activated_Date__c = Date.today();
            sub.OrderApi__Paid_Through_Date__c = Date.today().addDays(1);
            sub.OrderApi__Days_To_Lapse__c = 365;
            sub.OrderApi__Enable_Auto_Renew__c = true;
            sub.OrderApi__Item__c = itm.Id;
            sub.OrderApi__status__C = 'Active';
        
        insert sub;
        test.startTest();
        	sub.OrderApi__Activated_Date__c = Date.today().addDays(-100);
            sub.OrderApi__Paid_Through_Date__c = Date.today().addDays(-99);
            sub.OrderApi__Days_To_Lapse__c = -100;
            sub.OrderApi__status__C = 'Expired';
        	update sub;
        test.stopTest();
    }
    
    /*
    @isTest
    public static void TestSubscriptionTriggerHandlerExpired(){
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'OrderApi__Subscription__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);

        insert triggerSettingsList;
        
        //insert Account
        Account accountObj = new Account();
        	
        	accountObj.Name = 'Test Account';
        	accountObj.No_Known_Address__c =true;        
        	accountObj.Media_Account_Owner__c=UserInfo.getUserId();
        
        insert accountObj;

        //insert Contact
        Contact newValidContactToInsert = new Contact(FirstName = 'Test Valid',
                                                      LastName = 'Contact',
                                                      AccountId = accountObj.Id);

        insert newValidContactToInsert;
        
        OrderApi__Item_Class__c itmcl = new OrderApi__Item_Class__c();
        	itmcl.Name = 'Certification';
        insert itmcl;

        //insert Item
        OrderApi__Item__c itm =new OrderApi__Item__c();
        	itm.name='Certification';
        	itm.Is_Entity__c = true;
        	itm.OrderApi__Is_Subscription__c = true;
        	itm.OrderApi__Is_Active__c = true;
        	itm.OrderApi__Item_Class__c = itmcl.Id;
        insert itm;
        
        //insert Subscriptions
        OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
        
            sub.OrderApi__Account__c = accountObj.Id;
            sub.OrderApi__Contact__c = newValidContactToInsert.Id;
            sub.OrderApi__Entity__c ='Account';
            sub.OrderApi__Activated_Date__c = Date.today().addDays(-100);
            sub.OrderApi__Paid_Through_Date__c = Date.today().addDays(-99);
            sub.OrderApi__Days_To_Lapse__c = -100;
            sub.OrderApi__Enable_Auto_Renew__c = true;
            sub.OrderApi__Item__c = itm.Id;
            sub.OrderApi__status__C = 'Expired';
        
        insert sub;
    }
    */
}