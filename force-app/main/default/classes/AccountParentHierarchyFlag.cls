public class AccountParentHierarchyFlag {
      
    public static void UpdateParentFlags(){
        
        AggregateResult[] parentAccountsAgg = [SELECT COUNT(Id),ParentId,Parent.Name
                                               FROM Account
                                               GROUP BY ParentId, Parent.Name];
        
        //create a list to store the parent Account ID's
        List<Id> parentAccountIDs = new List<Id>();
        
        for(AggregateResult a : parentAccountsAgg){
            if(a.get('parentId') == NULL){
                system.debug('NULL ID');
            }else{
                parentAccountIDs.add((Id) a.get('parentId'));
            }
        }
        
        List<Account> parentAccounts = [SELECT id,isHierarchy__c,isParent__c FROM Account WHERE Id IN :parentAccountIDs];
        List<Account> toUpdate = new List<Account>();
        
        for(Account a : parentAccounts){
            if(a.isHierarchy__c != True || a.isParent__c != True ){
                a.isHierarchy__c = True;
                a.isParent__c = True;
                toUpdate.add(a);
            }
        }
        
        update toUpdate;   
    }
    
    public static void UpdateChildFlags(){
        
        List<Account> childAccounts = [SELECT id,isHierarchy__c,isParent__c FROM Account WHERE ParentId != NULL];
        List<Account> toUpdate = new List<Account>();
        
        for(Account a : childAccounts){
            if(a.isHierarchy__c != True){
                a.isHierarchy__c = True;
                toUpdate.add(a);
            }
        }
        
        update toUpdate;  
    }
}