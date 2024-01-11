public class UnMergeFromBackups {
    
    public static void reverseReparentingOpportunities(List<DeDupe_Record_Back_Up__c> allLoserBackups){
        List<Opportunity> toUpdate = new List<Opportunity>();
        
        Map<Id,List<String>> originalIdToListofOpportunityNames = new Map<Id,List<String>>();
        Map<Id,Id> WinnerIdToLoserId = new Map<Id,Id>();
        List<Id> WinnerIds = new List<Id>();
        
        for(DeDupe_Record_Back_Up__c dbr :allLoserBackups){
            if(dbr.Re_Parented_Opportunities__c != null){
            	List<String> lstOpportunityNames = dbr.Re_Parented_Opportunities__c.split(', ');
            	originalIdToListofOpportunityNames.put(Id.ValueOf(dbr.Original_Record_Id__c), lstOpportunityNames);
            	WinnerIds.add(Id.ValueOf(dbr.Winner_ID__c));
            	WinnerIdToLoserId.put(Id.ValueOf(dbr.Winner_ID__c),Id.ValueOf(dbr.Original_Record_Id__c));
            }
        }
        
        List<Opportunity> OppsWithWinnerId = [SELECT ID,Name,AccountId FROM Opportunity WHERE AccountId IN :WinnerIds];
        
        for(Opportunity o : OppsWithWinnerId){
            Id originalId = WinnerIdToLoserId.get(o.Accountid);
            List<String> oppList = originalIdToListofOpportunityNames.get(originalId);
            if(originalId != null){
                if(oppList.contains(o.Name)){
                    o.AccountId = originalId;
                    o.Was_Unmerged__c = True;
                    toUpdate.add(o);
                }
            }
        }
        
        if(!toUpdate.isEmpty()){
            update toUpdate;
        }
        
    }
    
    public static void reverseReparentingContacts(List<DeDupe_Record_Back_Up__c> allLoserBackups){
        List<Contact> toUpdate = new List<Contact>();
        
        Map<Id,List<String>> originalIdToListofContactNames = new Map<Id,List<String>>();
        Map<Id,Id> WinnerIdToLoserId = new Map<Id,Id>();
        List<Id> WinnerIds = new List<Id>();
        
        for(DeDupe_Record_Back_Up__c dbr :allLoserBackups){
            if(dbr.Re_Parented_Contacts__c != null){
            	List<String> lstContactNames = dbr.Re_Parented_Contacts__c.split(', ');
            	originalIdToListofContactNames.put(Id.ValueOf(dbr.Original_Record_Id__c), lstContactNames);
            	WinnerIds.add(Id.ValueOf(dbr.Winner_ID__c));
            	WinnerIdToLoserId.put(Id.ValueOf(dbr.Winner_ID__c),Id.ValueOf(dbr.Original_Record_Id__c));
            }
        }
        List<Contact> ContsWithWinnerId = [SELECT ID,Name,FirstName,LastName,AccountId FROM Contact WHERE AccountId IN :WinnerIds];
        
        for(Contact c : ContsWithWinnerId){
            Id originalId = WinnerIdToLoserId.get(c.AccountId);
            List<String> contList = originalIdToListofContactNames.get(originalId);
            if(originalId != null){
                if(contList.Contains(c.FirstName + ' ' + c.LastName)){
                    c.AccountId = originalId;
                    c.Was_Unmerged__c = True;
                    toUpdate.add(c);
                }
            }            
        }
        
        if(!toUpdate.isEmpty()){
            update toUpdate;
        }
        
    }
    
    /*
public static List<DeDupe_Record_Back_Up__c> getLoserBackupsUtil(){
List<DeDupe_Record_Back_Up__c> allLoserBackups = [SELECT ID, Winner_ID__c, Original_Record_Id__c, Original_Object__c, Re_Parented_Opportunities__c,Re_Parented_Contacts__c
FROM DeDupe_Record_Back_Up__c
WHERE Winner_or_Loser__c = 'Loser' AND Original_Object__c = 'Account']; 
return allLoserBackups;
}
*/
    
}