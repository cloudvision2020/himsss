trigger SalesOrderLineTrigger on OrderApi__Sales_Order_Line__c (after insert) {
    TriggerDispatcher.Run(new SalesOrderLineTriggerHandler());
}