@isTest
public with sharing class OpportunityRelatedProducts_t {
    @testSetup static void  testSetupData() {

        TestUtility.createTriggerSettings();
        Opportunity opportunityObj =  TestUtility.createOpportunity();
        TestUtility.createOpportunityLineItem(opportunityObj);
    }
    @isTest
    public static void testGetpriceBookName(){
        Opportunity opportunityObj = [SELECT Id FROM Opportunity LIMIT 1];
        System.assertNotEquals(opportunityObj, null);
        OpportunityRelatedProducts_c.getpriceBookName(opportunityObj.Id);
    }
    @isTest
    public static void testSaveProductList(){
        Opportunity opportunityObj = [SELECT Id,Pricebook2Id FROM Opportunity LIMIT 1];
        OpportunityLineItem opportunityLineItemObj = [SELECT Id,TotalPrice,UnitPrice, Quantity,Discount, Contract_Line_Item__c FROM OpportunityLineItem LIMIT 1];
        System.assertNotEquals(opportunityLineItemObj.Id, null);
        List<OpportunityProductEditableList_c.FieldDetails> listWrapper= new List<OpportunityProductEditableList_c.FieldDetails>();
        OpportunityProductEditableList_c.FieldDetails fieldDetailsWrapperObj = new OpportunityProductEditableList_c.FieldDetails();
        fieldDetailsWrapperObj.fieldLabel = 'Product Name';
        fieldDetailsWrapperObj.fieldName ='Quantity';
        fieldDetailsWrapperObj.fieldValue = '5';
        fieldDetailsWrapperObj.isUpdateable = true;
        fieldDetailsWrapperObj.fieldType = 'Number';
        listWrapper.add(fieldDetailsWrapperObj);
        
        OpportunityProductEditableList_c.FieldDetails fieldDetailsWrapperObj1 = new OpportunityProductEditableList_c.FieldDetails();
        fieldDetailsWrapperObj1.fieldLabel = 'Start Date';
        fieldDetailsWrapperObj1.fieldName ='Start_Date__c';
        fieldDetailsWrapperObj1.fieldValue = String.valueOf(System.today());
        fieldDetailsWrapperObj1.isUpdateable = true;
        fieldDetailsWrapperObj1.fieldType = 'Date';
        listWrapper.add(fieldDetailsWrapperObj1);
        
        OpportunityProductEditableList_c.FieldDetails fieldDetailsWrapperObj2 = new OpportunityProductEditableList_c.FieldDetails();
        fieldDetailsWrapperObj2.fieldLabel = 'Unit Price  ';
        fieldDetailsWrapperObj2.fieldName ='UnitPrice';
        fieldDetailsWrapperObj2.fieldValue = '100';
        fieldDetailsWrapperObj2.isUpdateable = true;
        fieldDetailsWrapperObj2.fieldType = 'currency';
        listWrapper.add(fieldDetailsWrapperObj2);

        OpportunityProductEditableList_c.FieldDetails fieldDetailsWrapperObj3 = new OpportunityProductEditableList_c.FieldDetails();
        fieldDetailsWrapperObj3.fieldLabel = 'Product Name';
        fieldDetailsWrapperObj3.fieldName ='End_Date__c';
        fieldDetailsWrapperObj3.fieldValue = String.valueOf(System.today().addDays(5));
        fieldDetailsWrapperObj3.isUpdateable = true;
        fieldDetailsWrapperObj3.fieldType = 'Date';
        listWrapper.add(fieldDetailsWrapperObj3);
            
        List<OpportunityProductEditableList_c.toDisplayWrapper> prodList = new  List<OpportunityProductEditableList_c.toDisplayWrapper>();
    
        OpportunityProductEditableList_c.toDisplayWrapper toDisplayWrapperobj = new OpportunityProductEditableList_c.toDisplayWrapper();
        toDisplayWrapperobj.prodId = opportunityLineItemObj.Id;
        toDisplayWrapperobj.isRowEditable = true;
        toDisplayWrapperobj.fileDetailWrapper = listWrapper;
        prodList.add(toDisplayWrapperobj);
        OpportunityRelatedProducts_c.saveProductList(opportunityObj.Id, prodList);
        System.assertNotEquals(opportunityObj.Id, null);
    }
    
    @isTest
    public static void testSaveProductList1(){
        Opportunity opportunityObj = [SELECT Id,Pricebook2Id FROM Opportunity LIMIT 1];
        OpportunityLineItem opportunityLineItemObj = [SELECT Id,TotalPrice,UnitPrice, Quantity,Discount, Contract_Line_Item__c FROM OpportunityLineItem LIMIT 1];
        System.assertNotEquals(opportunityLineItemObj.Id, null);
        
        List<OpportunityProductEditableList_c.FieldDetails> listWrapper= new List<OpportunityProductEditableList_c.FieldDetails>();  
        
        OpportunityProductEditableList_c.FieldDetails fieldDetailsWrapperObj2 = new OpportunityProductEditableList_c.FieldDetails();
        fieldDetailsWrapperObj2.fieldLabel = 'Corporate Membership Discount Amount ';
        fieldDetailsWrapperObj2.fieldName ='Corporate_Membership_Discount_Amount__c';
        fieldDetailsWrapperObj2.fieldValue = '100';
        fieldDetailsWrapperObj2.isUpdateable = true;
        fieldDetailsWrapperObj2.fieldType = 'currency';
        listWrapper.add(fieldDetailsWrapperObj2);
       
        List<OpportunityProductEditableList_c.toDisplayWrapper> prodList = new  List<OpportunityProductEditableList_c.toDisplayWrapper>();
        OpportunityProductEditableList_c.toDisplayWrapper toDisplayWrapperobj = new OpportunityProductEditableList_c.toDisplayWrapper();

        toDisplayWrapperobj.prodId = opportunityLineItemObj.Id;
        toDisplayWrapperobj.isRowEditable = true;
        toDisplayWrapperobj.fileDetailWrapper = listWrapper;
        prodList.add(toDisplayWrapperobj);
        OpportunityRelatedProducts_c.saveProductList(opportunityObj.Id, prodList);
        System.assertNotEquals(opportunityObj.Id, null);

    }

    @isTest
    public static void testSaveProductList2(){
        Opportunity opportunityObj = [SELECT Id,Pricebook2Id FROM Opportunity LIMIT 1];
        OpportunityLineItem opportunityLineItemObj = [SELECT Id,TotalPrice,UnitPrice, Quantity,Discount, Contract_Line_Item__c FROM OpportunityLineItem LIMIT 1];
        System.assertNotEquals(opportunityLineItemObj.Id, null);
        
        List<OpportunityProductEditableList_c.FieldDetails> listWrapper= new List<OpportunityProductEditableList_c.FieldDetails>();  
        
        OpportunityProductEditableList_c.FieldDetails fieldDetailsWrapperObj2 = new OpportunityProductEditableList_c.FieldDetails();
        fieldDetailsWrapperObj2.fieldLabel = 'Corporate Member Discount';
        fieldDetailsWrapperObj2.fieldName ='Corporate_Member_Discount__c';
        fieldDetailsWrapperObj2.fieldValue = 'false';
        fieldDetailsWrapperObj2.isUpdateable = true;
        fieldDetailsWrapperObj2.fieldType = 'boolean';
        listWrapper.add(fieldDetailsWrapperObj2);
       
        List<OpportunityProductEditableList_c.toDisplayWrapper> prodList = new  List<OpportunityProductEditableList_c.toDisplayWrapper>();
        OpportunityProductEditableList_c.toDisplayWrapper toDisplayWrapperobj = new OpportunityProductEditableList_c.toDisplayWrapper();

        toDisplayWrapperobj.prodId = opportunityLineItemObj.Id;
        toDisplayWrapperobj.isRowEditable = true;
        toDisplayWrapperobj.fileDetailWrapper = listWrapper;
        prodList.add(toDisplayWrapperobj);
        OpportunityRelatedProducts_c.saveProductList(opportunityObj.Id, prodList);
        System.assertNotEquals(opportunityObj.Id, null);
    }

    @isTest
    public static void testSaveProductList3(){
        Opportunity opportunityObj = [SELECT Id,Pricebook2Id FROM Opportunity LIMIT 1];
        OpportunityLineItem opportunityLineItemObj = [SELECT Id,TotalPrice,UnitPrice, Quantity,Discount, Contract_Line_Item__c FROM OpportunityLineItem LIMIT 1];
        System.assertNotEquals(opportunityLineItemObj.Id, null);
        
        List<OpportunityProductEditableList_c.FieldDetails> listWrapper= new List<OpportunityProductEditableList_c.FieldDetails>();  
        
        OpportunityProductEditableList_c.FieldDetails fieldDetailsWrapperObj2 = new OpportunityProductEditableList_c.FieldDetails();
        fieldDetailsWrapperObj2.fieldLabel = 'Total Price';
        fieldDetailsWrapperObj2.fieldName ='TotalPrice';
        fieldDetailsWrapperObj2.fieldValue = '1001';
        fieldDetailsWrapperObj2.isUpdateable = true;
        fieldDetailsWrapperObj2.fieldType = 'currency';
        listWrapper.add(fieldDetailsWrapperObj2);
       
        List<OpportunityProductEditableList_c.toDisplayWrapper> prodList = new  List<OpportunityProductEditableList_c.toDisplayWrapper>();
        OpportunityProductEditableList_c.toDisplayWrapper toDisplayWrapperobj = new OpportunityProductEditableList_c.toDisplayWrapper();

        toDisplayWrapperobj.prodId = opportunityLineItemObj.Id;
        toDisplayWrapperobj.isRowEditable = true;
        toDisplayWrapperobj.fileDetailWrapper = listWrapper;
        prodList.add(toDisplayWrapperobj);
        OpportunityRelatedProducts_c.saveProductList(opportunityObj.Id, prodList);
        System.assertNotEquals(opportunityObj.Id, null);

    }
}