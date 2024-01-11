/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class TermTriggerHandler implements TriggerHandlerInterface{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public Boolean IsDisabled(){
        if(TriggerSettings__c.getInstance('OrderApi__Renewal__c') == null){
            return TriggerDisabled;
        }
        if (TriggerSettings__c.getInstance('OrderApi__Renewal__c').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
    
    // Set the Academic Subscription date on the Individual Subscriptions
    public void BeforeInsert(List<SObject> newItems) {
        system.debug('***TermTriggerHandler BeforeInsert***');
        Set<Id> accountIds = new Set<Id>();
        Map<Id,OrderApi__Item__c> itemsMap = new Map<Id,OrderApi__Item__c>([SELECT Id,Name
                                                                        FROM OrderApi__Item__c
                                                                        WHERE Name = 'Academic Organizational Affiliate' 
                                                                        OR Name = 'Individual Organizational Affiliate']);
        string academicItem = '';
        string individualItem = '';
        for(OrderApi__Item__c item: itemsMap.values()){
            if(item.name == 'Academic Organizational Affiliate'){
                academicItem = item.Id;
            }
            if(item.name == 'Individual Organizational Affiliate'){
                individualItem = item.Id;
            }
        }
        system.debug('academicItem : '+academicItem);
        system.debug('individualItem : '+individualItem);
        
        for(OrderApi__Renewal__c terms: (List<OrderApi__Renewal__c>)newItems){
            String itemName = '';
            if(itemsMap.ContainsKey(terms.OrderApi__Item__c)){
                if(itemsMap.get(terms.OrderApi__Item__c).Name == 'Individual Organizational Affiliate'){
                    accountIds.add(terms.OrderApi__Account__c);
                }
            }
        }
        system.debug('accountIds : '+accountIds);
        Map<Id, OrderApi__Renewal__c> accountIdTermMap = new Map<Id, OrderApi__Renewal__c>();
        List<OrderApi__Renewal__c> acedemicTerms = [SELECT Id,  OrderApi__Subscription__c,OrderApi__Item__c, OrderApi__Item__r.Individual_Membership__c, OrderApi__Term_Start_Date__c,OrderApi__Account__c,
                                    OrderApi__Sales_Order_Line__r.OrderApi__Is_Renewal__c,OrderApi__Subscription__r.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c,OrderApi__Term_End_Date__c,Is_Renewal_SOL__c 
                                FROM OrderApi__Renewal__c 
                                WHERE OrderApi__Account__c IN: accountIds 
                                AND OrderApi__Item__c =: academicItem
                                AND OrderApi__Sales_Order_Line__r.OrderApi__Is_Renewal__c = false
                                AND OrderApi__Is_Active__c = true
                                AND OrderApi__Subscription__r.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c = 'ORG'
                                ORDER By createdDate DESC];
        system.debug('acedemicTerms : '+acedemicTerms);
        
        for(OrderApi__Renewal__c term: acedemicTerms){
            accountIdTermMap.put(term.OrderApi__Account__c, term);
        }
        system.debug('accountIdTermMap : '+accountIdTermMap);
        
        if(accountIdTermMap.size() > 0){
            for(OrderApi__Renewal__c terms: (List<OrderApi__Renewal__c>)newItems){
                if(itemsMap.ContainsKey(terms.OrderApi__Item__c)){
                    if(itemsMap.get(terms.OrderApi__Item__c).Name == 'Individual Organizational Affiliate' && terms.Is_Renewal_SOL__c == false){
                        OrderApi__Renewal__c academicTerm = accountIdTermMap.get(terms.OrderApi__Account__c);
                        terms.OrderApi__Term_Start_Date__c = academicTerm.OrderApi__Term_Start_Date__c;
                        terms.OrderApi__Term_End_Date__c = academicTerm.OrderApi__Term_End_Date__c;
                        system.debug('update terms : '+terms);
                    }
                }
            }
        }
        
    }
     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        system.debug('***TermTriggerHandler AfterInsert***');
        Set<Id> subId = new Set<Id>();
        Set<Id> solId = new Set<Id>();
        Map<Id,OrderApi__Sales_Order__c> contactToSOMapStateful = new Map<Id,OrderApi__Sales_Order__c>();
        List<FDService.SalesOrderLine> lines = new List<FDService.SalesOrderLine>();
        FDService.OrderService orderService = FDService.OrderService.getInstance();
        Map<Id, OrderApi__Sales_Order__c> contactToSOMap = new Map<Id,OrderApi__Sales_Order__c>();

        for(OrderApi__Renewal__c term : [Select Id, OrderApi__Item__c,  OrderApi__Subscription__c, OrderApi__Item__r.Individual_Membership__c, OrderApi__Sales_Order_Line__c from OrderApi__Renewal__c 
                                            where Id=:newItems.keyset() and OrderApi__Item__r.Individual_Membership__c != null]) {
            if(term.OrderApi__Item__r.Individual_Membership__c != null && term.OrderApi__Sales_Order_Line__c != null){
               // subId.add(term.OrderApi__Subscription__c);
                solId.add(term.OrderApi__Sales_Order_Line__c);
            }
        }
        system.debug('>>> 1= '+solId);
        // Get Assigments

        List<OrderApi__Assignment__c> assignment = [Select Id, OrderApi__Contact__c, OrderApi__Is_Active__c, OrderApi__Sales_Order_Line__c, OrderApi__Term__c,
                                                    OrderApi__Sales_Order_Line__r.OrderApi__Item__r.Individual_Membership__c,
                                                    OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Account__c,
                                                    OrderApi__Item_Class__r.Legacy_Item_Class_ID__c, OrderApi__Item_Class__c
                                                    from OrderApi__Assignment__c
                                                    where OrderApi__Sales_Order_Line__c =:solId and OrderApi__Is_Active__c=:true];
        system.debug('>>> 2= '+assignment);
        Map<Id, Id> mapSOLToCon = new Map<Id, Id>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        String emailTemplateName = 'Chapter_Memberships';
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];
        Id emailTemplateId = emailTemplate.Id;

        for(OrderApi__Assignment__c assign : assignment){
            if(assign.OrderApi__Contact__c != null && assign.OrderApi__Sales_Order_Line__c != null){
                OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
                salesOrder.OrderApi__Contact__c = assign.OrderApi__Contact__c; 
                salesOrder.OrderApi__account__c = assign.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Account__c;
                salesOrder.OrderApi__posting_Entity__c = 'Receipt';
                salesOrder.OrderApi__is_Closed__c = false;
                salesOrder.OrderApi__is_Proforma__c = true;
                salesOrder.OrderApi__schedule_Type__c = 'Simple Receipt';
                contactToSOMap.put(assign.OrderApi__Contact__c, salesOrder);

                if(assign.OrderApi__Item_Class__c != null &&
                    assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c != null &&
                    assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c =='CORP'){
                        system.debug('assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c'+assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c);
                    // Create and populate the email message
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(emailTemplateId); 
                    email.setTargetObjectId(assign.OrderApi__Contact__c); 
                    email.setSaveAsActivity(false); 
                    emailMessages.add(email);
                }
            }
        }
        system.debug('>>> 3= '+contactToSOMap);
        system.debug('>>> 4= '+emailMessages);

        Database.SaveResult[] myResult = Database.insert(contactToSOMap.values(),false);
        List<OrderApi__Sales_Order__c> updateOrders = new List<OrderApi__Sales_Order__c>();
        
        for (OrderApi__Sales_Order__c record : contactToSOMap.values()) {
            contactToSOMapStateful.put(record.OrderApi__Contact__c, record);
        }

        Set<Id> setSOId = new Set<Id>();
        List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
        for(OrderApi__Assignment__c assign : assignment){
            if(contactToSOMapStateful.get(assign.OrderApi__Contact__c)!=null){
                Id soid = contactToSOMapStateful.get(assign.OrderApi__Contact__c).Id;
                
                OrderApi__Sales_Order__c soOrder = new OrderApi__Sales_Order__c();
                soOrder.Id = soId;
                soOrder.OrderApi__Status__c = 'Closed';
                salesOrderList.add(soOrder);
                setSOId.add(soid);
                if(assign.OrderApi__Sales_Order_Line__r.OrderApi__Item__r.Individual_Membership__c  != null){
                    FDService.SalesOrderLine line = FDService.SalesOrderLine.getInstance();
                    line.salesOrder = soid;
                    line.item = assign.OrderApi__Sales_Order_Line__r.OrderApi__Item__r.Individual_Membership__c ;
                    line.isRenewal = false;
                    line.entity = 'Contact';
                    lines.add(line);
                }
            }   
        }
       
        if(!lines.isEmpty()) {
            lines = orderService.addItemsToOrder(lines);
        }

        if(setSOId.size() > 0){
            update salesOrderList;
            updateSO(setSOId);
        }
        
        // Send the email messages
        if (!emailMessages.isEmpty()) {
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);
        }
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Id> contactIdChapterMap = new Map<Id, Id>();
        Map<Id, OrderApi__Renewal__c> contactIdTermMap = new Map<Id, OrderApi__Renewal__c>();
        
        List<OrderApi__Renewal__c> IndividualTerms = [SELECT Id,  OrderApi__Subscription__c,OrderApi__Item__c, OrderApi__Item__r.Free_Chapter_member_included__c, 
                                                            OrderApi__Term_Start_Date__c,OrderApi__Contact__c,OrderApi__Sales_Order_Line__r.OrderApi__Is_Renewal__c,
                                                            OrderApi__Grace_Period_End_Date__c,OrderApi__Term_End_Date__c,OrderApi__Is_Active__c ,OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c,
                                                            (SELECT Id,OrderApi__Item__c,OrderApi__Term__c,OrderApi__Subscription__c,
                                                                OrderApi__Subscription__r.OrderApi__Contact__c,OrderApi__Item__r.Name
                                                             FROM OrderApi__Subscription_Lines__r
                                                             WHERE OrderApi__Item_Class__r.Name = 'Chapter Memberships')
                                                        FROM OrderApi__Renewal__c 
                                                        WHERE Id IN :newItems.keyset()
                                                        AND OrderApi__Is_Active__c = false
                                                        AND OrderApi__Item__r.Free_Chapter_member_included__c = true];
        system.debug('IndividualTerms : '+IndividualTerms);
        
        if(IndividualTerms.size() > 0){
            for(OrderApi__Renewal__c term: IndividualTerms){
                OrderApi__Renewal__c oldTerm = (OrderApi__Renewal__c)oldItems.get(term.Id);
                system.debug('oldTerm Is Active : '+oldTerm.OrderApi__Is_Active__c);
                
                if(term.OrderApi__Is_Active__c == false && term.OrderApi__Is_Active__c != oldTerm.OrderApi__Is_Active__c){
                    List<OrderApi__Subscription_Line__c> lstSubsLines = term.OrderApi__Subscription_Lines__r;
                    system.debug('lstSubsLines : '+lstSubsLines);
                    if(lstSubsLines.size() > 0){
                        for(OrderApi__Subscription_Line__c subsLine: lstSubsLines){
                            contactIdChapterMap.put(term.OrderApi__Contact__c, subsLine.OrderApi__Item__c);  
                            contactIdTermMap.put(term.OrderApi__Contact__c, term);
                        }
                    }
                }
            }    
        }
        system.debug('contactIdChapterMap : '+contactIdChapterMap);
        system.debug('contactIdTermMap : '+contactIdTermMap);
        
        List<OrderApi__Badge__c> chapterBadge = [SELECT Id,OrderApi__Contact__c,OrderApi__Is_Active__c,OrderApi__Badge_Type__r.Name,Name__c,
                                                 OrderApi__Sales_Order_Line__c,OrderApi__Badge_Type__c,OrderApi__Item__c,OrderApi__Expired_Date__c 
                                                 FROM OrderApi__Badge__c
                                                 WHERE OrderApi__Item__c IN: contactIdChapterMap.values()
                                                 AND OrderApi__Contact__c IN: contactIdChapterMap.keySet()
                                                 AND OrderApi__Is_Active__c = true];
        system.debug('chapterBadge : '+chapterBadge);
        List<OrderApi__Badge__c> updateBadge = new List<OrderApi__Badge__c>();
        if(chapterBadge.size() > 0){
            for(OrderApi__Badge__c badge: chapterBadge){
                if(badge.Name__c.contains('Chapter Member') && contactIdTermMap.containsKey(badge.OrderApi__Contact__c) && badge.OrderApi__Is_Active__c){
                    decimal graceDays = contactIdTermMap.get(badge.OrderApi__Contact__c).OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c;
                    system.debug('graceDays : '+graceDays);
                    if(badge.OrderApi__Sales_Order_Line__c == null){
                        badge.OrderApi__Expired_Date__c = contactIdTermMap.get(badge.OrderApi__Contact__c).OrderApi__Grace_Period_End_Date__c;    
                    }
                    //badge.OrderApi__Expired_Date__c = contactIdTermMap.get(badge.OrderApi__Contact__c).OrderApi__Term_End_Date__c.addDays(integer.valueOf(graceDays));
                    system.debug('badge.OrderApi__Expired_Date__c : '+badge.OrderApi__Expired_Date__c);
                    //badge.OrderApi__Expired_Date__c = contactIdTermMap.get(badge.OrderApi__Contact__c).OrderApi__Term_End_Date__c;
                    updateBadge.add(badge);
                }
            }
            system.debug('updateBadge : '+updateBadge);
            if(updateBadge.size() > 0){
                update updateBadge;
            }
        }
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    

    @future
    public static void updateSO(Set<Id> soIds){
        system.debug('>>> 5= '+soIds);
        List<OrderApi__Sales_Order__c> salesOrder = new List<OrderApi__Sales_Order__c>();

        for(Id soId: soIds){
            OrderApi__Sales_Order__c soOrder = new OrderApi__Sales_Order__c();
            soOrder.Id = soId;
            soOrder.OrderApi__Is_Posted__C = true;
            salesOrder.add(soOrder);
        }

        update salesOrder;
    }
}