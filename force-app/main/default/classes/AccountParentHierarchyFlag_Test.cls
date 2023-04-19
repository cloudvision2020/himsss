@isTest
public class AccountParentHierarchyFlag_Test {
    
    @isTest
    public static void testParentIsMarked(){
        
        Account newParentAccount = new Account();
        newParentAccount.Name = 'Test Parent Account';
        newParentAccount.No_Known_Address__c = True;
        insert newParentAccount;
        
        Account newChildAccount = new Account();
        newChildAccount.Name = 'Test Child Account';
        newChildAccount.No_Known_Address__c = True;
        newChildAccount.ParentId = newParentAccount.Id;
        insert newChildAccount;
        
        test.startTest();
        AccountParentHierarchyFlag.UpdateParentFlags();
        test.stopTest();
        
        List<Account> parentAccount = [SELECT Id, isParent__c 
                                       FROM Account
                                       WHERE id = :newParentAccount.Id];
        
        system.assert(parentAccount[0].isParent__c == True);
        
    }
    
    @isTest
    public static void testHierarchyIsMarked(){
        
        Account newParentAccount = new Account();
        newParentAccount.Name = 'Test Parent Account';
        newParentAccount.No_Known_Address__c = True;
        insert newParentAccount;
        
        Account newChildAccount = new Account();
        newChildAccount.Name = 'Test Child Account';
        newChildAccount.No_Known_Address__c = True;
        newChildAccount.ParentId = newParentAccount.Id;
        insert newChildAccount;
        
        test.startTest();
        AccountParentHierarchyFlag.UpdateParentFlags();
        AccountParentHierarchyFlag.UpdateChildFlags();
        test.stopTest();
        
        List<Account> parentAccount = [SELECT Id, isParent__c , isHierarchy__c
                                       FROM Account
                                       WHERE id = :newParentAccount.Id];
        
        List<Account> childAccount = [SELECT Id, isParent__c , isHierarchy__c
                                      FROM Account
                                      WHERE parentId = :newParentAccount.Id];
        
        system.assert(parentAccount[0].isParent__c == True);
        system.assert(parentAccount[0].isHierarchy__c == True);
        system.assert(childAccount[0].isParent__c == False);
        system.assert(childAccount[0].isHierarchy__c == True);
    }
    
    
}