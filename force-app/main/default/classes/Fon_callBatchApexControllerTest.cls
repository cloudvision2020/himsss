@isTest(seeAllData=false)
public with sharing class Fon_callBatchApexControllerTest {
    @testSetup static void  testSetupData() {
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

        //insert Item
        OrderApi__Item__c itm =new OrderApi__Item__c();
        itm.name='TestItem';
        insert itm;

        //insert Subscriptions
        list<OrderApi__Subscription__c> subList=new list<OrderApi__Subscription__c>();
        for(integer i=0;i<20;i++){
            OrderApi__Subscription__c sub=new OrderApi__Subscription__c();
            sub.OrderApi__Account__c=accountObj.Id;
            //sub.OrderApi__Sales_Order_Line__c=genId(OrderApi__Sales_Order_Line__c.SObjectType),
            sub.OrderApi__Contact__c=newValidContactToInsert.Id;
            //sub.OrderApi__Business_Group__c=bg.Id,
            sub.OrderApi__Entity__c='Contact';
            sub.OrderApi__Activated_Date__c=Date.today();
            sub.OrderApi__Paid_Through_Date__c=Date.today().addDays(1);
            sub.OrderApi__Days_To_Lapse__c=365;
            sub.OrderApi__Enable_Auto_Renew__c=true;
            sub.OrderApi__Item__c=itm.Id;
            sub.OrderApi__status__C='Active';  
            subList.add(sub); 
        }
        insert subList;
        
        //insert Terms
        list<OrderApi__Renewal__c> termList=new list<OrderApi__Renewal__c>();
        for(integer i=0;i<20;i++){
            OrderApi__Renewal__c term =new OrderApi__Renewal__c();
            term.OrderApi__Subscription__C=subList[i].Id;
            termList.add(term);
        }
        insert termList;
        
    }

    static testmethod void searchSubscriptionsTest(){
        test.startTest();
        //we have to create metadata record here because at the time of delpoyment we get error no metadata record is present.
         FON_Item_Audit_Setting__mdt MetadataTest = 
       (FON_Item_Audit_Setting__mdt)Json.deserialize('{"name": "Audit_Subscriptions","Audit_Percentage__c": "5","Order_By__c" : "createddate DESC"}', FON_Item_Audit_Setting__mdt.class);
        Fon_callBatchApexController.auditMatadata=MetadataTest;
        
        OrderApi__Item__c itm=[select id from OrderApi__Item__c where name='TestItem'];
        Fon_callBatchApexController.AuditSubscriptionsWrapper output=Fon_callBatchApexController.searchSubscriptionsList(itm.Id);
        Fon_callBatchApexController.executeBatchJob(itm.id,output.eligibleSubscriptions);
        test.stopTest();
   }
}