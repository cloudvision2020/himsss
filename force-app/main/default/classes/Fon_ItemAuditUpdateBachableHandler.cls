public class Fon_ItemAuditUpdateBachableHandler {
    public static list<Contact> updateTerms(OrderApi__Subscription__c[] lstsubs){
       set<String> contactIds=new set<String>();
       list<Contact> contactList=new list<Contact>();
        list<OrderApi__Renewal__c> termsToUpdate=new list<OrderApi__Renewal__c>();
                for(OrderApi__Subscription__c sub:[select id,OrderApi__Item__c,OrderApi__Contact__r.email,OrderApi__Status__c,(select id,Audit__c from OrderApi__Renewals__r)terms from OrderApi__Subscription__c where Id IN:lstsubs]){
                    if(!(sub.OrderApi__Renewals__r).isEmpty()){
                        for(OrderApi__Renewal__c term:sub.OrderApi__Renewals__r){
                            term.Audit__c=true;
                            termsToUpdate.add(term);
                        }
                        contactIds.add(sub.OrderApi__Contact__c);
                    }
                } 
        if(!termsToUpdate.isEmpty()){
            update  termsToUpdate; 
        }
        if(!contactIds.isEmpty()){
            return [select id,firstname,lastname,email from contact where id IN:contactIds];
        }
        else{
            return contactList;
        }        
    }
}