/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-12-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TranscriptCEHoursController {
    @AuraEnabled( cacheable=true )
    public static User getUserInfo() {
        system.debug('***TranscriptCEHoursController getUserInfo***');
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() limit 1];
    }

    @AuraEnabled( cacheable = true )  
    public static  List<CEHoursWrapper> fetchCEHoursActive(boolean isActive ) {  
        return getData(isActive);
    } 
    @AuraEnabled( cacheable = true )  
    public static  List<CEHoursWrapper> fetchCEHoursInActive(boolean isActive ) {  
        return getData(isActive);
    }
    public static List<CEHoursWrapper> getData(boolean isActive){
        List<CEHoursWrapper> wrapperList = new  List<CEHoursWrapper>();
        
        List<User> user = [Select id, contactId FROM USER Where id=:UserInfo.getUserId()];
        
        Map<Id,OrderApi__Subscription__c> subscriptions;
        
        if(isActive){
            subscriptions = new Map<Id,OrderApi__Subscription__c>([Select Id, FON_Certification_Item__c, Name, FON_Override_Submit_Logic__c, Is_Submit__c, Is_CE_Hours__c,Active_Term_Approved_HIMSS_CE_Hours__c, OrderApi__Activated_Date__c, OrderApi__Paid_Through_Date__c,Recert_Eligible_Date__c,
                                                                 Active_Term_Non_Approved_CE_Hours__c, Active_Term_CE_Hours__c, OrderApi__Item__r.Name, Is_Renewal__c,OrderApi__Term_Start_Date__c, OrderApi__Term_End_Date__c, OrderApi__Grace_Period_End_Date__c,
                                        (Select Id,Name, OrderApi__Subscription__c 
                                        FROM OrderApi__Renewals__r Where OrderApi__Is_Active__c=true
                                        order by createdDate DESC LIMIT 1) 
                                        from OrderApi__Subscription__c
                                        WHERE OrderApi__Contact__c=:user[0].contactId
                                        AND OrderApi__Status__c='Active' 
                                        AND Is_Certificate__c=TRUE]); 
        }
        else{
            subscriptions =  new Map<Id,OrderApi__Subscription__c>([Select Id, Name, FON_Certification_Item__c, FON_Override_Submit_Logic__c, Is_Submit__c, Is_CE_Hours__c,Active_Term_Approved_HIMSS_CE_Hours__c, OrderApi__Activated_Date__c, OrderApi__Paid_Through_Date__c,
                                                                   Active_Term_Non_Approved_CE_Hours__c, Active_Term_CE_Hours__c, OrderApi__Item__r.Name, Is_Renewal__c, OrderApi__Term_Start_Date__c, OrderApi__Term_End_Date__c, OrderApi__Grace_Period_End_Date__c,
                                        (Select Id,Name, OrderApi__Subscription__c 
                                        FROM OrderApi__Renewals__r order by createdDate DESC
                                        LIMIT 1)  
                                        from OrderApi__Subscription__c
                                        WHERE OrderApi__Contact__c=:user[0].contactId
                                        AND OrderApi__Status__c!='Active' 
                                        AND Is_Certificate__c=TRUE ]); 
        }

        if(!subscriptions.isEmpty()){
            Set<Id> setTermIds = new Set<Id>();
            for(OrderApi__Subscription__c sub : subscriptions.values()){
                if(!sub.OrderApi__Renewals__r.isEmpty()){
                    setTermIds.add(sub.OrderApi__Renewals__r[0].Id);
                }
               
            }
            
            List<CE_Hours__c> ceHours = [SELECT Id, Name, Credit_Date__c, Education_Provider__c,
                                                Activity_Type__c,Number_Of_Credits__c,Program_Title__c,Term__c,
                                                Term__r.OrderApi__Subscription__c,Term__r.Name 
                                                FROM CE_Hours__c 
                                                WHERE Term__c =:setTermIds];
            
            Map<Id,List<CE_Hours__c>> subMap = new Map<Id,List<CE_Hours__c>>();
            for(CE_Hours__c hour : ceHours){
                List<CE_Hours__c> hrs = subMap.get(hour.Term__r.OrderApi__Subscription__c);
                if(hrs==null){
                    hrs = new List<CE_Hours__c>();
                }
                hrs.add(hour);
                subMap.put(hour.Term__r.OrderApi__Subscription__c,hrs);
            }
            
            for(OrderApi__Subscription__c sub : subscriptions.values()){
                CEHoursWrapper wrapp = new  CEHoursWrapper();
                wrapp.subscription = sub;
                if(!sub.OrderApi__Renewals__r.isEmpty()){
                    wrapp.termId = sub.OrderApi__Renewals__r[0].Id;
                }
                for(CE_Hours__c hour : ceHours) {
                    if(subMap.get(sub.Id)!=null && !subMap.get(sub.Id).isEmpty()){
                        wrapp.ceHours = subMap.get(sub.Id);
                    }
                }
                wrapperList.add(wrapp);
            }
        }
        return wrapperList;
       /* Map<Id,OrderApi__Renewal__c> terms = new Map<Id,OrderApi__Renewal__c>([Select id, OrderApi__Subscription__c, 
        OrderApi__Subscription__r.Is_Certificate__c
        FROM OrderApi__Renewal__c 
        WHERE OrderApi__Subscription__r.OrderApi__Contact__c=:con[0].Id
        AND OrderApi__Subscription__r.Is_Certificate__c=TRUE]);

        return [ 
            SELECT Id, Name, Credit_Date__c, Activity_Type__c,Number_Of_Credits__c,Program_Title__c,Term__c 
            FROM CE_Hours__c 
            WHERE Term__c =: terms.keySet()
        ];  */
    }
    @AuraEnabled
    public static string deleteSelectedRecord(string selectedId){
        try{
            delete [Select id from CE_Hours__c where id=:selectedId];
            return null;
        }
        catch(exception ex){
            return ex.getMessage();
        }
    }
    public class CEHoursWrapper{
        @AuraEnabled
        public OrderApi__Subscription__c subscription;
        @AuraEnabled
        public Id termId;
        @AuraEnabled
        public  List< CE_Hours__c > ceHours;
        public CEHoursWrapper(){
            subscription =  new OrderApi__Subscription__c();
            ceHours = new  List<CE_Hours__c >();
        }
    } 

    @AuraEnabled(cacheable=true)
    public static OrderApi__Renewal__c getTerm(Id termId) {
        system.debug('getTerm/OrderApi__Renewal__c object');
        return [SELECT Id, OrderApi__Term_Start_Date__c, OrderApi__Grace_Period_End_Date__c, OrderApi__Term_End_Date__c FROM OrderApi__Renewal__c WHERE Id = :termId LIMIT 1];
    }


    @AuraEnabled
    public static string processSubscription(String subId) {
        String encryptId = '';
        Map<Id,OrderApi__Sales_Order__c> contactToSOMapStateful = new Map<Id,OrderApi__Sales_Order__c>();
        List<FDService.SalesOrderLine> lines = new List<FDService.SalesOrderLine>();
        FDService.OrderService orderService = FDService.OrderService.getInstance();
        Map<Id, OrderApi__Sales_Order__c> contactToSOMap = new Map<Id,OrderApi__Sales_Order__c>();
        
        String termId = '';
        List<OrderApi__Subscription__c> listSub = [SELECT Id,
                                                        OrderApi__Contact__c,
                                                        OrderApi__Grace_Period_End_Date__c,
                                                        OrderApi__Item__c,
                                                        OrderApi__Item__r.Recertification_Fee__c,
                                                        Recertification_Fee_Item__c,
                                                        OrderApi__Subscription_Plan__c,
                                                        OrderApi__Account__c,Recert_Eligible_Date__c,(Select Id, 
                                                        Renewal_SalesOrder__c, 
                                                        Renewal_SalesOrder__r.OrderApi__Encrypted_Id__c 
                                                        from OrderApi__Renewals__r ORDER BY CreatedDate DESC limit 1)
                                                        FROM OrderApi__Subscription__c
                                                        WHERE Id=:subId];
        system.debug('>>. > > '+ listSub[0].OrderApi__Item__r.Recertification_Fee__c);
        for (OrderApi__Subscription__c sub : listSub) {
            OrderApi__Sales_Order__c salesOrder = createSalesOrder(sub.OrderApi__Account__c, sub);
            contactToSOMap.put(sub.OrderApi__Contact__c, salesOrder);
            if(sub.OrderApi__Renewals__r.size() > 0){
                termId = sub.OrderApi__Renewals__r[0].Id;
                if(sub.OrderApi__Renewals__r[0].Renewal_SalesOrder__c != null){
                    encryptId = sub.OrderApi__Renewals__r[0].Renewal_SalesOrder__r.OrderApi__Encrypted_Id__c;
                    return encryptId;
                }
            }
        }
        
        Database.SaveResult[] myResult = Database.insert(contactToSOMap.values(),false);
        List<OrderApi__Sales_Order__c> updateOrders = new List<OrderApi__Sales_Order__c>();
        
        for (OrderApi__Sales_Order__c record : contactToSOMap.values()) {
            contactToSOMapStateful.put(record.OrderApi__Contact__c, record);
        }
        for (OrderApi__Subscription__c sub : listSub) {
            if(contactToSOMapStateful.get(sub.OrderApi__Contact__c)!=null){
                Id soid = contactToSOMapStateful.get(sub.OrderApi__Contact__c).Id;
                updateOrders.add(new OrderApi__Sales_Order__c(Id = soid,OrderApi__is_Closed__c = true,OrderApi__Status__c = 'Closed'));
                lines.add(createOrderLines(sub.OrderApi__Account__c , soid, sub));
                if(sub.Recertification_Fee_Item__c != null){
                    FDService.SalesOrderLine line = FDService.SalesOrderLine.getInstance();
                    line.salesOrder = soid;
                    line.item = sub.Recertification_Fee_Item__c;
                    line.isRenewal = false;
                    line.entity = 'Contact';
                    lines.add(line);
                }
            }   
        }
        if(!lines.isEmpty()) {
            lines = orderService.addItemsToOrder(lines);
        }
        if(updateOrders.size()>0){
            update updateOrders;
            
            OrderApi__Renewal__c term = new OrderApi__Renewal__c();
            term.Id = termId;
            term.Renewal_SalesOrder__c = updateOrders[0].Id;
            term.Is_Attested__c = true;
            
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Renewal__c', true);
            update term;
            Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Renewal__c', false);
            
            return [Select Id, OrderApi__Encrypted_Id__c  from OrderApi__Sales_Order__c where Id=:updateOrders[0].Id].OrderApi__Encrypted_Id__c;
            
        }
        return null;
    }

    public static OrderApi__Sales_Order__c createSalesOrder(Id parentAccId, OrderApi__Subscription__c sub){
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Contact__c = sub.OrderApi__Contact__c; 
        salesOrder.OrderApi__account__c = sub.OrderApi__Account__c;
        salesOrder.OrderApi__posting_Entity__c = 'Receipt';
        salesOrder.OrderApi__is_Closed__c = false;
        salesOrder.OrderApi__is_Proforma__c = true;
        salesOrder.OrderApi__schedule_Type__c = 'Simple Receipt';
        salesOrder.OrderApi__Entity__c = 'Contact';
        return salesOrder;
    }
    
    public static FDService.SalesOrderLine createOrderLines(Id parentAccId, Id soid, OrderApi__Subscription__c sub){
        FDService.SalesOrderLine line = FDService.SalesOrderLine.getInstance();
        line.salesOrder = soid;
        line.item = sub.OrderApi__Item__c;
        line.subscriptionPlan = sub.OrderApi__Subscription_Plan__c;
        line.subscription = sub.id;
        line.isRenewal = true;
        line.entity = 'Contact';
        return line;
    }

    @AuraEnabled
    public static string createCertificate(String subId) {
        
        List<OrderApi__Subscription__c> lstSub = [Select Id, Certificate__c from OrderApi__Subscription__c where Id=:subId];
        
        if(lstSub.size() > 0 && lstSub[0].Certificate__c != null){
            SDOC__SDJob__c job = new SDOC__SDJob__c();
            job.SDOC__Start__c = true;
            job.SDOC__Oid__c = subId;
            job.SDOC__ObjApiName__c = 'OrderApi__Subscription__c';
            job.SDOC__Doclist__c = lstSub[0].Certificate__c;
            insert job;
    
            return job.Id;
        }
        return null;
        
    }

    @AuraEnabled
    public static string viewCertificate(String subId) {
        List<Attachment> lstAttach = [Select Id, ParentId, CreatedById from Attachment where ParentId =:subId and CreatedById =:UserInfo.getUserId() ORDER BY CreatedDate DESC limit 1 ];

        if(lstAttach.size() > 0){
            return lstAttach[0].Id;
        }

        return null;
    }
    
    @AuraEnabled
    public static CEHoursEditWrapper editCEHours(String subId) {
        List<CE_Hours__c> ceHours = [SELECT Id, Name, Credit_Date__c, Education_Provider__c,
                                                Activity_Type__c,Number_Of_Credits__c,Program_Title__c,Term__c
                                                FROM CE_Hours__c 
                                                WHERE Id =: subId];
        
        if(ceHours.size() > 0) {
            CEHoursEditWrapper ceWrap = new CEHoursEditWrapper();
            ceWrap.creditDate = ceHours[0].Credit_Date__c;
            ceWrap.creditNumber = ceHours[0].Number_Of_Credits__c;
            ceWrap.programTitle = ceHours[0].Program_Title__c;
            ceWrap.activityType = ceHours[0].Activity_Type__c;
            
            ceWrap.educationProvider = ceHours[0].Education_Provider__c;
            return ceWrap;
        }
        return null;
    }
    
    public class CEHoursEditWrapper{
        @AuraEnabled
        public date creditDate;
        @AuraEnabled
        public decimal creditNumber;
        @AuraEnabled
        public string programTitle;
        @AuraEnabled
        public string activityType;
        @AuraEnabled
        public string educationProvider;
        
    }
  
}