public class BatchCEHoursUpdateOnSubscription implements Database.Batchable<sObject>{

   public final String STATUSACTIVE = 'Active';
   Set<Id> setIdsStatefull =  new Set<Id>();

   public BatchCEHoursUpdateOnSubscription(){
     
   }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id, Education_Provider__c, Number_Of_Credits__c, Term__r.OrderApi__Subscription__c, Term__r.OrderApi__Subscription__r.orderAPI__Contact__c From CE_Hours__c Where Term__r.OrderApi__Subscription__r.OrderApi__Status__c=:STATUSACTIVE AND Term__r.OrderApi__Subscription__r.Is_Certificate__c =true'; 
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<CE_Hours__c > scope){
        Set<Id> setIds =  new Set<Id>();
        Map<Id, Integer> mapOfActiveTerm = new  Map<Id, Integer>();
        Map<Id, Integer> mapOfApprovedHimss = new  Map<Id, Integer>();
        Map<Id, Integer> mapOfNonApprovedHimss = new  Map<Id, Integer>();
        for(CE_Hours__c  ce : scope){
            if(!setIdsStatefull.contains(ce.Term__r.OrderApi__Subscription__c)){
                setIds.add(ce.Term__r.OrderApi__Subscription__c); 
                setIdsStatefull.add(ce.Term__r.OrderApi__Subscription__c); 
            }
        }
        for(CE_Hours__c  ce : [Select id,Term__c, Number_Of_Credits__c, Education_Provider__c, Term__r.OrderApi__Subscription__c, Term__r.OrderApi__Subscription__r.orderAPI__Contact__c 
                                FROM CE_Hours__c 
                                where Term__r.OrderApi__Subscription__c=:setIds 
                                AND Term__r.OrderApi__Subscription__r.OrderApi__Status__c=:STATUSACTIVE]){
                                
            if(ce.Education_Provider__c=='HIMSS'){
                Integer approvedTerms = mapOfApprovedHimss.get(ce.Term__r.OrderApi__Subscription__c); 
                if(approvedTerms==null){
                    approvedTerms = 0;
                }  
                if(ce.Number_Of_Credits__c!=null){  
                    approvedTerms+=Integer.valueOf(ce.Number_Of_Credits__c);
                }
                mapOfApprovedHimss.put(ce.Term__r.OrderApi__Subscription__c,approvedTerms); 
            }
            else if(ce.Education_Provider__c=='NON-HIMSS'){
                Integer  nonApprovedTerms = mapOfNonApprovedHimss.get(ce.Term__r.OrderApi__Subscription__c);
                if(nonApprovedTerms ==null){
                    nonApprovedTerms = 0;
                }
                if(ce.Number_Of_Credits__c!=null){
                    nonApprovedTerms+=Integer.valueOf(ce.Number_Of_Credits__c);
                }
                mapOfNonApprovedHimss.put(ce.Term__r.OrderApi__Subscription__c,nonApprovedTerms); 
            }
            Integer activeTerms = mapOfActiveTerm.get(ce.Term__r.OrderApi__Subscription__c); 
            if(activeTerms ==null){
                activeTerms = 0;
            }
            if(ce.Number_Of_Credits__c!=null){
                activeTerms+=Integer.valueOf(ce.Number_Of_Credits__c);
            }
            mapOfActiveTerm.put(ce.Term__r.OrderApi__Subscription__c,activeTerms); 
        }
        Map<Id,OrderApi__Subscription__c>  subToUpdate = new Map<Id,OrderApi__Subscription__c>();
        for(CE_Hours__c  ce : scope){
            OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
            sub.Id = ce.Term__r.OrderApi__Subscription__c;
            if(!subToUpdate.containsKey(sub.Id)){
                if( mapOfActiveTerm.get(ce.Term__r.OrderApi__Subscription__c)!=null){
                    sub.Active_Term_CE_Hours__c = mapOfActiveTerm.get(ce.Term__r.OrderApi__Subscription__c);
                }
                if(mapOfApprovedHimss.get(ce.Term__r.OrderApi__Subscription__c)!=null){
                    sub.Active_Term_Approved_HIMSS_CE_Hours__c = mapOfApprovedHimss.get(ce.Term__r.OrderApi__Subscription__c);
                }
                if(mapOfNonApprovedHimss.get(ce.Term__r.OrderApi__Subscription__c)!=null){
                    sub.Active_Term_Non_Approved_CE_Hours__c = mapOfNonApprovedHimss.get(ce.Term__r.OrderApi__Subscription__c);
                }
                subToUpdate.put(sub.id,sub); 
            }
        }
        if(!subToUpdate.isEmpty()){
            update subToUpdate.values();
        }
    }

   public void finish(Database.BatchableContext BC){
   
   }
}