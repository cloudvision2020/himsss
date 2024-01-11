@istest
public class TermTriggerHandler_Test {
    @testSetup static void  contractTestSetup() {
        TestUtility.createTriggerSettings();
        string accountid = TestUtility.createAccount();
        Contact conObj = TestUtility.createContact(accountid);
        OrderApi__Item__c itemObj = TestUtility.createItem();
        OrderApi__Item__c itemsObj = TestUtility.createItem(itemObj.id);
        OrderApi__Item_Class__c itemClassObj = TestUtility.createItemClass('CORP');
        
        OrderApi__Subscription__c subscriptionObj = TestUtility.createSubscription();
        OrderApi__Sales_Order__c salesOrderObj = TestUtility.createSalesOrder();
        OrderApi__Sales_Order_Line__c salesOrderLineObj = TestUtility.createSalesOrderLine(salesOrderObj.id);
        OrderApi__Assignment__c assignmentObj = TestUtility.createAssigment(conObj.id,itemsObj.id,itemClassObj.id,salesOrderLineObj.id);
        OrderApi__Renewal__c renewalObj = TestUtility.createRenewal(subscriptionObj.id,itemsObj.id,salesOrderLineObj.id);
      }
     @IsTest
    static void testAfterInsert(){
        
     }
}