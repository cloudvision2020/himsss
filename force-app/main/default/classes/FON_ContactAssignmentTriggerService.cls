public without sharing class FON_ContactAssignmentTriggerService{
    public static Boolean runOnce = false;

    public static void createChapterSubscription(List<Contact> lstNewContact, Map<Id,Contact> mapIdToOldContact){
        List<Contact> contacts = new List<Contact>();
        for(Contact con: lstNewContact){
            if(String.isNotBlank(con.Chapter_Complimentary_Membership__c) && 
              	con.Chapter_Complimentary_Membership__c != mapIdToOldContact.get(con.Id).Chapter_Complimentary_Membership__c){
                    contacts.add(con);
            }
        }
        if(contacts.size() > 0){
            createSalesOrder(contacts,mapIdToOldContact);
        }
        
    } 

    // This method will fire on after update event
    public static void createSalesOrder(List<Contact> lstNewContact,Map<Id,Contact> mapIdToOldContact){
        system.debug('***createSalesOrder***');
        
        List<OrderApi__Subscription_Line__c> himssSubsLineList = new List<OrderApi__Subscription_Line__c>();
        List<OrderApi__Renewal__c> himssTerms = new List<OrderApi__Renewal__c>();
        List<OrderApi__Sales_Order__c> lstPostedExistingSalesOrder = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Sales_Order__c> lstPostedSalesOrder = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Subscription_Line__c> newSubsLines = new List<OrderApi__Subscription_Line__c>();
        
        Map<Id,OrderApi__Sales_Order__c> mapContactIdToSalesOrder = new Map<Id,OrderApi__Sales_Order__c>();
        Map<Id,OrderApi__Sales_Order_Line__c> mapContactIdToSOLI = new Map<Id,OrderApi__Sales_Order_Line__c>();
        
        List<Contact> lstFilterContact = new List<Contact>();
        List<String> lstNewChapterName = new List<String>();
        Set<Id> setOfContactId = new Set<Id>();

        for(Contact eachContact : lstNewContact){
            
            System.debug('Chapter Complimentary Membership value : '+eachContact.Chapter_Complimentary_Membership__c);
            System.debug('Opt out of Chapter Membership : '+eachContact.Opt_out_of_Chapter_Membership__c);
            //System.debug('Is Update Required : '+eachContact.IsUpdateRequired__c);
            
            if(String.isNotBlank(eachContact.Chapter_Complimentary_Membership__c) && eachContact.Opt_out_of_Chapter_Membership__c == 'No'){
                String strNewChapter = 'HIMSS '+eachContact.Chapter_Complimentary_Membership__c;
                lstNewChapterName.add(strNewChapter);
                lstFilterContact.add(eachContact);
                setOfContactId.add(eachContact.Id);
            }
        }
        system.debug('lstNewChapterName : '+lstNewChapterName);
        system.debug('lstFilterContact : '+lstFilterContact);
        system.debug('setOfContactId : '+setOfContactId);

        if(lstFilterContact.size() > 0){
            Map<Id,OrderApi__Subscription__c> mapPrimarySubscription = fetchPrimaryMembership(setOfContactId);
            Map<String,OrderApi__Item__c> mapNewChapterNameToObjItem = fetchChapterItem(lstNewChapterName);
            Map<Id,OrderApi__Price_Rule__c> priceRuleMap = fetchPriceRule(lstNewChapterName);
            Map<Id,OrderApi__Subscription_Line__c> mapContactIdToObjSubsLI = fetchSubsLIByContactId(setOfContactId,mapPrimarySubscription);
			
            system.debug('mapPrimarySubscription : '+mapPrimarySubscription);
            system.debug('mapNewChapterNameToObjItem : '+mapNewChapterNameToObjItem);
            system.debug('priceRuleMap : '+priceRuleMap);
            system.debug('mapContactIdToObjSubsLI : '+mapContactIdToObjSubsLI);

            for(Contact eachContact : lstFilterContact){
                system.debug('eachContact : '+eachContact);
                
                String strNewChapter = 'HIMSS '+eachContact.Chapter_Complimentary_Membership__c;
                system.debug('strNewChapter : '+strNewChapter);

                if(mapPrimarySubscription.containsKey(eachContact.Id)){
                    himssSubsLineList = mapPrimarySubscription.get(eachContact.Id).OrderApi__Subscription_Lines__r;
                    himssTerms = mapPrimarySubscription.get(eachContact.Id).OrderApi__Renewals__r;
                }

                System.debug('himssSubsLineList : '+himssSubsLineList);
                System.debug('himssTerms : '+himssTerms);

                if(himssSubsLineList.size() > 0){
                    system.debug('SOL chapter Name : '+himssSubsLineList[0].OrderApi__Item__r.Name);
                    system.debug('SOL contains chapter : '+himssSubsLineList[0].OrderApi__Item__r.Name.contains(eachContact.Chapter_Complimentary_Membership__c));
                    if(himssSubsLineList[0].OrderApi__Item__r.Name.contains(eachContact.Chapter_Complimentary_Membership__c)){
                        return;
                    }
                }

                if(mapNewChapterNameToObjItem.containsKey(strNewChapter) && himssTerms.size() > 0
                   && mapPrimarySubscription.containsKey(eachContact.Id)){
                       system.debug('himssSubsLineList 1 : '+himssSubsLineList);
                       if(himssSubsLineList.Size() > 0){
                       		system.debug('himssSubsLineList 2 : '+himssSubsLineList);    
                           //List<OrderApi__Subscription_Line__c> newSubscriptionLines = fetchActiveNewSubscription(setOfContactId);
                           //system.debug('newSubscriptionLines : '+newSubscriptionLines);
                           
                           for(OrderApi__Subscription_Line__c subsLine: himssSubsLineList){
                               subsLine.OrderApi__Item__c = mapNewChapterNameToObjItem.get(strNewChapter).Id;
                               subsLine.OrderApi__Line_Description__c = strNewChapter;
                               subsLine.OrderApi__Price_Rule__c = priceRuleMap.get(subsLine.OrderApi__Item__c).Id;
                               newSubsLines.add(subsLine);    
                           }
                       }else{
                           system.debug('mapContactIdToObjSubsLI : '+mapContactIdToObjSubsLI);
                           if(!mapContactIdToObjSubsLI.containsKey(eachContact.Id)){
                                mapContactIdToSalesOrder.put(eachContact.Id,fetchSalesOrderInstance(eachContact));
                                mapContactIdToSOLI.put(eachContact.Id,fetchSalesOrderInstance(eachContact, mapNewChapterNameToObjItem.get(strNewChapter), himssTerms[0]));                               
                           }
                           
                       }
                    }
            }

            System.debug('mapContactIdToSalesOrder : '+mapContactIdToSalesOrder);
            System.debug('mapContactIdToSOLI : '+mapContactIdToSOLI);

            if(!mapContactIdToSalesOrder.values().isEmpty()){
                
                insert mapContactIdToSalesOrder.values();
                
                List<OrderApi__Sales_Order__c> lstPostedNewSalesOrder = new List<OrderApi__Sales_Order__c>();
                
                for(Id eachContactId : mapContactIdToSalesOrder.keySet()){
                    OrderApi__Sales_Order__c objSO = mapContactIdToSalesOrder.get(eachContactId);
                    OrderApi__Sales_Order_Line__c objSOLI = mapContactIdToSOLI.get(eachContactId);
                    objSOLI.OrderApi__Sales_Order__c = objSO.Id;
                    lstPostedNewSalesOrder.add(objSO);
                }
                
                insert mapContactIdToSOLI.values();
                
                for(OrderApi__Sales_Order__c eachSO : lstPostedNewSalesOrder){
                    eachSO.OrderApi__Is_Closed__c = true;
                }
                
                if(lstPostedNewSalesOrder.size() > 0){
                    Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Sales_Order__c', true);
                        update lstPostedNewSalesOrder;
                    Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Sales_Order__c', false);    
                }
                
                for(OrderApi__Sales_Order__c eachSO : lstPostedNewSalesOrder){
                    eachSO.OrderApi__Is_Posted__c = true;
                }
                
                if(lstPostedNewSalesOrder.size() > 0){
                    update lstPostedNewSalesOrder;
                }
                
            }
            
            if(newSubsLines.size() > 0){
                system.debug('newSubsLines : '+newSubsLines);
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription_Line__c', true);
                    update newSubsLines;
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Subscription_Line__c', false);
                
                if(mapIdToOldContact.size() > 0 && newSubsLines.size() > 0){
                	updateBadge(newSubsLines,mapIdToOldContact,false);    
                }
                
            }
        }
    }
    
    
    public static void updateBadge(List<OrderApi__Subscription_Line__c> newSubsLines, Map<Id,Contact> mapIdToOldContact, boolean isExpired){
        system.debug('***updateBadge***');
        system.debug('newSubsLines : '+newSubsLines);
        system.debug('newSubsLines Item : '+newSubsLines[0].OrderApi__Line_Description__c+'---'+newSubsLines[0].OrderApi__Item__c);
        List<OrderApi__Badge__c> updateBadge = new List<OrderApi__Badge__c>();
        Map<String,string> solBadgeTypeNamesMap = new Map<String,string>();
        map<string,OrderApi__Subscription_Line__c> solSubsLineMap = new map<string,OrderApi__Subscription_Line__c>();
        map<String,String> solItemMap = new map<String,String>();
        map<string,OrderApi__Badge_Type__c> badgeTypeMap = new map<string,OrderApi__Badge_Type__c>();
        Set<Id> contactIds = new Set<Id>();
        Set<String> OldBadgeTypeNameSet = new Set<String>();
        
        for(OrderApi__Subscription_Line__c subsLine: newSubsLines){
            
            system.debug('Item Name : '+subsLine.OrderApi__Line_Description__c);
            system.debug('Item Id : '+subsLine.OrderApi__Item__c);
            string badgeTypeName = 'Chapter Member - '+getBadgeTypeName(subsLine.OrderApi__Line_Description__c);
            string OldBadgeTypeName = '';
            if(mapIdToOldContact.containsKey(subsLine.OrderApi__Subscription__r.OrderApi__Contact__c)){
                Contact con = mapIdToOldContact.get(subsLine.OrderApi__Subscription__r.OrderApi__Contact__c);
                OldBadgeTypeName = getOldBadgeTypeName(con.Chapter_Complimentary_Membership__c);
            }
            
            system.debug('OldBadgeTypeName : '+OldBadgeTypeName);
            system.debug('badgeTypeName : '+badgeTypeName);
            if(subsLine.OrderApi__Sales_Order_Line__c != null){
                //solBadgeTypeNamesMap.put(subsLine.OrderApi__Sales_Order_Line__c,badgeTypeName);
            	//solItemMap.put(subsLine.OrderApi__Sales_Order_Line__c, subsLine.OrderApi__Item__c);
                //solSubsLineMap.put(subsLine.OrderApi__Sales_Order_Line__c, subsLine);
            	solSubsLineMap.put(OldBadgeTypeName, subsLine);
                solBadgeTypeNamesMap.put(OldBadgeTypeName,badgeTypeName);
            	solItemMap.put(OldBadgeTypeName, subsLine.OrderApi__Item__c);
            }
            
            OldBadgeTypeNameSet.add(OldBadgeTypeName);
            contactIds.add(subsLine.OrderApi__Subscription__r.OrderApi__Contact__c);
        }
        system.debug('solBadgeTypeNamesMap : '+solBadgeTypeNamesMap);
        system.debug('solItemMap : '+solItemMap);
        List<OrderApi__Badge__c> chapterBadge = [SELECT Id,OrderApi__Contact__c,OrderApi__Is_Active__c,OrderApi__Badge_Type__r.Name,
                                                 OrderApi__Sales_Order_Line__c,OrderApi__Badge_Type__c,OrderApi__Item__c,OrderApi__Expired_Date__c 
                                                 FROM OrderApi__Badge__c
                                                 WHERE OrderApi__Badge_Type__r.Name IN: OldBadgeTypeNameSet
                                                 AND OrderApi__Contact__c IN: contactIds
                                                 AND (OrderApi__Is_Active__c = true 
                                                      OR OrderApi__Sales_Order_Line__r.OrderApi__End_Date__c > Today)];
        
        system.debug('chapterBadge : '+chapterBadge);
        List<OrderApi__Badge_Type__c> badgeTypes = [SELECT Id,Name 
                                                   FROM OrderApi__Badge_Type__c 
                                                   WHERE Name IN: solBadgeTypeNamesMap.values()];
        
        system.debug('badgeTypes : '+badgeTypes);
        for(OrderApi__Badge_Type__c bt: badgeTypes){
            badgeTypeMap.put(bt.Name, bt);
        }
        system.debug('badgeTypeMap : '+badgeTypeMap);
        
        for(OrderApi__Badge__c badge: chapterBadge){
            string badgeName = '';
            if(!isExpired){
            	if(solBadgeTypeNamesMap.containsKey(badge.OrderApi__Badge_Type__r.Name)){
                    badgeName = solBadgeTypeNamesMap.get(badge.OrderApi__Badge_Type__r.Name);
                    if(badgeTypeMap.containsKey(badgeName)){
                        badge.OrderApi__Badge_Type__c = badgeTypeMap.get(badgeName).Id;
                    }
                }
                if(solItemMap.containsKey(badge.OrderApi__Badge_Type__r.Name)){
                    badge.OrderApi__Item__c = solItemMap.get(badge.OrderApi__Badge_Type__r.Name);
                }
                badge.OrderApi__Sales_Order_Line__c = null;
            }
            else{
                badge.OrderApi__Expired_Date__c = system.today().addDays(-1);
                badge.OrderApi__Sales_Order_Line__c = null;
            }
            updateBadge.add(badge);
        }
        system.debug('updateBadge : '+updateBadge);
        if(updateBadge.size() > 0){
            Framework.Dispatcher.disableTriggerInContext.put('Contact', true);
            	update updateBadge;
            Framework.Dispatcher.disableTriggerInContext.put('Contact', false);
        }
    }
    
    public static string getBadgeTypeName(string chapterName){
        string badgeTypeName = '';
        integer strLength = chapterName.length();
        badgeTypeName = chapterName.right(strLength-6);
        system.debug('badgeTypeName 1: '+badgeTypeName);
        strLength = badgeTypeName.length();
        badgeTypeName = badgeTypeName.left(strLength-8);
        system.debug('badgeTypeName 2:'+badgeTypeName);
        return badgeTypeName;
    }
	
    public static string getOldBadgeTypeName(string chapterName){
        string badgeTypeName = '';
        integer strLength = chapterName.length();
        badgeTypeName = chapterName.left(strLength-8);
        system.debug('badgeTypeName : '+badgeTypeName);
        return 'Chapter Member - '+badgeTypeName;
    }
    
    //This method will fire on before update event
    public static void updateContactOpOutChapterMembership(List<Contact> lstNewContact, Map<Id,Contact> mapIdToOldContact){
        system.debug('***updateContactOpOutChapterMembership***');
        List<OrderApi__Subscription_Line__c> subsLines = new List<OrderApi__Subscription_Line__c>();
        Boolean isChapterMembershipOptOutNo = false;
        Set<Id> setOfContactId = new Set<Id>();

        Map<Id,OrderApi__Subscription__c> mapPrimarySubscription = fetchPrimaryMembership(mapIdToOldContact.KeySet());

        for(contact eachContact: lstNewContact){
            System.debug('Chapter Complimentary Membership value : '+eachContact.Chapter_Complimentary_Membership__c);
            System.debug('Opt out of Chapter Membership : '+eachContact.Opt_out_of_Chapter_Membership__c);
            //if(String.isNotBlank(eachContact.Chapter_Complimentary_Membership__c) && 
            if(eachContact.Opt_out_of_Chapter_Membership__c == 'Yes' &&
                mapIdToOldContact.get(eachContact.Id).Opt_out_of_Chapter_Membership__c =='No'){
                    system.debug('***Chapter Membership Opt out No***');
                    eachContact.Chapter_Complimentary_Membership__c = '';
                    if(mapPrimarySubscription.Size() > 0 && mapPrimarySubscription.ContainsKey(eachContact.Id)){
                        OrderApi__Subscription__c subs = mapPrimarySubscription.get(eachContact.Id);
                        if(subs.OrderApi__Subscription_Lines__r.size() > 0){
                            for(OrderApi__Subscription_Line__c sl: subs.OrderApi__Subscription_Lines__r){}
                            subsLines.addAll(subs.OrderApi__Subscription_Lines__r);
                        }
                        
                    }
               }
        }

        system.debug('subsLines : '+subsLines);
            
        if(subsLines.size() > 0){
            system.debug('subsLines inside if : '+subsLines);
            updateBadge(subsLines,mapIdToOldContact,true);
            delete subsLines;
        }
    }

    public static List<OrderApi__Subscription_Line__c> fetchNewSubscription(Set<Id> chapterSubsLine){
        List<OrderApi__Subscription_Line__c> lstSubsLines = [SELECT Id,OrderApi__Item__c,OrderApi__Term__c,OrderApi__Subscription__c,
                                                             OrderApi__Subscription__r.OrderApi__Contact__c,OrderApi__Item__r.Name  
                                                             FROM OrderApi__Subscription_Line__c
                                                             WHERE Id IN : chapterSubsLine 
                                                             AND OrderApi__Subscription__r.OrderApi__Status__c =: 'Active' 
                                                             ORDER BY CreatedDate DESC limit 1];
        return lstSubsLines;
    }
    
    public static List<OrderApi__Subscription_Line__c> fetchActiveNewSubscription(Set<Id> setOfContactId){
        List<OrderApi__Subscription_Line__c> lstSubsLines = [SELECT Id,OrderApi__Item__c,OrderApi__Term__c,OrderApi__Subscription__c,
                                                             OrderApi__Subscription__r.OrderApi__Contact__c,OrderApi__Item__r.Name  
                                                             FROM OrderApi__Subscription_Line__c
                                                             WHERE OrderApi__Subscription__r.OrderApi__Contact__c IN : setOfContactId 
                                                             AND OrderApi__Subscription__r.OrderApi__Status__c =: 'Active'
                                                             AND OrderApi__Item__r.Name LIKE '%HIMSS%'
                                                             AND (NOT OrderApi__Item__r.Name LIKE '%Annual Membership%') 
                                                             AND OrderApi__Item_Class__r.Name = 'Chapter Memberships'
                                                             ORDER BY CreatedDate DESC limit 1];
        return lstSubsLines;
    }
    
    public static Map<Id,OrderApi__Price_Rule__c> fetchPriceRule(List<String> ItemNames){
        Map<Id,OrderApi__Price_Rule__c> priceRuleMap = new Map<Id,OrderApi__Price_Rule__c>();
        List<OrderApi__Price_Rule__c> priceRuleList = [Select id,OrderApi__Item__c,Name,OrderApi__Price__c 
                                                       from OrderApi__Price_Rule__c 
                                                       where Name IN : ItemNames
                                                       Limit 1];
        for(OrderApi__Price_Rule__c priceR: priceRuleList){
            priceRuleMap.put(priceR.OrderApi__Item__c, priceR);
        }
        return priceRuleMap;
    }
    
    
    public static Map<Id,OrderApi__Subscription__c> fetchPrimaryMembership(Set<Id> setOfContactId){
        system.debug('***fetchPrimaryMembership***');
        system.debug('setOfContactId : '+setOfContactId);
        Map<Id,OrderApi__Subscription__c> conSubsMap = new Map<Id,OrderApi__Subscription__c>();
        List<OrderApi__Subscription__c> lstSubs = [SELECT Id,OrderApi__Item__r.Free_Chapter_member_included__c,OrderApi__Contact__c,OrderApi__Status__c,OrderApi__Item__r.Name,
                                                   (SELECT Id,OrderApi__Term_Start_Date__c,OrderApi__Term_End_Date__c,
                                                        OrderApi__Account__c    
                                                      FROM OrderApi__Renewals__r
                                                      WHERE OrderApi__Is_Active__c = true
                                                      ORDER BY OrderApi__Term_End_Date__c DESC
                                                   ),
                                                   (SELECT Id,OrderApi__Subscription__c,OrderApi__Sales_Order_Line__c,OrderApi__Subscription__r.OrderApi__Contact__c,  
                                                              OrderApi__Item__c,OrderApi__Item__r.Name,OrderApi__Line_Description__c
                                                      FROM OrderApi__Subscription_Lines__r 
                                                      WHERE OrderApi__Item__r.Name LIKE '%HIMSS%'
                                                      AND (NOT OrderApi__Item__r.Name LIKE '%Annual Membership%') 
                                                      AND OrderApi__Item_Class__r.Name = 'Chapter Memberships'
                                                   	  AND IsActiveForMembership__c = true
                                                   )  
                                                   FROM OrderApi__Subscription__c   
                                                   WHERE OrderApi__Contact__c IN : setOfContactId
                                                   AND OrderApi__Item__r.Free_Chapter_member_included__c = true
                                                   AND OrderApi__Status__c = 'Active'
                                                   ORDER BY CreatedDate DESC limit 1];
        for(OrderApi__Subscription__c subs: lstSubs){
            if(!conSubsMap.containsKey(subs.OrderApi__Contact__c)){
                conSubsMap.put(subs.OrderApi__Contact__c, subs);
            }
        }
        system.debug('conSubsMap : '+conSubsMap);
        return conSubsMap;
    }
    
    
    
    public static Map<String,OrderApi__Item__c> fetchChapterItem(List<String> lstChapterName){
        Map<String,OrderApi__Item__c> mapChapterNameToObjItem = new Map<String,OrderApi__Item__c>();
        List<OrderApi__Item__c> lstItem = [SELECT Id, Name  
                                           FROM OrderApi__Item__c 
                                           WHERE Name IN : lstChapterName];
        for(OrderApi__Item__c eachItem : lstItem){
            mapChapterNameToObjItem.put(eachItem.Name, eachItem);
        }
        return mapChapterNameToObjItem;
    }
    
    
    
    public static OrderApi__Sales_Order__c fetchSalesOrderInstance(Contact objContact){
        system.debug('***fetchSalesOrderInstance SO***');
        OrderApi__Sales_Order__c objNewSO = new OrderApi__Sales_Order__c();
        objNewSO.OrderApi__Contact__c = objContact.Id;
        objNewSO.OrderApi__Account__c = objContact.AccountId;
        objNewSO.OrderApi__Entity__c = 'Contact';
        objNewSO.OrderApi__Is_Posted__c = false;
        return objNewSO;
    }
    
    public static OrderApi__Sales_Order_Line__c fetchSalesOrderInstance(Contact objContact, OrderApi__Item__c objChapterItem, 
                                                                        OrderApi__Renewal__c obRenewalTerm){
                                                                            system.debug('***fetchSalesOrderInstance SOL***');
                                                                            OrderApi__Sales_Order_Line__c objSOLI = new OrderApi__Sales_Order_Line__c();
                                                                            objSOLI.OrderApi__Contact__c = objContact.Id;
                                                                            objSOLI.OrderApi__Account__c = objContact.AccountId;
                                                                            objSOLI.OrderApi__Item__c = objChapterItem.Id;
                                                                            objSOLI.OrderApi__Entity__c = 'Contact';
                                                                            objSOLI.OrderApi__Subscription_Start_Date__c = obRenewalTerm.OrderApi__Term_Start_Date__c;
                                                                            objSOLI.OrderApi__Activation_Date__c = obRenewalTerm.OrderApi__Term_Start_Date__c;
                                                                            objSOLI.OrderApi__End_Date__c = obRenewalTerm.OrderApi__Term_End_Date__c;
                                                                            return objSOLI;
    } 
    
    public static Map<Id,OrderApi__Subscription_Line__c> fetchSubsLIByContactId(Set<Id> setOfContactId, Map<Id,OrderApi__Subscription__c> mapPrimarySubscription){
        system.debug('***fetchSubsLIByContactId***');
        
        Set<Id> subsIds = new Set<Id>();
        for(OrderApi__Subscription__c subs: mapPrimarySubscription.values()){
            subsIds.add(subs.Id);
        }
        system.debug('subsIds : '+subsIds);
        Map<Id,OrderApi__Subscription_Line__c> mapContactIdToObjSubsLI = new Map<Id,OrderApi__Subscription_Line__c>();
        List<OrderApi__Subscription_Line__c> lstSubsLI = [SELECT Id,OrderApi__Subscription__c, OrderApi__Subscription__r.OrderApi__Contact__c, 
                                                              OrderApi__Item__c,OrderApi__Item__r.Name,OrderApi__Subscription__r.OrderApi__Status__c,
                                                              OrderApi__Subscription__r.OrderApi__Item__r.Name
                                                          FROM OrderApi__Subscription_Line__c 
                                                          WHERE OrderApi__Subscription__r.OrderApi__Contact__c IN : setOfContactId 
                                                          AND OrderApi__Item__r.Name LIKE '%HIMSS%' 
                                                          AND OrderApi__Subscription__r.OrderApi__Status__c = 'Active'
                                                          AND OrderApi__Subscription__c IN : subsIds 
                                                          AND OrderApi__Subscription__r.OrderApi__Item__r.Free_Chapter_member_included__c = true
                                                          ORDER BY CreatedDate DESC]; 
        for(OrderApi__Subscription_Line__c eachSubsLI : lstSubsLI){
            if(!mapContactIdToObjSubsLI.containsKey(eachSubsLI.OrderApi__Subscription__r.OrderApi__Contact__c)){
                mapContactIdToObjSubsLI.put(eachSubsLI.OrderApi__Subscription__r.OrderApi__Contact__c, eachSubsLI);
            }
        }
        
        return mapContactIdToObjSubsLI;
    }
}