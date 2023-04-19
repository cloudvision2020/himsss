public class Fon_ItemAuditUpdateBachable implements Database.Batchable<sObject>,Database.Stateful
{
public string ItemId;
public Integer noOfSubsConsidered;
public string orderby;
public list<Contact> contactList=new list<Contact>();
public Fon_ItemAuditUpdateBachable(String ItemId,Integer noOfSubsConsidered,String orderby){
    this.ItemId=ItemId;
    this.noOfSubsConsidered=noOfSubsConsidered;
    this.orderby=orderby;
}

public Database.QueryLocator start(Database.BatchableContext BC){
    String queryString='';
    if(orderby!='' && orderby!=null){
    queryString='select id from OrderApi__Subscription__c where OrderApi__Item__c=:ItemId and OrderApi__Status__c=\'Active\'  ORDER BY '+orderby +' limit ' +noOfSubsConsidered;
    }else{
        queryString='select id from OrderApi__Subscription__c where OrderApi__Item__c=:ItemId and OrderApi__Status__c=\'Active\' limit ' +noOfSubsConsidered;
    }
    return Database.getQueryLocator(queryString);

}

public void execute(Database.BatchableContext BC,OrderApi__Subscription__c[] lstsubs){          
    contactList.addAll(Fon_ItemAuditUpdateBachableHandler.updateTerms(lstsubs));       
}

public void finish(Database.BatchableContext BC){   
    list<EmailTemplate> template = [Select id,body,subject from EmailTemplate where developername =: System.Label.Fon_Audit_Template_Name];     
    if(template.size()>0){
        list<Messaging.SingleEmailMessage> emailList=new list<Messaging.SingleEmailMessage>();
        if(!contactList.isEmpty()){                
            for(Contact con : contactList){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[]{con.email};
                mail.setToAddresses(toAddresses);
                String plainBody = template[0].body.replace('[credential]', 'testing');
                plainBody=plainBody.replace('{!Contact.FirstName}', con.FirstName);
                plainBody=plainBody.replace('{!Contact.LastName}', con.LastName);
                mail.setPlainTextBody(plainBody);
                mail.setSubject(template[0].subject);
                mail.setTargetObjectId(con.Id);  
                //mail.
                emailList.add(mail);
            }                
        }  
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList,false);
        }         
    }        
}
}