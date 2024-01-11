global class UnMergeFromBackupsBatched implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String originalOBJ = 'Account';
        String loserTag = 'Loser';
        String querySelect = 'SELECT ID, Winner_ID__c, Original_Record_Id__c, Original_Object__c, Re_Parented_Opportunities__c,Re_Parented_Contacts__c ';
        String queryFrom = 'FROM DeDupe_Record_Back_Up__c ';
        String queryWhere = 'WHERE Original_Object__c = :originalOBJ AND Winner_or_Loser__c = :loserTag AND UnMerged__c = False';
        String query = querySelect+queryFrom+queryWhere;
        return Database.getQueryLocator(query);
    }    
    
    global void execute(Database.BatchableContext BC, List<DeDupe_Record_Back_Up__c> allLoserAccountBackupRecords) {
        try{
        	UnMergeFromBackups.reverseReparentingContacts(allLoserAccountBackupRecords);
        }catch(Exception e){
            system.debug('reverseReparentingContacts');
            system.debug(e.getCause());
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
        
        try{
        	UnMergeFromBackups.reverseReparentingOpportunities(allLoserAccountBackupRecords);
        }catch(Exception e){
            system.debug('reverseReparentingOpportunities');
            system.debug(e.getCause());
            system.debug(e.getLineNumber());
            system.debug(e.getMessage());
            system.debug(e.getTypeName());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('Batch Complete!');
    }
}