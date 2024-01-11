global class StandardizeAMSCompanyIDs_Account implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String q = 'SELECT ID, AMS_Company_ID__c FROM Account';
        return Database.getQueryLocator(q);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> allAccounts) {
        List<Account> accountsToUpdateAMS = new List<Account>();
        List<Account> toUpdate = new List<Account>();
        
        for(Account a : allAccounts){
            if(a.AMS_Company_ID__c != null){
                String ams = a.AMS_Company_ID__c;
                if(ams.Length() < 12){
                    accountsToUpdateAMS.add(a); 
                }
            }
        }
        
        for(Account a : accountsToUpdateAMS){
            String currentAMS = a.AMS_Company_ID__c;
            String newAms = currentAMS.leftPad(12, '0');
            a.AMS_Company_ID__c = newAms;
            toUpdate.add(a);
        }
        update toUpdate;
    }
    global void finish(Database.BatchableContext BC) {
        system.debug('FINISHED ADJUSTING AMS COMPANY IDS - ACCOUNT');
    }
    
}