public class UpdateEmail implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext BC){
        date td =date.today();
        return Database.getQueryLocator('Select id,email,OrderApi__Assistant_Email__c,OrderApi__Personal_Email__c,OrderApi__Other_Email__c, OrderApi__Work_Email__c from contact where lastmodifieddate!=:td');
    }
    public void execute(Database.BatchableContext BC, List<Contact> lstcon){
        for(Contact con : lstcon){
            if(con.email!=null){
                con.email = con.email+'.invalid';
            }
            if(con.OrderApi__Personal_Email__c!=null){
                con.OrderApi__Personal_Email__c = con.OrderApi__Personal_Email__c+'.invalid';
            }
            if(con.OrderApi__Work_Email__c!=null){
                con.OrderApi__Work_Email__c = con.OrderApi__Work_Email__c +'.invalid';
            }
               if(con.OrderApi__Other_Email__c!=null){
                con.OrderApi__Other_Email__c = con.OrderApi__Other_Email__c+'.invalid';
            }
        }
        Framework.Dispatcher.disableTriggerInContext.put('Contact', true);
        update lstcon;
        Framework.Dispatcher.disableTriggerInContext.put('Contact', false);
    }
    public void finish(Database.BatchableContext BC){
    }
}