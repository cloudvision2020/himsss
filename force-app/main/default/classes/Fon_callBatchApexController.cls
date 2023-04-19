public class Fon_callBatchApexController {
    @AuraEnabled(cacheable = true)
    public static AuditSubscriptionsWrapper searchSubscriptionsList(Id itemId){
        //get custom metadata
        //FON_Item_Audit_Setting__mdt itemSetting = FON_Item_Audit_Setting__mdt.getInstance(System.Label.Fon_Audit_Metadata_Record_Name); 
        FON_Item_Audit_Setting__mdt itemSetting =  Fon_callBatchApexController.auditMatadata;
        Integer noOfActiveSubs=0;
        AuditSubscriptionsWrapper subWrapper = new AuditSubscriptionsWrapper();                 
        list<AggregateResult> aggRes=[select count(id) numSubs from OrderApi__Subscription__c where OrderApi__Item__c=:ItemId and OrderApi__status__C='Active' group by OrderApi__Item__c];    
        if(!aggRes.isEmpty()){
            noOfActiveSubs=(Integer) aggRes[0].get('numSubs');
        }
        
        
        list<AggregateResult> aggRes1=[select count(Id) numSubs from OrderApi__Renewal__c where OrderApi__Subscription__r.OrderApi__status__C='Active' and Audit__c =true and  OrderApi__Subscription__r.OrderApi__Item__c =:ItemId group by OrderApi__Subscription__c];    
        Integer noOfAuditActiveSubs=aggRes1.size();
        
        Integer percNo=0;
        if(noOfActiveSubs>1)
        {
            percNo=(Integer)((itemSetting.Audit_Percentage__c/100)*noOfActiveSubs); 
        }
        
        subWrapper.activeSubscriptions=noOfActiveSubs;
        subWrapper.auditSubscriptions=noOfAuditActiveSubs;
        subWrapper.eligibleSubscriptions=percNo;
        
        return subWrapper;        
    }
    
    @AuraEnabled
    public static Id executeBatchJob(Id itemId,Integer eligibleSubscriptions){
        //get custom metadata
        FON_Item_Audit_Setting__mdt itemSetting =  Fon_callBatchApexController.auditMatadata;
        Fon_ItemAuditUpdateBachable  auditBatch = new Fon_ItemAuditUpdateBachable(ItemId,eligibleSubscriptions,itemSetting.Order_By__c);
        Id batchJobId;
        batchJobId = Database.executeBatch(auditBatch,1);
        return batchJobId;
    }
    
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }
    
    public class AuditSubscriptionsWrapper{
        @AuraEnabled
        public Integer activeSubscriptions{get;set;}
        @AuraEnabled
        public Integer auditSubscriptions{get;set;}
        @AuraEnabled
        public Integer eligibleSubscriptions{get;set;}
    }
    
    @testVisible static FON_Item_Audit_Setting__mdt auditMatadata{ 
        get{ 
            if(auditMatadata == NULL){ 
                auditMatadata =  FON_Item_Audit_Setting__mdt.getInstance(System.Label.Fon_Audit_Metadata_Record_Name); 
            } 
            return auditMatadata; 
        } 
        set; 
    } 
}