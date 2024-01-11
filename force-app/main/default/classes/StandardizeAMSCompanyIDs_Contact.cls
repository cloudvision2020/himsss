global class StandardizeAMSCompanyIDs_Contact implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String q = 'SELECT ID,AMS_ID__c,AMS_Contact_ID__c FROM Contact';
        return Database.getQueryLocator(q);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> allContacts) {
        List<Contact> contactsToUpdateAMS = new List<Contact>();
        List<Contact> contactsToUpdateAMSContact = new List<Contact>();
        List<Contact> toUpdateAMS = new List<Contact>();
        List<Contact> toUpdateAMSContact = new List<Contact>();
        
        for(Contact c : allContacts){
            if(c.AMS_ID__c != null){
                String ams = c.AMS_ID__c;
                if(ams.Length() < 12){
                    contactsToUpdateAMS.add(c); 
                }
            }
        }
        
        for(Contact c : allContacts){
            if(c.AMS_Contact_ID__c != null){
                String ams = c.AMS_Contact_ID__c;
                if(ams.Length() < 12){
                    contactsToUpdateAMSContact.add(c); 
                }
            }
        }
        
        for(Contact c : contactsToUpdateAMS){
            String currentAMS =c.AMS_ID__c;
            String newAms = currentAMS.leftPad(12, '0');
            c.AMS_ID__c = newAms;
            toUpdateAMS.add(c);
        }
        
        for(Contact c : contactsToUpdateAMSContact){
            String currentAMSContact =c.AMS_Contact_ID__c;
            String newAmsContact = currentAMSContact.leftPad(12, '0');
            c.AMS_Contact_ID__c = newAmsContact;
            toUpdateAMSContact.add(c);
        }
        update toUpdateAMS;
        update toUpdateAMSContact;
        
    }
    global void finish(Database.BatchableContext BC) {
        system.debug('FINISHED ADJUSTING AMS COMPANY IDS - Contact');
    }
    
}