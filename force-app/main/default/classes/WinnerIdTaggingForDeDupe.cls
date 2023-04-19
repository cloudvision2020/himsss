public class WinnerIdTaggingForDeDupe {
    
    public static void setWinnerIds(){
        
        List<DeDupe_Record_Back_Up__c> allWinnerRecords = [SELECT Id,Original_Record_Id__c, De_Dupe_Key_Value__c,Winner_ID__c 
                                                           FROM DeDupe_Record_Back_Up__c
                                                           WHERE Winner_or_Loser__c = 'Winner'];
        
        List<DeDupe_Record_Back_Up__c> allLoserRecords = [SELECT Id, Original_Record_Id__c, De_Dupe_Key_Value__c,Winner_ID__c 
                                                          FROM DeDupe_Record_Back_Up__c
                                                          WHERE Winner_or_Loser__c = 'Loser'];
        
        Map<String,String> DeDupeValueKeyTowinnerOrginalId = new Map<String,String>();
        
        List<DeDupe_Record_Back_Up__c> losersToUpdate = new List<DeDupe_Record_Back_Up__c>();
        
        for(DeDupe_Record_Back_Up__c winner : allWinnerRecords){
            String keyValue = winner.De_Dupe_Key_Value__c;
            DeDupeValueKeyTowinnerOrginalId.put(keyValue.toLowerCase(), winner.Original_Record_Id__c);
        }
        
        for(DeDupe_Record_Back_Up__c loser : allLoserRecords){
            String keyValue = loser.De_Dupe_Key_Value__c;
            loser.Winner_ID__c = DeDupeValueKeyTowinnerOrginalId.get(keyValue.toLowerCase());
            losersToUpdate.add(loser);
        }
        
        if(!losersToUpdate.isEmpty()){
            update losersToUpdate;
        }
        
    }
    
    
}