global class AMS_Leading_Nine_Batch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, AMS_ID__c FROM  Contact';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> ContactList) {
                
        STRING LEADINGNUMBER = '9';
        List<Contact> updateContacts = new List<Contact>();
        
        Set<String> duplicateAMS = new Set<String>();
        for (AggregateResult aggregate : [SELECT AMS_ID__c,count(id) FROM Contact WHERE ID IN:ContactList GROUP BY AMS_ID__c HAVING count(AMS_ID__c)>1 ORDER BY AMS_ID__c])
        {
            duplicateAMS.add((String)aggregate.get('AMS_ID__c'));
        }
        
        List<Contact> relevantContacts = [SELECT ID, NAME, AMS_ID__c FROM Contact WHERE AMS_ID__c IN :duplicateAMS];
        
        List<String> splitString = new List<String>();
        
        for(Contact c : relevantContacts){
            splitString = c.AMS_ID__c.split('');
            if(splitstring[0] == '0'){
                splitstring[0] = LEADINGNUMBER;
                String newAMS = String.join(splitstring,'');
                c.AMS_ID__c = newAMS;
                updateContacts.add(c);
            }
        }
        
        update updateContacts;
        
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('Batch Complete!');
    }
}