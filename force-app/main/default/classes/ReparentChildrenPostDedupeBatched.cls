global class ReparentChildrenPostDedupeBatched implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String originalOBJ = 'Account';
        String loserTag = 'Loser';
        String query = 'SELECT Id,Original_Record_Id__c, Winner_ID__c FROM DeDupe_Record_Back_Up__c WHERE Original_Object__c = :originalOBJ AND Winner_or_Loser__c = :loserTag';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<DeDupe_Record_Back_Up__c> allLoserAccountBackupRecords) {
        
        Map<String,String> loserAccountOriginalIdToWinnerId = new Map<String,String>();
        List<String> loserAccountOriginalIds = new List<String>();
        
        for(DeDupe_Record_Back_Up__c loserAccount : allLoserAccountBackupRecords){
            loserAccountOriginalIdToWinnerId.put(loserAccount.Original_Record_Id__c, loserAccount.Winner_ID__c);
            loserAccountOriginalIds.add(loserAccount.Original_Record_Id__c);
        }
        //ReparentChildrenPostDedupe.addReparentedOppsandContactsToBackup(loserAccountOriginalIds,allLoserAccountBackupRecords);
        //ReparentChildrenPostDedupe.reparentOpportunities(allLoserAccountBackupRecords,loserAccountOriginalIdToWinnerId,loserAccountOriginalIds);
        //ReparentChildrenPostDedupe.reparentContacts(allLoserAccountBackupRecords,loserAccountOriginalIdToWinnerId,loserAccountOriginalIds);
        ReparentChildrenPostDedupe.reparentContracts(allLoserAccountBackupRecords,loserAccountOriginalIdToWinnerId,loserAccountOriginalIds);
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('BATCH FINISHED');
    }
    
}