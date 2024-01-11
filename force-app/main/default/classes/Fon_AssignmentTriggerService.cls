public class Fon_AssignmentTriggerService{
    public static Boolean runOnce = false;
    public static void createSubscriptionAfterInsert(Map<Id, OrderApi__Assignment__c> newItems) {
		system.debug('***AssignmentTriggerHandler AfterInsert***');
        createSubscription(newItems,null);
    }
 
    public static void createSubscriptionAfterUpdate(Map<Id, OrderApi__Assignment__c> newItems, Map<Id, OrderApi__Assignment__c> oldItems) {
        system.debug('*** AssignmentTriggerHandler AfterUpdate ***');
        system.debug('newItems active : '+newItems.values());
        List<OrderApi__Assignment__c> assignment = [Select Id, OrderApi__Contact__c, OrderApi__Is_Active__c, OrderApi__Sales_Order_Line__c, OrderApi__Term__c,OrderApi__Subscription__r.OrderApi__Activated_Date__c,
                                                    OrderApi__Subscription__c,OrderApi__Term__r.OrderApi__Term_End_Date__c,OrderApi__Sales_Order_Line__r.OrderApi__Is_Renewal__c,OrderApi__Subscription__r.OrderApi__Status__c,
                                                    OrderApi__Sales_Order_Line__r.OrderApi__Item__r.Individual_Membership__c,OrderApi__Item__r.Individual_Membership__c,OrderApi__Term__r.OrderApi__Is_Active__c,
                                                    OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Account__c,OrderApi__Subscription__r.OrderApi__Account__c,
                                                    OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Sales_Order_Status__c,OrderApi__Term__r.OrderApi__Assignments_Allowed__c,
                                                    OrderApi__Item_Class__r.Legacy_Item_Class_ID__c, OrderApi__Item_Class__c,OrderApi__Subscription__r.OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c	
                                                    from OrderApi__Assignment__c
                                                    where Id IN :newItems.keyset()
                                                    AND OrderApi__Subscription__r.OrderApi__Status__c != 'Cancelled'
                                                    AND OrderApi__Is_Active__c = false];
        system.debug('assignment : '+assignment);
        List<OrderApi__Renewal__c> termList = new List<OrderApi__Renewal__c>();
        Map<Id, Id> contactTermMap = new Map<Id, Id>();
        Map<Id, date> contactCorporateTermMap = new Map<Id, date>();
        Map<Id, Id> contactIsRenewalMap = new Map<Id, Id>();
        List<OrderApi__Assignment__c> renewalAssignmentList = new List<OrderApi__Assignment__c>();
        if(assignment.size() > 0){
            for(OrderApi__Assignment__c assign : assignment){
                OrderApi__Assignment__c oldAssign = oldItems.get(assign.Id);
                System.debug('oldAssign : '+oldAssign);
                system.debug('assign.OrderApi__Is_Active__c : '+assign.OrderApi__Is_Active__c);
                system.debug('oldAssign.OrderApi__Is_Active__c : '+oldAssign.OrderApi__Is_Active__c);
                system.debug('assign.OrderApi__Contact__c : '+assign.OrderApi__Contact__c);
                system.debug('assign.OrderApi__Item__r.Individual_Membership__c : '+assign.OrderApi__Item__r.Individual_Membership__c);
                system.debug('assign.OrderApi__Term__c : '+assign.OrderApi__Term__c);
                system.debug('assign.OrderApi__Sales_Order_Line__c : '+assign.OrderApi__Sales_Order_Line__c);
                if(assign.OrderApi__Contact__c != null && assign.OrderApi__Item__r.Individual_Membership__c != null){
                    system.debug('*** inside for loop 1***');
                    if(assign.OrderApi__Is_Active__c == false){
                        if(!contactTermMap.ContainsKey(assign.OrderApi__Contact__c)){
                            contactTermMap.put(assign.OrderApi__Contact__c,assign.OrderApi__Item__r.Individual_Membership__c);
                        }
                        if(!contactCorporateTermMap.ContainsKey(assign.OrderApi__Contact__c)){
                            contactCorporateTermMap.put(assign.OrderApi__Contact__c,assign.OrderApi__Term__r.OrderApi__Term_End_Date__c);
                        }
                    }
                    if(assign.OrderApi__Sales_Order_Line__r.OrderApi__Is_Renewal__c){
                        if(!contactIsRenewalMap.ContainsKey(assign.OrderApi__Contact__c)){
                            contactIsRenewalMap.put(assign.OrderApi__Contact__c,assign.OrderApi__Subscription__c);
                            renewalAssignmentList.add(assign);
                        }
                    }
                   
                }
            }
            system.debug('contactTermMap : '+contactTermMap);
            system.debug('contactCorporateTermMap : '+contactCorporateTermMap);
            system.debug('contactIsRenewalMap : '+contactIsRenewalMap);
            
            List<OrderApi__Renewal__c> terms = [SELECT Id,OrderApi__Term_End_Date__c,OrderApi__Assignments_Allowed__c,OrderApi__Contact__c,
                                                OrderApi__Subscription__r.OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c,OrderApi__Subscription__c
                                                FROM OrderApi__Renewal__c
                                               WHERE OrderApi__Contact__c IN: contactTermMap.Keyset()
                                               AND OrderApi__Item__c IN: contactTermMap.values()];
            system.debug('terms size : '+terms.size());
            system.debug('terms : '+terms);    
            
            
            for(OrderApi__Renewal__c trm: terms){
                //system.debug('trm : '+trm);
                //integer gracePeriods = integer.valueOf(trm.OrderApi__Assignments_Allowed__c + 1) ;
                //system.debug('trm OrderApi__Subscription__r 1 : '+trm.OrderApi__Subscription__r);
                //system.debug('trm OrderApi__Subscription__r 2 : '+trm.OrderApi__Subscription__r.OrderApi__Subscription_Plan__r);
                //system.debug('trm OrderApi__Subscription__r 3 : '+trm.OrderApi__Subscription__r.OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c);
                if(contactCorporateTermMap.ContainsKey(trm.OrderApi__Contact__c) && !contactIsRenewalMap.ContainsKey(trm.OrderApi__Contact__c)){
                    Date termEndDate = contactCorporateTermMap.get(trm.OrderApi__Contact__c);
                    system.debug('termEndDate : '+termEndDate);
                    system.debug('trm.OrderApi__Term_End_Date__c : '+trm.OrderApi__Term_End_Date__c);
                    if(termEndDate == trm.OrderApi__Term_End_Date__c ){
                        if(trm.OrderApi__Subscription__r.OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c != null){
                            integer gracePeriods = integer.valueOf(trm.OrderApi__Subscription__r.OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c + 1) ;
                            trm.OrderApi__Term_End_Date__c = Date.today().addDays(-gracePeriods);
                        }
                        else{
                            trm.OrderApi__Term_End_Date__c = Date.today().addDays(-1);
                        }
                        termList.add(trm);
                    }
                }
                if(contactIsRenewalMap.ContainsKey(trm.OrderApi__Contact__c)){
                    contactIsRenewalMap.put(trm.OrderApi__Contact__c,trm.OrderApi__Subscription__c);
                }
                
            }
            system.debug('termList : '+termList);
            if(termList.size() > 0){
                Database.SaveResult[] myResult = Database.update(termList,false);
            }
            if(contactIsRenewalMap.size() > 0){
            	createRenewalSubscription(renewalAssignmentList,contactIsRenewalMap);    
            }
            
        }
        else{
            system.debug('***createSubscription***');
            createSubscription(newItems,oldItems);
        }
        
    }
    public static void createRenewalSubscription(List<OrderApi__Assignment__c> newItems,Map<Id,Id> contactIsRenewalMap){
        system.debug('***createRenewalSubscription***');
        Map<Id,OrderApi__Sales_Order__c> contactToSOMapStateful = new Map<Id,OrderApi__Sales_Order__c>();
        List<FDService.SalesOrderLine> lines = new List<FDService.SalesOrderLine>();
        FDService.OrderService orderService = FDService.OrderService.getInstance();
        Map<Id, OrderApi__Sales_Order__c> contactToSOMap = new Map<Id,OrderApi__Sales_Order__c>();
		Map<Id, Id> mapSOLToCon = new Map<Id, Id>();
        Set<Id> setSOId = new Set<Id>();
		List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Sales_Order__c> updateOrders = new List<OrderApi__Sales_Order__c>();
        List<String> emailTemplateName = new List<String>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<OrderApi__Assignment__c> assignment = newItems;
        system.debug('assignment : '+assignment);
        
        emailTemplateName.add('Chapter_Memberships');
        emailTemplateName.add('OA_Membership');
        Id corpEmailtemplateId;
        Id orgEmailtemplateId;
        List<EmailTemplate> emailTemplate = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName IN :emailTemplateName];
        for(EmailTemplate templates: emailTemplate){
            if(templates.DeveloperName == 'Chapter_Memberships'){
                corpEmailtemplateId =templates.Id; 
            }
            if(templates.DeveloperName == 'OA_Membership'){
                orgEmailtemplateId =templates.Id;
            }
        }
        //Id emailTemplateId = emailTemplate.Id;
        system.debug('orgEmailtemplateId : '+orgEmailtemplateId+'- corpEmailtemplateId : '+corpEmailtemplateId);
        
        if(assignment.size() > 0){
            for(OrderApi__Assignment__c assign : assignment){
                System.debug('assign.OrderApi__Sales_Order_Line__c : '+assign.OrderApi__Sales_Order_Line__c);
                if(assign.OrderApi__Contact__c != null && assign.OrderApi__Item__r.Individual_Membership__c != null){
                    OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
                    salesOrder.OrderApi__Contact__c = assign.OrderApi__Contact__c; 
                    salesOrder.OrderApi__account__c = assign.OrderApi__Subscription__r.OrderApi__Account__c;
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
                        email.setTemplateId(corpEmailtemplateId); 
                        email.setTargetObjectId(assign.OrderApi__Contact__c); 
                        email.setSaveAsActivity(false); 
                        emailMessages.add(email);
                    }
                    if(assign.OrderApi__Item_Class__c != null &&
                        assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c != null &&
                        assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c =='ORG'){
                            system.debug('assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c'+assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c);
                        // Create and populate the email message
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTemplateId(orgEmailtemplateId); 
                        email.setTargetObjectId(assign.OrderApi__Contact__c); 
                        email.setSaveAsActivity(false); 
                        emailMessages.add(email);
                    }
    			}
            }
            
            system.debug('contactToSOMap.values() : '+contactToSOMap.values());
            Database.SaveResult[] myResult = Database.insert(contactToSOMap.values(),false);
            
            
            system.debug('myResult : '+myResult);
            
            for (OrderApi__Sales_Order__c record : contactToSOMap.values()) {
                contactToSOMapStateful.put(record.OrderApi__Contact__c, record);
            }
    
            
            
            for(OrderApi__Assignment__c assign : assignment){
                if(contactToSOMapStateful.get(assign.OrderApi__Contact__c)!=null){
                    Id soid = contactToSOMapStateful.get(assign.OrderApi__Contact__c).Id;
                    if(assign.OrderApi__Item__r.Individual_Membership__c  != null){
                        OrderApi__Sales_Order__c soOrder = new OrderApi__Sales_Order__c();
                        soOrder.Id = soId;
                        soOrder.OrderApi__Status__c = 'Closed';
                        salesOrderList.add(soOrder);
                        setSOId.add(soid);
    
                        FDService.SalesOrderLine line = FDService.SalesOrderLine.getInstance();
                        line.salesOrder = soid;
                        line.item = assign.OrderApi__Item__r.Individual_Membership__c ;
                        line.isRenewal = true;
                        line.entity = 'Contact';
                        if(contactIsRenewalMap.containsKey(assign.OrderApi__Contact__c)){
                            line.subscription = contactIsRenewalMap.get(assign.OrderApi__Contact__c);
                        }
                        
                        system.debug('assign.OrderApi__Subscription__c : '+assign.OrderApi__Subscription__c);
                        if(assign.OrderApi__Subscription__c != null){
                            system.debug('Activated Date : '+assign.OrderApi__Subscription__r.OrderApi__Activated_Date__c);
                            //line.endDate = assign.OrderApi__Subscription__r.OrderApi__Paid_Through_Date__c;
                            line.activationDate = assign.OrderApi__Subscription__r.OrderApi__Activated_Date__c;
                            line.autoCalculateActivationDate = false;
                        }
                        lines.add(line);
                    }
                }	
            }
            system.debug('AssignmentTriggerHandler lines 1 : '+lines);
            if(!lines.isEmpty()) {
                lines = orderService.addItemsToOrder(lines);
                system.debug('AssignmentTriggerHandler lines 2 : '+lines);
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
    }
    public static void createSubscription(Map<Id, OrderApi__Assignment__c> newItems,Map<Id, OrderApi__Assignment__c> oldItems){
    	Map<Id,OrderApi__Sales_Order__c> contactToSOMapStateful = new Map<Id,OrderApi__Sales_Order__c>();
        List<FDService.SalesOrderLine> lines = new List<FDService.SalesOrderLine>();
        FDService.OrderService orderService = FDService.OrderService.getInstance();
        Map<Id, OrderApi__Sales_Order__c> contactToSOMap = new Map<Id,OrderApi__Sales_Order__c>();
		Map<Id, Id> mapSOLToCon = new Map<Id, Id>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<String> emailTemplateName = new List<String>();
        Set<Id> setSOId = new Set<Id>();
		List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Sales_Order__c> updateOrders = new List<OrderApi__Sales_Order__c>();
        boolean isRun = false;
        
        List<OrderApi__Assignment__c> assignment = [Select Id, OrderApi__Contact__c, OrderApi__Is_Active__c, OrderApi__Sales_Order_Line__c, OrderApi__Term__c,OrderApi__Term__r.OrderApi__Is_Active__c,
                                                    OrderApi__Sales_Order_Line__r.OrderApi__Item__r.Individual_Membership__c,OrderApi__Subscription__c,OrderApi__Item__r.Individual_Membership__c,
                                                    OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Account__c,OrderApi__Subscription__r.OrderApi__Account__c,
                                                    OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Sales_Order_Status__c,
                                                    OrderApi__Item_Class__r.Legacy_Item_Class_ID__c, OrderApi__Item_Class__c,OrderApi__Subscription__r.OrderApi__Activated_Date__c
                                                    from OrderApi__Assignment__c
                                                    where Id =:newItems.keyset() 
                                                    AND OrderApi__Is_Active__c= true
                                                    AND OrderApi__Term__r.OrderApi__Is_Active__c = true];
        system.debug('assignment : '+assignment);
        
        for(OrderApi__Assignment__c assgn: assignment){
            system.debug('New is Active : '+assgn.OrderApi__Is_Active__c);
            system.debug('oldItems : '+oldItems);
            if(oldItems == null){
                isRun = true;
            }
            else{
                OrderApi__Assignment__c oldAssign = oldItems.get(assgn.Id);
                system.debug('Old is Active : '+oldAssign.OrderApi__Is_Active__c);
                if(assgn.OrderApi__Is_Active__c == true && 
                   assgn.OrderApi__Subscription__c != oldAssign.OrderApi__Subscription__c &&
                  	assgn.OrderApi__Term__r.OrderApi__Is_Active__c) {
                    isRun = true;
                }
            }
            
        }
		
        system.debug('isRun : '+isRun);
        if(assignment.size() > 0 && isRun){
        //if(assignment.size() > 0){
            emailTemplateName.add('Chapter_Memberships');
            emailTemplateName.add('OA_Membership');
            Id corpEmailtemplateId;
            Id orgEmailtemplateId;
            List<EmailTemplate> emailTemplate = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName IN :emailTemplateName];
            for(EmailTemplate templates: emailTemplate){
                if(templates.DeveloperName == 'Chapter_Memberships'){
                    corpEmailtemplateId =templates.Id; 
                }
                if(templates.DeveloperName == 'OA_Membership'){
                    orgEmailtemplateId =templates.Id;
                }
            }
            //Id emailTemplateId = emailTemplate.Id;
            system.debug('orgEmailtemplateId : '+orgEmailtemplateId+'- corpEmailtemplateId : '+corpEmailtemplateId);
    
            for(OrderApi__Assignment__c assign : assignment){
                System.debug('assign.OrderApi__Sales_Order_Line__c : '+assign.OrderApi__Sales_Order_Line__c);
                if(assign.OrderApi__Contact__c != null && assign.OrderApi__Item__r.Individual_Membership__c != null){
                    OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
                    salesOrder.OrderApi__Contact__c = assign.OrderApi__Contact__c; 
                    salesOrder.OrderApi__account__c = assign.OrderApi__Subscription__r.OrderApi__Account__c;
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
                        email.setTemplateId(corpEmailtemplateId); 
                        email.setTargetObjectId(assign.OrderApi__Contact__c); 
                        email.setSaveAsActivity(false); 
                        emailMessages.add(email);
                    }
                    if(assign.OrderApi__Item_Class__c != null &&
                        assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c != null &&
                        assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c =='ORG'){
                            system.debug('assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c'+assign.OrderApi__Item_Class__r.Legacy_Item_Class_ID__c);
                        // Create and populate the email message
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTemplateId(orgEmailtemplateId); 
                        email.setTargetObjectId(assign.OrderApi__Contact__c); 
                        email.setSaveAsActivity(false); 
                        emailMessages.add(email);
                    }  
                }
            }
            
            system.debug('contactToSOMap.values() : '+contactToSOMap.values());
            Database.SaveResult[] myResult = Database.insert(contactToSOMap.values(),false);
            
            
            system.debug('myResult : '+myResult);
            
            for (OrderApi__Sales_Order__c record : contactToSOMap.values()) {
                contactToSOMapStateful.put(record.OrderApi__Contact__c, record);
            }
    
            
            
            for(OrderApi__Assignment__c assign : assignment){
                if(contactToSOMapStateful.get(assign.OrderApi__Contact__c)!=null){
                    Id soid = contactToSOMapStateful.get(assign.OrderApi__Contact__c).Id;
                    if(assign.OrderApi__Item__r.Individual_Membership__c  != null){
                        OrderApi__Sales_Order__c soOrder = new OrderApi__Sales_Order__c();
                        soOrder.Id = soId;
                        soOrder.OrderApi__Status__c = 'Closed';
                        salesOrderList.add(soOrder);
                        setSOId.add(soid);
    
                        FDService.SalesOrderLine line = FDService.SalesOrderLine.getInstance();
                        line.salesOrder = soid;
                        line.item = assign.OrderApi__Item__r.Individual_Membership__c ;
                        line.isRenewal = false;
                        line.entity = 'Contact';
                        system.debug('assign.OrderApi__Subscription__c : '+assign.OrderApi__Subscription__c);
                        if(assign.OrderApi__Subscription__c != null){
                            system.debug('Activated Date : '+assign.OrderApi__Subscription__r.OrderApi__Activated_Date__c);
                            //line.endDate = assign.OrderApi__Subscription__r.OrderApi__Paid_Through_Date__c;
                            line.activationDate = assign.OrderApi__Subscription__r.OrderApi__Activated_Date__c;
                            line.autoCalculateActivationDate = false;
                        }
                        lines.add(line);
                    }
                }	
            }
            system.debug('AssignmentTriggerHandler lines 1 : '+lines);
            if(!lines.isEmpty()) {
                lines = orderService.addItemsToOrder(lines);
                system.debug('AssignmentTriggerHandler lines 2 : '+lines);
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
    }

    @future
    public static void updateSO(Set<Id> soIds){
        
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