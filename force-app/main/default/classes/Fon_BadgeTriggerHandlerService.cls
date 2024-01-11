public class Fon_BadgeTriggerHandlerService{
    public static Boolean runOnce = false;

    public static void BeforeInsert(List<OrderApi__Badge__c> newItems) {
        system.debug('***BadgeTriggerHandler BeforeInsert***');
        Map<Id, Id> contactIdChapterMap = new Map<Id, Id>();
        Set<Id> solIds = new Set<Id>();
        Map<Id, OrderApi__Renewal__c> contactIdTermMap = new Map<Id, OrderApi__Renewal__c>();
        Set<Id> subscriptionIds = new Set<Id>();
        for(OrderApi__Badge__c badge: (List<OrderApi__Badge__c>)newItems){
            system.debug('badge : '+badge);
            system.debug('SOL : '+badge.OrderApi__Sales_Order_Line__c);
            if(badge.Name__c.contains('Chapter Member') && badge.OrderApi__Is_Active__c){
                contactIdChapterMap.put(badge.OrderApi__Contact__c, badge.OrderApi__Item__c);
                solIds.add(badge.OrderApi__Sales_Order_Line__c);
            }
        }
        
        // This methos is used to set null value on the Sales Order Line and 
    	// Update the Expired date to be term grace period date
        system.debug('contactIdChapterMap : '+contactIdChapterMap);
        if(contactIdChapterMap.size() > 0){
        	
            List<OrderApi__Subscription_Line__c> lstSubsLines = [SELECT Id,OrderApi__Item__c,OrderApi__Term__c,OrderApi__Subscription__c,
                                                                 	OrderApi__Subscription__r.OrderApi__Contact__c,OrderApi__Item__r.Name,OrderApi__Sales_Order_Line__c
                                                                 FROM OrderApi__Subscription_Line__c
                                                                 WHERE OrderApi__Subscription__r.OrderApi__Contact__c IN : contactIdChapterMap.KeySet()  
                                                                 AND OrderApi__Subscription__r.OrderApi__Status__c = 'Active'
                                                                 AND (OrderApi__Item__c =: contactIdChapterMap.values() 
                                                                      OR OrderApi__Sales_Order_Line__c IN: solIds)
                                                                 AND OrderApi__Item_Class__r.Name = 'Chapter Memberships'];
            for(OrderApi__Subscription_Line__c subsLine: lstSubsLines){
                subscriptionIds.add(subsLine.OrderApi__Subscription__c);
            }
            system.debug('subscriptionIds : '+subscriptionIds);
            List<OrderApi__Renewal__c> IndividualTerms = [SELECT Id,  OrderApi__Subscription__c,OrderApi__Item__c, OrderApi__Item__r.Free_Chapter_member_included__c, 
                                                        	OrderApi__Term_Start_Date__c,OrderApi__Contact__c,OrderApi__Sales_Order_Line__r.OrderApi__Is_Renewal__c,
                                                        	OrderApi__Grace_Period_End_Date__c,OrderApi__Term_End_Date__c, OrderApi__Subscription_Plan__r.OrderApi__Grace_Period__c 
                                                        FROM OrderApi__Renewal__c 
                                                        WHERE OrderApi__Subscription__c IN: subscriptionIds
                                                        AND OrderApi__Is_Active__c = true
                                                        AND OrderApi__Sales_Order_Line__r.OrderApi__Is_Renewal__c = false
                                                        AND OrderApi__Item__r.Free_Chapter_member_included__c = true
                                                        ORDER By createdDate DESC];
            
            system.debug('IndividualTerms : '+IndividualTerms);
            
            for(OrderApi__Renewal__c terms: IndividualTerms){
                contactIdTermMap.put(terms.OrderApi__Contact__c, terms);
            }
            system.debug('contactIdTermMap : '+contactIdTermMap);
            
            if(contactIdTermMap.size() > 0){
               for(OrderApi__Badge__c badge: (List<OrderApi__Badge__c>)newItems){
                    if(badge.Name__c.contains('Chapter Member') && contactIdTermMap.containsKey(badge.OrderApi__Contact__c) && badge.OrderApi__Is_Active__c){
                        badge.OrderApi__Sales_Order_Line__c = null;
                        badge.OrderApi__Expired_Date__c = contactIdTermMap.get(badge.OrderApi__Contact__c).OrderApi__Grace_Period_End_Date__c;
                    }
                } 
            }
            
        }
        
    }
     
    public static void BeforeDelete(Map<Id, OrderApi__Badge__c> oldItems) {
        
        Set<String> setCGroup = new Set<String>();
        List<Contact> lstCon = new List<Contact>();
        Set<String> setContactId = new Set<String>();

        for(sObject obj : oldItems.values()){
            OrderApi__Badge__c badge = (OrderApi__Badge__c)obj;
            setCGroup.add(badge.Name__c);
            setContactId.add(badge.OrderApi__Contact__c);
        }

            if(setCGroup.size() > 0){
            List<PagesApi__Community_Group_Member__c> lstCGM = [Select Id, PagesApi__Community_Group__c, PagesApi__Community_Group__r.Badge_Name__c from PagesApi__Community_Group_Member__c where PagesApi__Contact__c=:setContactId];
            List<PagesApi__Community_Group_Member__c> lstDelete = new List<PagesApi__Community_Group_Member__c>();
            for(PagesApi__Community_Group_Member__c cgm : lstCGM){
                if(setCGroup.Contains(cgm.PagesApi__Community_Group__r.Badge_Name__c)){
                    lstDelete.add(cgm);
                }
            }

            if(lstDelete.size() > 0){
                delete lstDelete;
            }
        }
    }
 
    public static void AfterInsert(Map<Id, OrderApi__Badge__c> newItems) {

        Set<String> setName = new Set<String>();
        List<PagesApi__Community_Group__c > groupToCreate = new List<PagesApi__Community_Group__c>();

        for(sObject obj : newItems.values()){
            OrderApi__Badge__c badge = (OrderApi__Badge__c)obj;
            if(badge.OrderApi__Is_Active__c){
                setName.add(badge.Name__c);
            }
        }
        Map<String, Id> communityToGroupMap = new Map<String, Id>();
        List<PagesApi__Community_Group_Member__c> lstCommunituGroupMember = new List<PagesApi__Community_Group_Member__c>();

        for (PagesApi__Community_Group__c cGroup : [SELECT Id, Name, Badge_Name__c, Community_Group__c FROM PagesApi__Community_Group__c where Badge_Name__c=:setName]) {
            communityToGroupMap.put(cGroup.Badge_Name__c, cGroup.Id);
        }

        if(communityToGroupMap.keyset().size() > 0){
            for(sObject obj : newItems.values()){
                OrderApi__Badge__c badge = (OrderApi__Badge__c)obj;
                if(communityToGroupMap.containskey(badge.Name__C)){
                    PagesApi__Community_Group_Member__c groupMember = new PagesApi__Community_Group_Member__c();
                    groupMember.PagesApi__Community_Group__c = communityToGroupMap.get(badge.Name__C);
                    groupMember.PagesApi__Contact__c = badge.OrderApi__Contact__c;
                    lstCommunituGroupMember.add(groupMember);
                }
            }

            if(lstCommunituGroupMember.size() > 0){
                insert lstCommunituGroupMember;
            }
        }

    }
 
    public static void AfterUpdate(Map<Id, OrderApi__Badge__c> newItems, Map<Id, OrderApi__Badge__c> oldItems) {

        Set<Id> conId = new Set<Id>();
        Set<String> setCGroup = new Set<String>();
        List<Contact> lstCon = new List<Contact>();
        Set<Id> checkDuplicateConIds = new Set<Id>();
        Set<Id> checkDuplicateConIdUpdate = new Set<Id>();
        Set<String> setContactId = new Set<String>();
        Set<String> setCGroupName = new Set<String>();

        for(sObject obj : newItems.values()){
            OrderApi__Badge__c badge = (OrderApi__Badge__c)obj;
            OrderApi__Badge__c badgeold = (OrderApi__Badge__c)oldItems.get(obj.Id);
            if(!badge.OrderApi__Is_Active__c && badge.OrderApi__Is_Active__c != badgeold.OrderApi__Is_Active__c && badge.Name__c.Contains('Member')){
                conId.add(badge.OrderApi__Contact__c);

                Contact con = new Contact();
                con.Id = badge.OrderApi__Contact__c;
                con.Professional_Communities__c = null;
                con.International_Professional_Community__c = null;
                if(!checkDuplicateConIds.contains(con.Id)){
                    checkDuplicateConIds.add(con.Id);
                    lstCon.add(con);
                }
                
            }

            if(!badge.OrderApi__Is_Active__c && badge.OrderApi__Is_Active__c != badgeold.OrderApi__Is_Active__c){
                setCGroup.add(badge.Name__c);
                setContactId.add(badge.OrderApi__Contact__c);
            }

            if(badge.OrderApi__Is_Active__c && badge.OrderApi__Is_Active__c != badgeold.OrderApi__Is_Active__c){
                setCGroupName.add(badge.Name__c);
                setContactId.add(badge.OrderApi__Contact__c);
            }
        }

        List<OrderApi__Badge__c>  lstBadge = [Select Id, OrderApi__Contact__c from OrderApi__Badge__c where 
                                                      OrderApi__Is_Active__c =:true and OrderApi__Contact__c=:conId and 
                                                      Name__c like '%Member%'];

        if(lstBadge.size() > 0){
            List<Contact> lstConUpdate = new List<Contact>();

            Map<Id, OrderApi__Badge__c>  mapBadge = new Map<Id, OrderApi__Badge__c>();
            for(OrderApi__Badge__c badge : lstBadge){
                mapBadge.put(badge.OrderApi__Contact__c, badge);
            }

            for(sObject obj : newItems.values()){
                OrderApi__Badge__c badge = (OrderApi__Badge__c)obj;
                OrderApi__Badge__c badgeold = (OrderApi__Badge__c)oldItems.get(obj.Id);
                if(!badge.OrderApi__Is_Active__c && badge.OrderApi__Is_Active__c != badgeold.OrderApi__Is_Active__c && badge.Name__c.Contains('Member') && !mapBadge.containskey(badge.OrderApi__Contact__c)){
                    Contact con = new Contact();
                    con.Id = badge.OrderApi__Contact__c;
                    con.Professional_Communities__c = null;
                    con.International_Professional_Community__c = null;
                    if(!checkDuplicateConIdUpdate.contains(con.Id)){
                        checkDuplicateConIdUpdate.add(con.Id);
                        lstConUpdate.add(con);
                    }
                    
                }
            }
        
            if(lstConUpdate.size() > 0){
                update lstConUpdate;
            }
            }else{
                if(lstCon.size() > 0){
                    update lstCon;
                }
            }


        if(setCGroup.size() > 0){
            List<PagesApi__Community_Group_Member__c> lstCGM = [Select Id, PagesApi__Community_Group__c, PagesApi__Community_Group__r.Badge_Name__c 
                                                                from PagesApi__Community_Group_Member__c where PagesApi__Contact__c=:setContactId and PagesApi__Is_Active__c = true];

            List<PagesApi__Community_Group_Member__c> lstDelete = new List<PagesApi__Community_Group_Member__c>();
            for(PagesApi__Community_Group_Member__c cgm : lstCGM){
                if(setCGroup.Contains(cgm.PagesApi__Community_Group__r.Badge_Name__c)){
                    cgm.PagesApi__Is_Active__c = false;
                    cgm.PagesApi__Deactivated_Date__c = Date.today();
                    lstDelete.add(cgm);
                }
            }

            if(lstDelete.size() > 0){
                update lstDelete;
            }
        }

        Map<String, Id> communityToGroupMap = new Map<String, Id>();
        List<PagesApi__Community_Group_Member__c> lstCommunituGroupMember = new List<PagesApi__Community_Group_Member__c>();

        for (PagesApi__Community_Group__c cGroup : [SELECT Id, Name, Badge_Name__c, Community_Group__c FROM PagesApi__Community_Group__c where Badge_Name__c=:setCGroupName]) {
            communityToGroupMap.put(cGroup.Badge_Name__c, cGroup.Id);
        }

        if(communityToGroupMap.keyset().size() > 0){
            for(sObject obj : newItems.values()){
                OrderApi__Badge__c badge = (OrderApi__Badge__c)obj;
                OrderApi__Badge__c badgeold = (OrderApi__Badge__c)oldItems.get(obj.Id);
                if(communityToGroupMap.containskey(badge.Name__C) && badge.OrderApi__Is_Active__c != badgeold.OrderApi__Is_Active__c){
                    PagesApi__Community_Group_Member__c groupMember = new PagesApi__Community_Group_Member__c();
                    groupMember.PagesApi__Community_Group__c = communityToGroupMap.get(badge.Name__C);
                    groupMember.PagesApi__Contact__c = badge.OrderApi__Contact__c;
                    lstCommunituGroupMember.add(groupMember);
                }
            }

            if(lstCommunituGroupMember.size() > 0){
                insert lstCommunituGroupMember;
            }
        }

        
    }
 
}