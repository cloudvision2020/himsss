public class ReparentChildrenPostDedupe {
    
    public static void reparentOpportunities(List<DeDupe_Record_Back_Up__c> allLoserAccountBackupRecords,Map<String,String> loserAccountOriginalIdToWinnerId,
                                             List<String> loserAccountOriginalIds)
    {
        List<Opportunity> opportunitiesToBeReparented = new List<Opportunity>();
        
        
        for(opportunity o : [SELECT id,AccountId,Name FROM Opportunity 
                             WHERE AccountId IN :loserAccountOriginalIds])
        {
            o.AccountId = loserAccountOriginalIdToWinnerId.get(o.AccountId);
            opportunitiesToBeReparented.add(o);
        }
        
        if(!opportunitiesToBeReparented.isEmpty()){
            update opportunitiesToBeReparented;
        }
    }
    
    public static void reparentContacts(List<DeDupe_Record_Back_Up__c> allLoserAccountBackupRecords,Map<String,String> loserAccountOriginalIdToWinnerId,
                                        List<String> loserAccountOriginalIds)
    {
        List<Contact> contactsToBeReparented = new List<Contact>();
        
        for(contact c : [SELECT id,AccountId FROM Contact 
                         WHERE AccountId IN :loserAccountOriginalIds])
        {
            c.AccountId = loserAccountOriginalIdToWinnerId.get(c.AccountId);
            contactsToBeReparented.add(c);
        }
        
        if(!contactsToBeReparented.isEmpty()){
            update contactsToBeReparented;
        }
        removeHistoricContactAccountRelationships(contactsToBeReparented,loserAccountOriginalIds);
        
    }
    
    public static void removeHistoricContactAccountRelationships(List<Contact> contactsToBeReparented,List<String> loserAccountOriginalIds)
    {
        List<String> reparentedContactIds = new List<String>();
        
        for(Contact c : contactsToBeReparented){
            reparentedContactIds.add(c.id);
        }
        
        List<AccountContactRelation> LoserAccountContactRelationships = [SELECT id 
                                                                         FROM AccountContactRelation 
                                                                         WHERE AccountId IN :loserAccountOriginalIds
                                                                         AND ContactId IN :reparentedContactIds];
        if(!LoserAccountContactRelationships.isEmpty()){
            delete LoserAccountContactRelationships;
        }
    }
    
    public static void reparentContracts(List<DeDupe_Record_Back_Up__c> allLoserAccountBackupRecords,Map<String,String> loserAccountOriginalIdToWinnerId,
                                         List<String> loserAccountOriginalIds)
    {
        List<Contract> contractsToBeReparented = new List<Contract>();
        
        for(Contract c : [SELECT id,AccountId FROM Contract 
                          WHERE AccountId IN :loserAccountOriginalIds])
        {
            c.AccountId = loserAccountOriginalIdToWinnerId.get(c.AccountId);
            contractsToBeReparented.add(c);
        }
        
        if(!contractsToBeReparented.isEmpty()){
            update contractsToBeReparented;
        }
        
    }
    
    public static void addReparentedOppsandContactsToBackup(List<String> loserAccountOriginalIds,List<DeDupe_Record_Back_Up__c> allLoserAccountBackupRecords){
        
        List<DeDupe_Record_Back_Up__c> bRToUpdate = new List<DeDupe_Record_Back_Up__c>();
        List<Opportunity> OppsFromLoserAccounts = [SELECT id,Name,AccountId FROM Opportunity WHERE AccountId IN :loserAccountOriginalIds];
        List<Contact> ContactFromLoserAccounts = [SELECT id,Name,AccountId FROM Contact WHERE AccountId IN :loserAccountOriginalIds];
        Map<String, List<String>> LoserAccountIdToOpportunityNames = new Map<String,List<String>>();
        Map<String, List<String>> LoserAccountIdToContactNames = new Map<String,List<String>>();
        
        for(String s : loserAccountOriginalIds){
            List<String> oppNames = new List<String>();
            for(Opportunity o : OppsFromLoserAccounts){
                if(o.AccountId == s){
                    oppNames.add(o.Name);
                }
            }
            LoserAccountIdToOpportunityNames.put(s, oppNames);
        }
        
        for(String s : loserAccountOriginalIds){
            List<String> contNames = new List<String>();
            for(Contact c : ContactFromLoserAccounts){
                if(c.AccountId == s){
                    contNames.add(c.Name);
                }
            }
            LoserAccountIdToContactNames.put(s, contNames);
        }
        
        for(DeDupe_Record_Back_Up__c dBR : allLoserAccountBackupRecords){
            
            dBR.Re_Parented_Opportunities__c = string.join(LoserAccountIdToOpportunityNames.get(dBR.Original_Record_Id__c), ', ');
            dBR.Re_Parented_Contacts__c = string.join(LoserAccountIdToContactNames.get(dBR.Original_Record_Id__c), ', ');
            bRToUpdate.add(dBR);
        }
        
        if(!bRToUpdate.isEmpty()){
            update bRToUpdate;
        }
        
    }
    
    
}