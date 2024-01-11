public class OpportunityLineItemTriggerHandler implements TriggerHandlerInterface

{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
    public static Boolean isBypassTrigger = false;
     
    /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public static Boolean IsDisabled()
    {
        System.debug('OpportunityLineItemTriggerHandler.IsDisabled executing');
        if (TriggerSettings__c.getInstance('OpportunityLineItem').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<OpportunityLineItem> newItems) {
        if(newItems.getSObjectType().getDescribe().getName() == 'OpportunityLineItem'){
               for(OpportunityLineItem oli : newItems){
                if(oli.Use_End_Date__c){
                    oli.Start_Date__c = oli.End_Date__c;
                }
                   
                
            }
        }
    }
     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {

        deleteContractLineItems((Map<Id, OpportunityLineItem >) oldItems);
    }
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        System.debug('OpportunityLineItemTriggerHandler|AfterInsert|start:  ');    
        
        
        createContractLineItems((Map<Id, OpportunityLineItem >)newItems);
        Set<String> setOppIds = new Set<String>();
        for(Id ids : newItems.keySet()){
            setOppIds.add(ids);
        } 
        //updateOpportunityLineItemSchedule(setOppIds);       
        createOpportunityLineItemSchedule(setOppIds,new Map<Id, Boolean>());
        List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>();
        for(OpportunityLineItemSchedule olis : [select Id, OpportunityLineItemId, OpportunityLineItem.Name, OpportunityLineItem.End_Date__c, OpportunityLineItem.Use_End_Date__c from OpportunityLineItemSchedule where OpportunityLineItemId IN : newItems.keyset()]){
            system.debug('currentOlis');
            system.debug(olis);

            if(olis.opportunityLineItem.Use_End_Date__c){
                olis.ScheduleDate = olis.OpportunityLineItem.End_Date__c;
            }
            olisList.add(olis);
        }
        OpportunityLineItemScheduleTrigHandler.isBypassOpportunityLineItemScheduleTrigger = true;
        update olisList;
        
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug('OpportunityLineItemTriggerHandler|AfterUpdate|start:  ');

        if(!OpportunityLineItemTriggerHandler.isBypassTrigger){
            
            OpportunityLineItemTriggerHandler.isBypassTrigger = true;
        	//updateOpportunityLineItemScheduleAfterUpdate((Map<Id, OpportunityLineItem>)newItems, (Map<Id, OpportunityLineItem>)oldItems);
            updateContractLineItems((Map<Id, OpportunityLineItem >)newItems ,(Map<Id, OpportunityLineItem >)oldItems);
           
        }
        
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    
    /*
     * date: 9/27/2021 
     * @description  updates line item schedule w/ appropriate schedule date
	*/
  /*  private Static void updateOpportunityLineItemSchedule(Set<String> opportunityLineItemIds){
        System.debug('OpportunityLineItemTriggerHandler|updateOpportunityLineItemSchedule|start:  ');
        System.debug('OpportunityLineItemTriggerHandler|updateOpportunityLineItemSchedule|opportunityLineItemIds:  ' + opportunityLineItemIds);
    
        Set<Id> contractLineItemIds = new Set<Id>();
        List<OpportunityLineItemSchedule> opportunityLineItemScheduleList = new List<OpportunityLineItemSchedule>();
        List<OpportunityLineItemSchedule> opportunityLineItemScheduleUpdateList = new List<OpportunityLineItemSchedule>();
        List<OpportunityLineItem> opportunityLineItemList = new List<OpportunityLineItem>();
        Map<String, Date> oliMap = new Map<String, Date>();
        
		opportunityLineItemList = [SELECT Id , Start_Date__c, End_Date__c, UnitPrice, TotalPrice,
                                                            Contract_Line_Item__c, Product2.Use_End_Date__c
                                                            FROM OpportunityLineItem
                                                            WHERE Id IN : opportunityLineItemIds
                                  ];       
        System.debug('OpportunityLineItemTriggerHandler|updateOpportunityLineItemSchedule|opportunityLineItemList:  ' + opportunityLineItemList);
        if(opportunityLineItemList.size() > 0){
            for(OpportunityLineItem opportunityLineItemObject : opportunityLineItemList){   
                if(opportunityLineItemObject.Product2.Use_End_Date__c){
                    oliMap.put(opportunityLineItemObject.Id, opportunityLineItemObject.End_Date__c);
                }else{
                    oliMap.put(opportunityLineItemObject.Id, opportunityLineItemObject.Start_Date__c);
                }
            }//end of loop
            opportunityLineItemScheduleList = [SELECT Id , ScheduleDate, OpportunityLineItemId
                                               FROM OpportunityLineItemSchedule
                                               WHERE OpportunityLineItemId IN : opportunityLineItemIds
                                              ];
        	System.debug('OpportunityLineItemTriggerHandler|updateOpportunityLineItemSchedule|opportunityLineItemScheduleList:  ' + opportunityLineItemScheduleList);
            if(opportunityLineItemScheduleList.size() > 0){
                for(OpportunityLineItemSchedule opportunityLineItemScheduleRecord : opportunityLineItemScheduleList){
                    if(oliMap.containsKey(opportunityLineItemScheduleRecord.OpportunityLineItemId)){
                        Date mapScheduleDate = oliMap.get(opportunityLineItemScheduleRecord.OpportunityLineItemId);
                        if(opportunityLineItemScheduleRecord.ScheduleDate != mapScheduleDate){
                            opportunityLineItemScheduleRecord.ScheduleDate = mapScheduleDate;
                            opportunityLineItemScheduleUpdateList.add(opportunityLineItemScheduleRecord);
                        }
                    }
                }//end of loop
            }
        }
        	System.debug('OpportunityLineItemTriggerHandler|updateOpportunityLineItemSchedule|opportunityLineItemScheduleUpdateList:  ' + opportunityLineItemScheduleUpdateList);
        if(opportunityLineItemScheduleUpdateList.size() > 0){
            OpportunityLineItemTriggerHandler.isBypassTrigger = true;
            OpportunityLineItemScheduleTrigHandler.isBypassOpportunityLineItemScheduleTrigger = true;
            update opportunityLineItemScheduleUpdateList;
        }
    }

    private void updateOpportunityLineItemScheduleAfterUpdate(Map<Id, OpportunityLineItem > newItems , Map<Id, OpportunityLineItem > oldItems){
        System.debug('OpportunityLineItemTriggerHandler|updateOpportunityLineItemScheduleAfterUpdate|start:  ');
        List<OpportunityLineItem> oliList = newItems.values();
        Set<String> opportunityLineItemIds = new Set<String>();
        
        if(oliList.size() > 0){
            for(OpportunityLineItem oliRecord : oliList){
                OpportunityLineItem oldRecord = oldItems.get(oliRecord.Id);
                if(oliRecord.Start_Date__c != oldRecord.Start_Date__c || oliRecord.End_Date__c != oldRecord.End_Date__c){
                    opportunityLineItemIds.add(oliRecord.Id);
                }
            }
            if(opportunityLineItemIds.size() > 0){
                updateOpportunityLineItemSchedule(opportunityLineItemIds);
            }
        }
        System.debug('OpportunityLineItemTriggerHandler|updateOpportunityLineItemScheduleAfterUpdate|end:  ');
    }*/
    /**
    * @description  createing Contract Line Item after insert  Opportunity Line 
	*/
    private void createContractLineItems(Map<Id, OpportunityLineItem > newItems){
        System.debug('Came in this part 1');
        Set<String> opportunityIds = new Set<String>();
        Map<String, List<OpportunityLineItem>> opportunityIdWithOpportunityLineItemsMap = new Map<String, List<OpportunityLineItem>>();
        Map<Id,OpportunityLineItem> newOLIs = new Map<Id,OpportunityLineItem>([SELECT Id, OpportunityId, Ad_Size2__c, Brand__c, CurrencyISOCode, Discount_Percent__c, End_Date__c, Description, ListPrice, ProductCode, Product2.Family, Product2.Name, Quantity, Rate_Type__c, Region__c, UnitPrice, Start_Date__c, TotalPrice FROM OpportunityLineItem WHERE Id IN : newItems.keySet()]);

        for(OpportunityLineItem opportunityLineItemObj : newOLIs.values()){

            opportunityIds.add(opportunityLineItemObj.OpportunityId);

            if(!opportunityIdWithOpportunityLineItemsMap.containsKey(opportunityLineItemObj.OpportunityId)){

                opportunityIdWithOpportunityLineItemsMap.put(opportunityLineItemObj.OpportunityId, new List<OpportunityLineItem>());
            }
            opportunityIdWithOpportunityLineItemsMap.get(opportunityLineItemObj.OpportunityId).add(opportunityLineItemObj);
        }    
       
        List<Contract> contracts =[SELECT Id,Opportunity__c FROM Contract 
                                    WHERE Opportunity__c =:opportunityIds
                                    AND Opportunity__r.RecordTypeId =:Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID];

        //getting Contract Line Items list with field maping from opportunity Line Items         
        List<Contract_Line_Item__c> contractLineItems = Utility.getContractLineItems(contracts, opportunityIdWithOpportunityLineItemsMap);
       
        if(!contractLineItems.isEmpty()){
           
            insert contractLineItems;
            OpportunityLineItemTriggerHandler.isBypassTrigger = true;
            updateOpportunityLineItems(contractLineItems, newItems.keySet());
        }
    }
   /**
    * @description after inserting  Contract  Line Item, update Opportunity Line Items field name 'Contract Line Item' with Contract Line Iiemt Id
	*/
    private void updateOpportunityLineItems(List<Contract_Line_Item__c> contractLineItems , Set<Id> opportunityLineItemIds){
         System.debug('Came in this part 2');
        Map<Id, OpportunityLineItem> opportunityLineItemIdWithopportunityLineItemObjMap = new Map<Id, OpportunityLineItem>([SELECT Id, Contract_Line_Item__c FROM OpportunityLineItem WHERE Id =:opportunityLineItemIds]);
                                                                                
        List<OpportunityLineItem> opportunityLineItems = new  List<OpportunityLineItem>();
        for(Contract_Line_Item__c ContractLineItemObj : contractLineItems){
            //get Contract Line Iiemt Id to update opportunity line item
            if(opportunityLineItemIdWithopportunityLineItemObjMap.containsKey(ContractLineItemObj.Opportunity_Line_Item_Id__c)){
                OpportunityLineItem opportunityLineItemObj = opportunityLineItemIdWithopportunityLineItemObjMap.get(ContractLineItemObj.Opportunity_Line_Item_Id__c);
                opportunityLineItemObj.Contract_Line_Item__c = ContractLineItemObj.Id;
                opportunityLineItems.add(opportunityLineItemObj);

            }

        }
        
        if(!opportunityLineItems.isEmpty()){
            OpportunityLineItemTriggerHandler.isBypassTrigger = true;
            update opportunityLineItems;
        }
    }
     /**
    * @description update Contract  Line Iiemt  after  update Opportunity Line Items 
	*/
    private void updateContractLineItems(Map<Id, OpportunityLineItem > newItems , Map<Id, OpportunityLineItem > oldItems){
         System.debug('Came in this part 3');
        Set<String> opportunityLineItemIds = new Set<String>();
        Set<Id> contractLineItemIdsForDeleteContractLineItemSchedul = new Set<Id>();
        Set<String> contractLineItemIds = new Set<String>();
        
        Map<Id,OpportunityLineItem> opportunityLineItemIdWithOpportunityLineItemObj = new  Map<Id,OpportunityLineItem>();
        //check if only add Size2 change
        Map<Id,Boolean> opportunityLineItemIdWithIsAdSize2Change = new  Map<Id,Boolean>();

        for(OpportunityLineItem opportunityLineItemObj :[SELECT Id ,Brand__c, Start_Date__c, End_Date__c, Quantity, UnitPrice, 
                                                        Discount_Percent__c,Contract_Line_Item__c,
                                                        Ad_Size2__c,Description, Rate_Type__c, TotalPrice
                                                        FROM OpportunityLineItem
                                                        WHERE Id =: newItems.keySet()
                                                        AND Opportunity.RecordTypeId =: Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID])
        {

            if(oldItems.containsKey(opportunityLineItemObj.Id))
            {
                OpportunityLineItem oldItemObj = oldItems.get(opportunityLineItemObj.Id);
                // check fields for update
                if(opportunityLineItemObj.Start_Date__c != oldItemObj.Start_Date__c ||
                    opportunityLineItemObj.Quantity != oldItemObj.Quantity ||
                    opportunityLineItemObj.UnitPrice != oldItemObj.UnitPrice ||
                    opportunityLineItemObj.Discount_Percent__c != oldItemObj.Discount_Percent__c ||
                    opportunityLineItemObj.TotalPrice != oldItemObj.TotalPrice ||
                    opportunityLineItemObj.End_Date__c != oldItemObj.End_Date__c ){
                    // for update Contract Line Item
                    contractLineItemIds.add(opportunityLineItemObj.Contract_Line_Item__c);
                    opportunityLineItemIdWithOpportunityLineItemObj.put(opportunityLineItemObj.Id, opportunityLineItemObj);
                    opportunityLineItemIdWithIsAdSize2Change.put(opportunityLineItemObj.Id , false);
                    
                    // for delete opportunity Line Item Schedule
                    opportunityLineItemIds.add(opportunityLineItemObj.Id);
                     // for delete Contract Line Item Schedul
                    contractLineItemIdsForDeleteContractLineItemSchedul.add(opportunityLineItemObj.Contract_Line_Item__c);
                }
                //check if Ad_Size2__c only change
               else if( opportunityLineItemObj.Ad_Size2__c != oldItemObj.Ad_Size2__c && 
                    opportunityLineItemObj.Start_Date__c == oldItemObj.Start_Date__c && opportunityLineItemObj.End_Date__c == oldItemObj.End_Date__c &&
                    opportunityLineItemObj.Quantity == oldItemObj.Quantity && opportunityLineItemObj.TotalPrice == oldItemObj.TotalPrice &&
                    opportunityLineItemObj.UnitPrice == oldItemObj.UnitPrice && opportunityLineItemObj.Discount_Percent__c == oldItemObj.Discount_Percent__c  ){

                    contractLineItemIds.add(opportunityLineItemObj.Contract_Line_Item__c);
                    opportunityLineItemIdWithOpportunityLineItemObj.put(opportunityLineItemObj.Id, opportunityLineItemObj);
                    opportunityLineItemIdWithIsAdSize2Change.put(opportunityLineItemObj.Id , true);
                }
            }
        }

        
       //update Contract Line Item after opportunity Line Item update
        List<Contract_Line_Item__c > contractLineItems = [SELECT Id,Opportunity_Line_Item_Id__c, Ad_Size__c, Brand__c, Discount__c, End_Date__c,
                                                             Line_Description__c, Rate_Type__c, Quantity__c,
                                                             Sales_Price__c, Start_Date__c, Total_Price__c FROM Contract_Line_Item__c 
                                                            WHERE id =: contractLineItemIds];
        
        for(Contract_Line_Item__c contractLineItemObj : contractLineItems){

            if(opportunityLineItemIdWithOpportunityLineItemObj.containsKey(contractLineItemObj.Opportunity_Line_Item_Id__c)){

                OpportunityLineItem opportunityLineItemObj = opportunityLineItemIdWithOpportunityLineItemObj.get(contractLineItemObj.Opportunity_Line_Item_Id__c);
                
                contractLineItemObj.Brand__c = opportunityLineItemObj.Brand__c;
                contractLineItemObj.Start_Date__c = opportunityLineItemObj.Start_Date__c;
                contractLineItemObj.End_Date__c = opportunityLineItemObj.End_Date__c;
                contractLineItemObj.Quantity__c = opportunityLineItemObj.Quantity;
                contractLineItemObj.Sales_Price__c = opportunityLineItemObj.UnitPrice;
                contractLineItemObj.Discount__c = opportunityLineItemObj.Discount_Percent__c;
                contractLineItemObj.Ad_Size__c = opportunityLineItemObj.Ad_Size2__c;
                contractLineItemObj.Line_Description__c = opportunityLineItemObj.Description;
                contractLineItemObj.Rate_Type__c = opportunityLineItemObj.Rate_Type__c;
                contractLineItemObj.Total_Price__c = opportunityLineItemObj.TotalPrice;
                system.debug('Inside For contractLineItemObj total Price---'+contractLineItemObj.Total_Price__c);
                system.debug('Inside For opportunityLineItemObj total Price---'+opportunityLineItemObj.TotalPrice);

            }

        }
        system.debug('Before contractLineItemObj update total Price---'+contractLineItems);
        update contractLineItems;
        createOpportunityLineItemSchedule(opportunityLineItemIds,opportunityLineItemIdWithIsAdSize2Change);
    
    }
    /**
    * @description delete  Contract  Line Iemts if  Opportunity Line Item end date not in past and opportunity (RT: HIMSS_Media)
	*/
    private void deleteContractLineItems(Map<Id, OpportunityLineItem > oldItems ){
        System.debug('Came in this part 4');
        Set<String> opportunityLineItemIds = new Set<String>();
        for(OpportunityLineItem OpportunityLineItemObj : [SELECT Id,End_Date__c FROM OpportunityLineItem
                                                            WHERE Id =: oldItems.keySet()
                                                            AND End_Date__c > today
                                                            AND Opportunity.RecordTypeId =: Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID])
        {
            opportunityLineItemIds.add(OpportunityLineItemObj.Id);
        }
        if(!opportunityLineItemIds.isEmpty()){
            List<Contract_Line_Item__c > contractLineItems = [SELECT Id,Opportunity_Line_Item_Id__c 
                                                                FROM Contract_Line_Item__c 
                                                            WHERE Opportunity_Line_Item_Id__c =: opportunityLineItemIds];
            if(!contractLineItems.isEmpty()) {
                delete contractLineItems;
            } 
        }
    }
    
    
    
    /**
    * @description create  Opportunity Line Item Schedule after insert, update and Delelet  Opportunity Line Item 
     according to  Opportunity Line Item start date  and end date deference
	*/
    @future
    private Static void createOpportunityLineItemSchedule(Set<String> opportunityLineItemIds,  Map<Id,Boolean> opportunityLineItemIdWithIsAdSize2Change){
         System.debug('Came in this part 5');
        System.debug('OpportunityLineItemTriggerHandler|createOpportunityLineItemSchedule|start:  ');
        System.debug('OpportunityLineItemTriggerHandler|createOpportunityLineItemSchedule|opportunityLineItemIds:  ' + opportunityLineItemIds);
        System.debug('OpportunityLineItemTriggerHandler|createOpportunityLineItemSchedule|opportunityLineItemIdWithIsAdSize2Change:  ' + opportunityLineItemIdWithIsAdSize2Change);
    
        Set<Id> contractLineItemIds = new Set<Id>();
        List<OpportunityLineItemSchedule> opportunityLineItemScheduleList = new List<OpportunityLineItemSchedule>();
                
        for(OpportunityLineItem opportunityLineItemObject :[SELECT Id , Start_Date__c, End_Date__c, UnitPrice, TotalPrice,
                                                            Contract_Line_Item__c, Use_End_Date__c, Product2.Use_End_Date__c
                                                            FROM OpportunityLineItem
                                                            WHERE Id IN : opportunityLineItemIds
                                                            AND Opportunity.RecordTypeId =: Constants.OPPORTUNITY_HIMSS_MEDIA_RECORDTYPEID
                                                            AND CanUseRevenueSchedule  = true])
        {   

            System.debug('OpportunityLineItemTriggerHandler|createOpportunityLineItemSchedule|opportunityLineItemObject:  ' + opportunityLineItemObject);
            contractLineItemIds.add(opportunityLineItemObject.Contract_Line_Item__c);
            
            Date scheduleStartDate;
            if(opportunityLineItemObject.Use_End_Date__c){
                scheduleStartDate = opportunityLineItemObject.End_Date__c;
            }else{
                scheduleStartDate = opportunityLineItemObject.Start_Date__c;
            }
            System.debug('OpportunityLineItemTriggerHandler|createOpportunityLineItemSchedule|scheduleStartDate:  ' + scheduleStartDate);
            //get deference between start date and end date
            Integer numberofInstallments =  opportunityLineItemObject.Start_Date__c.monthsBetween(opportunityLineItemObject.End_Date__c);
            numberofInstallments++;
                                
            for(Integer i = 0; i<numberofInstallments; i++){

                scheduleStartDate = scheduleStartDate.addMonths(1).toStartofMonth().addDays(-1);

                OpportunityLineItemSchedule opportunityLineItemScheduleObject = new OpportunityLineItemSchedule();

                opportunityLineItemScheduleObject.OpportunityLineItemId = opportunityLineItemObject.Id;
                opportunityLineItemScheduleObject.ScheduleDate = scheduleStartDate;
                
                opportunityLineItemScheduleObject.Revenue = opportunityLineItemObject.TotalPrice / numberofInstallments;
                opportunityLineItemScheduleObject.Type = 'Revenue';
            	System.debug('OpportunityLineItemTriggerHandler|createOpportunityLineItemSchedule|opportunityLineItemScheduleObject.ScheduleDate:  ' + opportunityLineItemScheduleObject.ScheduleDate);
                
                //Check after update  opportunity Line Item Ad_Size2__c 
                if(!opportunityLineItemIdWithIsAdSize2Change.isEmpty()){
                    if(opportunityLineItemIdWithIsAdSize2Change.containsKey(opportunityLineItemObject.Id) && !opportunityLineItemIdWithIsAdSize2Change.get(opportunityLineItemObject.Id)){
                        opportunityLineItemScheduleList.add(opportunityLineItemScheduleObject);
                    }
                }else{
                    opportunityLineItemScheduleList.add(opportunityLineItemScheduleObject);
                }
                scheduleStartDate = scheduleStartDate.addMonths(1);
            }
        }
    
        if(!opportunityLineItemScheduleList.isEmpty()){

            OpportunityLineItemTriggerHandler.isBypassTrigger = true;
            OpportunityLineItemScheduleTrigHandler.isBypassOpportunityLineItemScheduleTrigger = true;

            deleteContractLineItemsSchedule(contractLineItemIds);            
           // insert opportunityLineItemScheduleList;
            
            //New Code-Start
            Map<string,Contract_Line_Item__c> allContractLineItems=new Map<string,Contract_Line_Item__c>();
            List<Contract_Line_Item_Schedule__c> contractLineItemScheduleList = new List<Contract_Line_Item_Schedule__c>();
            Map<Id, List<OpportunityLineItemSchedule>> opportunityLineItemScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();

            for(OpportunityLineItemSchedule opportunityLineItemScheduleObj :opportunityLineItemScheduleList)
            {
                if(!opportunityLineItemScheduleMap.containsKey(opportunityLineItemScheduleObj.OpportunityLineItemId)){
                    opportunityLineItemScheduleMap.put(opportunityLineItemScheduleObj.OpportunityLineItemId, new List<OpportunityLineItemSchedule>());
                }
                opportunityLineItemScheduleMap.get(opportunityLineItemScheduleObj.OpportunityLineItemId).add(opportunityLineItemScheduleObj);
            }
            
            List<Contract_Line_Item__c> contractLineItem=[select Id,Opportunity_Line_Item_Id__c,Total_Price__c,Sales_Price__c from Contract_Line_Item__c WHERE Id=:contractLineItemIds];
            List<OpportunityLineItemSchedule> finalOppLineItemScheduleList=new List<OpportunityLineItemSchedule>();    
         
            for(Contract_Line_Item__c tempItems:contractLineItem)
            {
            System.debug('Came inside contract loop---'+tempItems.ID);
            Double price=tempItems.Total_Price__c;            
            List<Contract_Line_Item_Schedule__c> contractLineITemSchedule=[select ID,Extended_Amount__c,Billing_Date__c,Date__c,Amount__c,
                                                                     Set_Billing_Date__c,Contract_Line_Item__c from  Contract_Line_Item_Schedule__c 
                                                                           WHERE Contract_Line_Item__c=:tempItems.ID];
                
            List<Contract_Line_Item_Schedule__c> contractLineItemList=new List<Contract_Line_Item_Schedule__c>();            
            Integer count=0;
            Double newPrice; 
            //Create New List with Old contract passed month and new contract with adjusted amount---Start
            System.debug('Came inside contract loop---contractLineITemSchedule'+contractLineITemSchedule.size());
            if(contractLineITemSchedule.size()>0)
            {            
            for(Contract_Line_Item_Schedule__c tempRecord:contractLineITemSchedule)
            {
                 System.debug('Came inside contract loop---contractLineITemSchedule23'+tempRecord.Set_Billing_Date__c);
               if(tempRecord.Set_Billing_Date__c==true)
                {
                  contractLineItemList.add(tempRecord);
                  price=price-(tempRecord.Extended_Amount__c);
                  count++;
                }
                else
                {
                  System.debug('Came inside this loop inner 2');
                  
                  contractLineItemList.add(tempRecord);   
                }
            } 
               
            Integer newcount=0;                
             for(OpportunityLineItemSchedule itteration1:opportunityLineItemScheduleList)
            {
                if(itteration1.OpportunityLineItemId==tempItems.Opportunity_Line_Item_Id__c)
                {
                   newcount++; 
                }
            }
                 System.debug('All Count Values---'+count+'----'+newcount);
                 System.debug('New Price---'+newPrice);
                 newPrice=price/(newcount-count);
                
            for(OpportunityLineItemSchedule itteration1:opportunityLineItemScheduleList)
            {
                if(itteration1.OpportunityLineItemId==tempItems.Opportunity_Line_Item_Id__c)
                {
                    for(Contract_Line_Item_Schedule__c itteration2:contractLineITemSchedule)
                    {
                        if(itteration2.Date__c==itteration1.ScheduleDate)
                        {
                            itteration1.Revenue=itteration2.Amount__c;
                            finalOppLineItemScheduleList.add(itteration1);
                        }
                        else
                        {
                           itteration1.revenue= newPrice;    
                           finalOppLineItemScheduleList.add(itteration1); 
                        }
                    }
                   
                }
            }
            
                
            }
            else
            {
              for(OpportunityLineItemSchedule itteration1:opportunityLineItemScheduleList)
            {
                if(itteration1.OpportunityLineItemId==tempItems.Opportunity_Line_Item_Id__c) 
                {
                  finalOppLineItemScheduleList.add(itteration1);  
                }
            }            
                
            }
            }
            System.debug('All Values---'+finalOppLineItemScheduleList);
            insert  finalOppLineItemScheduleList; 
            //New Code End
            
            //insert opportunityLineItemScheduleList;
            createContractLineItemSchedule(contractLineItemIds, opportunityLineItemScheduleList); 
            
        }
    }
    
     /**
    * @description creating Contract Line Item Schedule recoreds after insert and update Opportunity Line Item 
	*/
    public static void createContractLineItemSchedule(Set<Id> contractLineItemIds , List<OpportunityLineItemSchedule> opportunityLineItemScheduleList){
         System.debug('Came in this part 6');
        Map<Id, List<OpportunityLineItemSchedule>> opportunityLineItemScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();

        for(OpportunityLineItemSchedule opportunityLineItemScheduleObj : [SELECT Id ,Revenue,  OpportunityLineItem.OpportunityId, OpportunityLineItemId,ScheduleDate, 
                                                                                OpportunityLineItem.UnitPrice,Type,
                                                                                OpportunityLineItem.Rate_Type__c
                                                                                FROM OpportunityLineItemSchedule
                                                                                WHERE Id =: opportunityLineItemScheduleList])
            {
                if(!opportunityLineItemScheduleMap.containsKey(opportunityLineItemScheduleObj.OpportunityLineItemId)){
                    opportunityLineItemScheduleMap.put(opportunityLineItemScheduleObj.OpportunityLineItemId, new List<OpportunityLineItemSchedule>());
                }
                opportunityLineItemScheduleMap.get(opportunityLineItemScheduleObj.OpportunityLineItemId).add(opportunityLineItemScheduleObj);
            }
        Map<string,Contract_Line_Item__c> allContractLineItems=new Map<string,Contract_Line_Item__c>();
        List<Contract_Line_Item_Schedule__c> contractLineItemScheduleList = new List<Contract_Line_Item_Schedule__c>();
        //Added by Sulabh
        set<string> allIds=new set<string>();
        for(Contract_Line_Item__c contractLineItemObj : [SELECT Id,Opportunity_Line_Item_Id__c, Start_Date__c,
                                                            End_Date__c,Discount__c,Quantity__c
                                                         FROM Contract_Line_Item__c
                                                         WHERE  Id =: contractLineItemIds])
            {
                allContractLineItems.put(contractLineItemObj.Id,contractLineItemObj);                  
                if(opportunityLineItemScheduleMap.containsKey(contractLineItemObj.Opportunity_Line_Item_Id__c)){

                    
                    Decimal installments = opportunityLineItemScheduleMap.get(contractLineItemObj.Opportunity_Line_Item_Id__c).size();
                    for(OpportunityLineItemSchedule  opportunityLineItemScheduleOnj : opportunityLineItemScheduleMap.get(contractLineItemObj.Opportunity_Line_Item_Id__c)){
                        Double discount = contractLineItemObj.Discount__c == null ? 0 : contractLineItemObj.Discount__c;
						Double price = discount==0 ? opportunityLineItemScheduleOnj.Revenue : opportunityLineItemScheduleOnj.Revenue * (1/(1-(discount/100)));
                        Contract_Line_Item_Schedule__c contractLineItemScheduleObj = new Contract_Line_Item_Schedule__c();

                        contractLineItemScheduleObj.Contract_Line_Item__c = contractLineItemObj.Id;
                        contractLineItemScheduleObj.Date__c =opportunityLineItemScheduleOnj.ScheduleDate;
                        
                        if(opportunityLineItemScheduleOnj.OpportunityLineItem.UnitPrice != 0){
                            if(opportunityLineItemScheduleOnj.OpportunityLineItem.Rate_Type__c == 'Flat Fee'){ 
                                contractLineItemScheduleObj.Quantity__c = 1;
                                contractLineItemScheduleObj.Amount__c =opportunityLineItemScheduleOnj.Revenue;
                            }
                        	else if(opportunityLineItemScheduleOnj.OpportunityLineItem.Rate_Type__c == 'CPM'){ 
                                contractLineItemScheduleObj.Quantity__c = (price / opportunityLineItemScheduleOnj.OpportunityLineItem.UnitPrice)*1000;
                                contractLineItemScheduleObj.Amount__c =(opportunityLineItemScheduleOnj.Revenue / contractLineItemScheduleObj.Quantity__c)*1000;
                            }
                            else{
                                contractLineItemScheduleObj.Quantity__c = (price / opportunityLineItemScheduleOnj.OpportunityLineItem.UnitPrice);
                                contractLineItemScheduleObj.Amount__c =opportunityLineItemScheduleOnj.Revenue / contractLineItemScheduleObj.Quantity__c;
                            }
                        }
                        else{
                            contractLineItemScheduleObj.Quantity__c = 0;
                        }  
                        contractLineItemScheduleList.add(contractLineItemScheduleObj);
                        system.debug('Line 470 contractLineItemScheduleObj'+contractLineItemScheduleObj.Contract_Line_Item__c+'---'+contractLineItemScheduleObj.Amount__c);
                        allIds.add(contractLineItemScheduleObj.Contract_Line_Item__c);
                    }
                }
            }
        if(!contractLineItemScheduleList.isEmpty()){
           
            //Sulabh Logic To be added
            List<Contract_Line_Item__c> contractLineItem=[select Id,Total_Price__c,Sales_Price__c from Contract_Line_Item__c WHERE Id=:allIds];
            List<Contract_Line_Item_Schedule__c> finalContractLineItemList=new List<Contract_Line_Item_Schedule__c>();            
            for(Contract_Line_Item__c tempItems:contractLineItem)
            {
            Double price=tempItems.Total_Price__c;            
            List<Contract_Line_Item_Schedule__c> contractLineITemSchedule=[select ID,Extended_Amount__c,Billing_Date__c,Date__c,Amount__c,
                                                                     Set_Billing_Date__c,Contract_Line_Item__c from  Contract_Line_Item_Schedule__c 
                                                                           WHERE Contract_Line_Item__c=:tempItems.ID];
            List<Contract_Line_Item_Schedule__c> contractLineItemList=new List<Contract_Line_Item_Schedule__c>();            
            Integer count=0; 
            //Create New List with Old contract passed month and new contract with adjusted amount---Start
            if(contractLineITemSchedule.size()>0)
            {            
            for(Contract_Line_Item_Schedule__c tempRecord:contractLineItemScheduleList)
            { 
                if(tempRecord.Contract_Line_Item__c==tempItems.Id){
                for(Contract_Line_Item_Schedule__c individualContractSchedule:contractLineITemSchedule)
                {
                
                if(tempRecord.Date__c==individualContractSchedule.Date__c && individualContractSchedule.Set_Billing_Date__c==true)
                {
                  contractLineItemList.add(individualContractSchedule);
                  price=price-(individualContractSchedule.Extended_Amount__c);
                }
                else if(individualContractSchedule.Contract_Line_Item__c==tempItems.Id)
                {
                  count++;
                  contractLineItemList.add(tempRecord);   
                }
                }
                }
            }               
            
            Double newPrice; 
            if(count!=0)
            {
              System.debug('Price and Count----'+Price+'-----'+count);
              newPrice= price/count;
                system.debug('New Price--'+newPrice);
            }
           
            for(Contract_Line_Item_Schedule__c tempRecord:contractLineItemList)
            {
                if(tempRecord.Set_Billing_Date__c==false)
                {
                   tempRecord.Amount__c=newPrice;
                    System.debug('tempRecord.Amount__c----'+tempRecord.Amount__c);
                   tempRecord.Quantity__c=1; 
                    System.debug('tempRecord.Quantity__c----'+tempRecord.Quantity__c);
                   finalContractLineItemList.add(tempRecord); 
                }
                else
                {
                 finalContractLineItemList.add(tempRecord);   
                }
            }              
            }
            }
            //Create New List with Old contract passed month and new contract with adjusted amount---End
          
            if(finalContractLineItemList.size()>0)
            {          
                 upsert finalContractLineItemList;          
           
            }
            
            else
            {     
                System.debug('Line 561-----'+contractLineItemScheduleList);
                upsert contractLineItemScheduleList;
            }            
            
            
        }      
        
        
    }
    
    
     /**
    * @description delete  Opportunit Line Item Schedule and Contract Line Item Schedule  after updating Opportunit Line Item
        */
        public static void deleteOpportunityLineItemAndContractLineItemsSchedule(Set<String> opportunityLineItemIds , Set<Id> contractLineItemIdsForDeleteContractLineItemSchedul){
          System.debug('Came in this part 7');   
        // deltete OpportunityLineItemSchedule
        List<OpportunityLineItemSchedule>  opportunityLineItemScheduleList = [SELECT Id FROM OpportunityLineItemSchedule 
        WHERE OpportunityLineItemId =: opportunityLineItemIds];
            System.debug('Inside OpportunityLineItemTriggerHandler Delete Mathod ----'+opportunityLineItemScheduleList);
        
        /*if(!opportunityLineItemScheduleList.isEmpty()){
          delete opportunityLineItemScheduleList;         

       }*/
        deleteContractLineItemsSchedule(contractLineItemIdsForDeleteContractLineItemSchedul);        
    }
  /**
    * @description delete   Contract Line Item Schedule  after update Opportunit Line Item
        */
    public static void deleteContractLineItemsSchedule(Set<Id> contractLineItemIds){
         System.debug('Came in this part 8');
        //delete Contract Line Item Schedule
        List<Contract_Line_Item_Schedule__c>  contractLineItemScheduleList = [SELECT Id, Contract_Line_Item__c,Contract_Line_Item__r.Contract__r.Opportunity__c, Billing_Date__c, Set_Billing_Date__c 
                                                                            FROM Contract_Line_Item_Schedule__c 
                                                                            WHERE Contract_Line_Item__c=: contractLineItemIds];
        if(!contractLineItemScheduleList.isEmpty()){
        for (Contract_Line_Item_Schedule__c contractLineItemSchedule : contractLineItemScheduleList) {
        	if(contractLineItemSchedule.Billing_Date__c > Date.Today() || contractLineItemSchedule.Billing_Date__c ==null){
               delete contractLineItemSchedule; 
            }
        }
        }
    } 
}