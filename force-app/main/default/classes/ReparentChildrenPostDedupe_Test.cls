@isTest
public class ReparentChildrenPostDedupe_Test {
    
    @TestSetup
    static void setupData(){
        String sourceAccount = TestUtility.createAccount();
        Account sourceAccountObj = [SELECT id,Name FROM Account WHERE Id = :sourceAccount LIMIT 1];
        sourceAccountObj.Name = 'Source Account';
        update sourceAccountObj;
        
        String winnerAccount = TestUtility.createAccount();
        Account winnerAccountObj = [SELECT id,Name FROM Account WHERE Id = :winnerAccount LIMIT 1];
        winnerAccountObj.Name = 'winner Account';
        update winnerAccountObj;
        
        Campaign testCampaign = new Campaign();
        testCampaign.Name = 'Test Campaign';
        insert testCampaign;
        
        TestUtility.createTriggerSettings();
        Opportunity sourceOpportunity = TestUtility.createOpportunity();
        sourceOpportunity.AccountId = sourceAccount;
        update sourceOpportunity;
        
        Contact sourceContact = new Contact();
        sourceContact.FirstName = 'Test';
        sourceContact.LastName = 'Contact';
        sourceContact.Email = 'Test@test.com';
        sourceContact.AccountId = sourceAccount;
        insert sourceContact;
        
        DeDupe_Record_Back_Up__c winnerAccountBR = new DeDupe_Record_Back_Up__c();
        winnerAccountBR.De_Dupe_Key_Description__c = 'Billing Address';
        winnerAccountBR.De_Dupe_Key_Value__c = '123TestLane';
        winnerAccountBR.Original_Object__c = 'Account';
        winnerAccountBR.Original_Record_Id__c = winnerAccount;
        winnerAccountBR.Winner_ID__c = 'NA';
        winnerAccountBR.Winner_or_Loser__c = 'Winner';
        insert winnerAccountBR;
        
        DeDupe_Record_Back_Up__c loserAccountBR = new DeDupe_Record_Back_Up__c();
        loserAccountBR.De_Dupe_Key_Description__c = 'Billing Address';
        loserAccountBR.De_Dupe_Key_Value__c = '123TestLane';
        loserAccountBR.Original_Object__c = 'Account';
        loserAccountBR.Original_Record_Id__c = sourceAccount;
        loserAccountBR.Winner_ID__c = winnerAccount;
        loserAccountBR.Winner_or_Loser__c = 'Loser';
        insert loserAccountBR;
        
        Contract testContract = new Contract();
        testContract.AccountId = sourceAccount;
        testContract.StartDate = system.today();
        testContract.ContractTerm = 1;
        insert testContract;
    }
    
    @isTest
    static void checkOpportunityisReparented(){
        
        Account winnerAccount = [SELECT Id From Account WHERE Name = 'winner Account'];
        
        DeDupe_Record_Back_Up__c loserAccountBR = [SELECT Original_Record_Id__c, Winner_ID__c 
                                                   FROM DeDupe_Record_Back_Up__c 
                                                   WHERE Winner_or_Loser__c = 'Loser'
                                                   LIMIT 1];
        
        Opportunity beforeReparent = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        system.assert(beforeReparent.AccountId == loserAccountBR.Original_Record_Id__c);
        
        Test.startTest();
        ReparentChildrenPostDedupeBatched ReparentChildrenPostDedupeBatched = new ReparentChildrenPostDedupeBatched(); 
        Id batchId = Database.executeBatch(ReparentChildrenPostDedupeBatched,100); 
        Test.stopTest();
        Opportunity afterReparent = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        system.assertEquals(winnerAccount.id, afterReparent.AccountId);
        
    }
    
    @isTest
    static void checkContactisReparented(){
        
        Account winnerAccount = [SELECT Id From Account WHERE Name = 'winner Account'];
        
        DeDupe_Record_Back_Up__c loserAccountBR = [SELECT Original_Record_Id__c, Winner_ID__c 
                                                   FROM DeDupe_Record_Back_Up__c 
                                                   WHERE Winner_or_Loser__c = 'Loser'
                                                   LIMIT 1];
        
        Contact beforeReparent = [SELECT id, AccountId FROM Contact LIMIT 1];
        system.assert(beforeReparent.AccountId == loserAccountBR.Original_Record_Id__c);
        AccountContactRelation relationShipBeforeReparent = [SELECT id,ContactId,AccountId FROM AccountContactRelation WHERE ContactId = :beforeReparent.id];
        system.assert(relationShipBeforeReparent.accountId == beforeReparent.AccountId);
        
        Test.startTest();
        ReparentChildrenPostDedupeBatched ReparentChildrenPostDedupeBatched = new ReparentChildrenPostDedupeBatched(); 
        Id batchId = Database.executeBatch(ReparentChildrenPostDedupeBatched,100);
        Test.stopTest();
        Contact afterReparent = [SELECT id, AccountId FROM Contact LIMIT 1];
        system.assertEquals(winnerAccount.id, afterReparent.AccountId);
        AccountContactRelation relationShipAfterReparent = [SELECT id,ContactId,AccountId FROM AccountContactRelation WHERE ContactId = :afterReparent.id];
        system.assert(relationShipAfterReparent.accountId == afterReparent.AccountId);
        
    }
    
    
    @isTest
    static void checkContractisReparented(){
        
        Account winnerAccount = [SELECT Id From Account WHERE Name = 'winner Account'];
        
        DeDupe_Record_Back_Up__c loserAccountBR = [SELECT Original_Record_Id__c, Winner_ID__c 
                                                   FROM DeDupe_Record_Back_Up__c 
                                                   WHERE Winner_or_Loser__c = 'Loser'
                                                   LIMIT 1];
        
        Contract beforeReparent = [SELECT Id,AccountID FROM Contract LIMIT 1];
        system.assert(beforeReparent.AccountId == loserAccountBR.Original_Record_Id__c);
        
        Test.startTest();
        ReparentChildrenPostDedupeBatched ReparentChildrenPostDedupeBatched = new ReparentChildrenPostDedupeBatched(); 
        Id batchId = Database.executeBatch(ReparentChildrenPostDedupeBatched,100);
        Test.stopTest();
        
        Contract afterReparent = [SELECT Id,AccountID FROM Contract LIMIT 1];
        system.assertEquals(winnerAccount.id, afterReparent.AccountId);
    }
    
}