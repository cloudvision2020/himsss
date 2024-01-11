@isTest
global class Fon_ContactTriggerServiceTest {
    
    static Boolean isInstalled = false;
    private static void install() {  
        if (!isInstalled) {
            Framework.Installer.install();
            //PagesApi.PackageScripts.install();
            OrderApi.PackageScripts.install();
            //EventApi.PackageScripts.install();
            isInstalled = true; 
        }
    }
    
    @isTest
    public static void testingAssignBatch(){
        install();
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule cons = new Framework.RoutingRule();
        cons.apexClass = 'Fon_ContactTriggerDomain';
        cons.namespace = '  ';
        cons.isEnabled = true;
        cons.sObjectName = 'Contact';
        cons.executionOrder = 0;
        rules.add(cons);
        Framework.Config.push(rules);
        
        Account ac = new Account();
        ac.Name = 'testAccount';
        insert ac;
        
        List<Contact> lstContact = new List<Contact>();
        Contact objContact1 = new Contact();
        objContact1.FirstName = 'test';
        objContact1.LastName = 'contact';
        objContact1.AccountId = ac.Id;
        objContact1.Opt_out_of_Chapter_Membership__c = 'Yes';
        lstContact.add(objContact1);
        
        
        insert lstContact;
        
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c();
        bg.Name = 'Test BG';
        insert bg; 
        
        List<OrderApi__Subscription_Plan__c> suPlans = New List<OrderApi__Subscription_Plan__c>();
        OrderApi__Subscription_Plan__c subPlanCurrent = new OrderApi__Subscription_Plan__c();
        subPlanCurrent.Name = 'Current';
        subPlanCurrent.OrderApi__Type__c = 'Calendar';
        subPlanCurrent.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlanCurrent.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlanCurrent.OrderApi__Enable_Proration__c = false;
        subPlanCurrent.OrderApi__Is_Active__c = true;
        subPlanCurrent.OrderApi__Business_Group__c = bg.Id; 
        subPlanCurrent.OrderApi__Grace_Period__c = 9;
        subPlanCurrent.OrderApi__Calendar_End_Month__c = '01 - January';
        suPlans.add(subPlanCurrent);
        
        insert suPlans;    

        List<OrderApi__Item_Class__c> itemClassToInsert = New List<OrderApi__Item_Class__c>();
        OrderApi__Item_Class__c itmClass = new OrderApi__Item_Class__c();
        itmClass.Name = 'ISACA Class';
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Assignment_SObject__c = 'TEST__C';        
        itmClass.OrderApi__Business_Group__c = bg.Id;
        itmClass.OrderApi__Is_Active__c = true;
        itemClassToInsert.add(itmClass) ;
        
        Insert itemClassToInsert;
        
        List<OrderApi__Item__c> itemToInsert = New List<OrderApi__Item__c>();
        OrderApi__Item__c itm = new OrderApi__Item__c(); 
        itm.Name = 'HIMSS '+'Alabama Chapter';
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Business_Group__c = bg.Id;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 160;
        itm.OrderApi__Display_Name__c = 'Test';
        itm.Free_Chapter_member_included__c = true;
        itemToInsert.add(itm) ;
        
        Insert itemToInsert;
        
        List<OrderApi__Item_Subscription_Plan__c> subscriptonPlanTOInsert = New List<OrderApi__Item_Subscription_Plan__c>();
        Integer mainItemCounter = 0;
        for(OrderApi__Subscription_Plan__c subPlan : suPlans){
            OrderApi__Item_Subscription_Plan__c isp = new  OrderApi__Item_Subscription_Plan__c();
            if(mainItemCounter == 0){
                isp.OrderApi__Is_Default__c = true;
            }
            isp.OrderApi__Item__c = itm.Id;
            isp.OrderApi__Subscription_Plan__c = subPlan.Id;
            subscriptonPlanTOInsert.add(isp) ;
            mainItemCounter = mainItemCounter + 1;
        }
        Insert subscriptonPlanTOInsert;
        for(OrderApi__Item__c myItem : itemToInsert){
            myItem.OrderApi__Is_Active__c = true;        
            
        }
        update itemToInsert;
        
        List<OrderApi__Subscription__c> subList = new List<OrderApi__Subscription__c>();
        OrderApi__Subscription__c subscription = new OrderApi__Subscription__c();
        subscription.OrderApi__Contact__c = lstContact[0].Id;
        subscription.OrderApi__Account__c = lstContact[0].AccountId;
        subscription.OrderApi__Item__c = itm.Id;     
        subscription.OrderApi__Subscription_Plan__c = suPlans[0].Id;
        subscription.OrderApi__Business_Group__c = bg.Id; 
        subscription.OrderApi__Status__c = 'Active';
        subList.add(subscription);
        insert subList;
        
        OrderApi__Subscription_Line__c subLine = new OrderApi__Subscription_Line__c();
        subLine.OrderApi__Subscription__c = subscription.Id;
        subLine.OrderApi__Item__c = itm.Id; 
        subLine.OrderApi__Is_Amendment__c = true;
        insert subLine;
        
        OrderApi__Renewal__c term = new OrderApi__Renewal__c();
        term.OrderApi__Subscription__C = subList[0].Id;
        term.OrderApi__Account__c = lstContact[0].AccountId;
        insert term;
        subscription.OrderApi__Status__c = 'Active';
        update subscription;
        
        for(Contact objContact : lstContact){
            objContact.Chapter_Complimentary_Membership__c = 'Alabama Chapter';
            objContact.Opt_out_of_Chapter_Membership__c = 'No';
        }
        update lstContact;
        
    } 
    
    
}