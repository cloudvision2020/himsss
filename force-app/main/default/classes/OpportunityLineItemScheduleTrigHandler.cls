public class OpportunityLineItemScheduleTrigHandler implements TriggerHandlerInterface{

    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
    public static Boolean isBypassOpportunityLineItemScheduleTrigger = false;

     /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public static Boolean IsDisabled()
    {
        System.debug('OpportunityLineItemScheduleTrigHandler.IsDisabled executing');
        if (TriggerSettings__c.getInstance('OpportunityLineItemSchedule').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<SObject> newItems) {
        System.debug('OpportunityLineItemScheduleTrigHandler|BeforeInsert|start:  '+newItems);
        //updateScheduleDate(newItems);
        if(newItems.getSObjectType(). getDescribe(). getName() == 'OpportunityLineItemSchedule'){
            List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>();
            Map<Id, OpportunityLineItemSchedule> olisMap = new Map<Id, OpportunityLineItemSchedule>();
            for(SObject olis : newItems){
                olisList.add((OpportunityLineItemSchedule)olis);
            }
            for(OpportunityLineItemSchedule olis: olisList){
                olisMap.put(olis.OpportunityLineItemId, olis);
            }
            Map<Id, OpportunityLineItem> oliMap = new Map<Id,OpportunityLineItem>([Select Id, End_Date__c, Use_End_Date__c from OpportunityLineItem where ID IN :olisMap.keyset()]);
            for(OpportunityLineItemSchedule olis: olisList){
                if(oliMap.get(olis.OpportunityLineItemId).Use_End_Date__c && oliMap.get(olis.OpportunityLineItemId).End_Date__c!=null){
                    String dateFormat = oliMap.get(olis.OpportunityLineItemId).End_Date__c.month() + '/' + oliMap.get(olis.OpportunityLineItemId).End_Date__c.day() + '/' + oliMap.get(olis.OpportunityLineItemId).End_Date__c.year();
                    olis.ScheduleDate = Date.parse(dateFormat);   
                }
            }
        }
        
        OpportunityLineItemTriggerHandler.isBypassTrigger = true;
        System.debug('OpportunityLineItemScheduleTrigHandler|BeforeInsert|end:  ');
    }
     
    /*public static void updateScheduleDate(List<OpportunityLineItemSchedule> newItems){
        System.debug('OpportunityLineItemScheduleTrigHandler|updateScheduleDate|start:  ');
        List<String> olisIdList = new List<String>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Map<String, Date> oliMap = new Map<String, Date>();
        
        System.debug('OpportunityLineItemScheduleTrigHandler|updateScheduleDate|newItems:  ' + newItems);
        for(OpportunityLineItemSchedule olisRecord : newItems){
            if(!olisIdList.contains(olisRecord.OpportunityLineItemId)){
                olisIdList.add(olisRecord.OpportunityLineItemId);
            }
        }        
        System.debug('OpportunityLineItemScheduleTrigHandler|updateScheduleDate|olisIdList:  ' + olisIdList);
        if(olisIdList.size() > 0){
            oliList = [SELECT Id , Start_Date__c, End_Date__c, UnitPrice, TotalPrice,
                       Contract_Line_Item__c, Product2.Use_End_Date__c
                       FROM OpportunityLineItem
                       WHERE Id IN : olisIdList
                      ];
        	System.debug('OpportunityLineItemScheduleTrigHandler|updateScheduleDate|oliList:  ' + oliList);
            if(oliList.size() > 0){
                for(OpportunityLineItem oliRecord : oliList){
                    if(oliRecord.Product2.Use_End_Date__c){
                        oliMap.put(oliRecord.Id, oliRecord.End_Date__c);
                    }
                }
            }
        }
        	System.debug('OpportunityLineItemScheduleTrigHandler|updateScheduleDate|oliMap:  ' + oliMap);
        if(oliMap.size() > 0){
            for(OpportunityLineItemSchedule olisRecord : newItems){
                if(oliMap.containsKey(olisRecord.OpportunityLineItemId)){
                    olisRecord.ScheduleDate = oliMap.get(olisRecord.OpportunityLineItemId);
                }
            }
        }
    }*/
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        for(sObject sObj : newItems.values()){
            if(sObj.getSObjectType(). getDescribe(). getName() == 'OpportunityLineItemSchedule'){
                OpportunityLineItemSchedule olis = (OpportunityLineItemSchedule) sObj;
                if(olis.Use_End_Date__c){
                    Date endDate = [Select Id, End_Date__c from OpportunityLineItem where ID = :olis.OpportunityLineItemId].End_Date__c;
                    if(endDate!=null){
                        String dateFormat = endDate.month() + '/' + endDate.day() + '/' + endDate.year();
                        olis.ScheduleDate = Date.parse(dateFormat);   
                    }
                }
            }
        }
        OpportunityLineItemTriggerHandler.isBypassTrigger = true;
        
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {
        
        OpportunityLineItemTriggerHandler.isBypassTrigger = true;
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) {
        
        if(!isBypassOpportunityLineItemScheduleTrigger){
            OpportunityLineItemTriggerHandler.isBypassTrigger = true;
            createContractLineItemSchedule((Map<Id, OpportunityLineItemSchedule>) newItems);
        }
        
        
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {

        updateContractLineItemSchedule((Map<Id, OpportunityLineItemSchedule>) newItems , (Map<Id, OpportunityLineItemSchedule>) oldItems);
        OpportunityLineItemTriggerHandler.isBypassTrigger = true;
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) {

        deleteContractLineItemSchedule((Map<Id, OpportunityLineItemSchedule>) oldItems);
        OpportunityLineItemTriggerHandler.isBypassTrigger = true;
        
    }
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {
        
        OpportunityLineItemTriggerHandler.isBypassTrigger = true;
        
    }

    /**
    * @description update Contract Line Item Schedule after  update Opportunity Line Item schedule 
	*/
    public static void updateContractLineItemSchedule(Map<Id, OpportunityLineItemSchedule> newItems, Map<Id, OpportunityLineItemSchedule> oldItems){

        Set<Id> contractLineItemIds = getcontractLineItemIdsForDelete(newItems);
        // delete existing Contract Line Items Schedule before   update  Opportunity Line Item schedule 
        OpportunityLineItemTriggerHandler.deleteContractLineItemsSchedule(contractLineItemIds);


        Set<Id> opportunityLineItemIds = new Set<Id>();
       for(OpportunityLineItemSchedule opportunityLineItemScheduleObj : newItems.values()){
           
          opportunityLineItemIds.add(OpportunityLineItemScheduleObj.OpportunityLineItemId);
       }

       Set<Id> opportunityLineItemScheduleIds = new Set<Id>();
       for(OpportunityLineItemSchedule opportunityLineItemScheduleObj : [SELECT Id FROM OpportunityLineItemSchedule 
                                                                         WHERE OpportunityLineItemId =: opportunityLineItemIds])
        {
            opportunityLineItemScheduleIds.add(opportunityLineItemScheduleObj.Id);
        }
        createContractLineItemScheduleInFuture(contractLineItemIds,opportunityLineItemScheduleIds);

    }
    /**
    * @description create Contract Line Item Schedule after insert, update and delete Opportunity Line Item schedule 
	*/
    public static void createContractLineItemSchedule(Map<Id, OpportunityLineItemSchedule> newItems){

        Set<Id> contractLineItemIds = getcontractLineItemIdsForDelete(newItems);
         // delete existing Contract Line Items Schedule before   insert  Opportunity Line Item schedule 
        OpportunityLineItemTriggerHandler.deleteContractLineItemsSchedule(contractLineItemIds);

        Set<Id> oliIds = new Set<Id>();
        for(OpportunityLineItemSchedule olis : newItems.values()){
            oliIds.add(olis.OpportunityLineItemId);
        }
        Map<Id,OpportunityLineItemSchedule> olisMap = new Map<Id,OpportunityLineItemSchedule>([SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId IN :oliIds]);
        createContractLineItemScheduleInFuture(contractLineItemIds, olisMap.keySet());
        
    }
     /**
    * @description create Contract Line Item Schedule after insert and update Opportunity Line Item schedule 
	*/
    @future
    public static void createContractLineItemScheduleInFuture(Set<Id> contractLineItemIds , Set<Id> opportunityLineItemScheduleIds){
              
        List<OpportunityLineItemSchedule> opportunityLineItemScheduleList = [SELECT Id ,Revenue,  OpportunityLineItem.OpportunityId, OpportunityLineItemId,ScheduleDate, 
                                                                                OpportunityLineItem.UnitPrice,
                                                                                OpportunityLineItem.Rate_Type__c
                                                                                FROM OpportunityLineItemSchedule
                                                                                WHERE Id =: opportunityLineItemScheduleIds
                                                                                AND OpportunityLineItem.Opportunity.RecordTypeId =: Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID];
        
        OpportunityLineItemTriggerHandler.createContractLineItemSchedule(contractLineItemIds, opportunityLineItemScheduleList);
    } 
        
     /**
    * @description delete Contract Line Item Schedule after delete Opportunity Line Item schedule 
	*/
    public static void deleteContractLineItemSchedule(Map<Id, OpportunityLineItemSchedule> oldItems){

        Set<Id> contractLineItemIds = getcontractLineItemIdsForDelete(oldItems);
        //get Contract Line Item Schedule id for delete before delete Opportunity Line Item Schedule
        OpportunityLineItemTriggerHandler.deleteContractLineItemsSchedule(contractLineItemIds);

        Set<Id> opportunityLineItemIds = new Set<Id>();
       for(OpportunityLineItemSchedule opportunityLineItemScheduleObj : oldItems.values()){
          opportunityLineItemIds.add(OpportunityLineItemScheduleObj.OpportunityLineItemId);
       }

       Set<Id> opportunityLineItemScheduleIds = new Set<Id>();
       for(OpportunityLineItemSchedule opportunityLineItemScheduleObj : [SELECT Id FROM OpportunityLineItemSchedule 
                                                                         WHERE OpportunityLineItemId =: opportunityLineItemIds])
        {
            opportunityLineItemScheduleIds.add(opportunityLineItemScheduleObj.Id);
        }
        createContractLineItemScheduleInFuture(contractLineItemIds,opportunityLineItemScheduleIds);
    }
     /**
    * @description get existing Contract Line Item Schedule id for delete before, insert ,update and  delete Opportunity Line Item Schedule 
	*/
    public static  Set<Id> getcontractLineItemIdsForDelete(Map<Id, OpportunityLineItemSchedule> opportunityLineItemScheduleMap){
        
        Set<Id> contractLineItemIds = new Set<Id>();        
        Set<Id> opportunityLineItemIds = new Set<Id>();
        for(OpportunityLineItemSchedule opportunityLineItemScheduleObj  :opportunityLineItemScheduleMap.values())
        {
            opportunityLineItemIds.add(opportunityLineItemScheduleObj.OpportunityLineItemId);
                       
        }
        for(OpportunityLineItem opportunityLineItemObj :[SELECT Id,Contract_Line_Item__c FROM OpportunityLineItem 
                                                        WHERE Id =: opportunityLineItemIds
                                                        And Opportunity.RecordTypeId =: Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID])
        {
            contractLineItemIds.add(opportunityLineItemObj.Contract_Line_Item__c);
        }
    
        return contractLineItemIds;
    }
}