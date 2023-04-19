@isTest
public class WinnerIdTaggingForDeDupe_Test {
    
    @TestSetup
    static void setupData(){
        
        List<DeDupe_Record_Back_Up__c> backUpRecords = new List<DeDupe_Record_Back_Up__c>();
        
        DeDupe_Record_Back_Up__c br1Winner = new DeDupe_Record_Back_Up__c();
        br1Winner.De_Dupe_Key_Description__c = 'First Name + Last Name + Email';
        br1Winner.De_Dupe_Key_Value__c = 'TestNameTest.Name@gmail.com';
        br1Winner.Original_Object__c = 'Contact';
        br1Winner.Original_Record_Id__c = 'WinnerId1234567890';
        br1Winner.Winner_ID__c = 'NA';
        br1Winner.Winner_or_Loser__c = 'Winner';
        backUpRecords.add(br1Winner);
        
        DeDupe_Record_Back_Up__c br1Loser = new DeDupe_Record_Back_Up__c();
        br1Loser.De_Dupe_Key_Description__c = 'First Name + Last Name + Email';
        br1Loser.De_Dupe_Key_Value__c = 'TestNameTest.Name@gmail.com';
        br1Loser.Original_Object__c = 'Contact';
        br1Loser.Original_Record_Id__c = 'LoserId1234567890';
        br1Loser.Winner_or_Loser__c = 'Loser';
        backUpRecords.add(br1Loser);
        
        insert backUpRecords;
        
    }
    
    @isTest
    static void checkLosergetsWinnerId(){
        
        List<DeDupe_Record_Back_Up__c> beforeWinnerIdTagging = [Select Id, Winner_ID__c,Winner_or_Loser__c 
                                                                FROM DeDupe_Record_Back_Up__c
                                                                WHERE Winner_or_Loser__c = 'Loser'];
        
        System.assert(beforeWinnerIdTagging[0].Winner_ID__c == Null);
        
        Test.startTest();
        WinnerIdTaggingForDeDupe.setWinnerIds();
        Test.stopTest();
        
        List<DeDupe_Record_Back_Up__c> afterWinnerIdTagging = [Select Id, Winner_ID__c,Winner_or_Loser__c 
                                                               FROM DeDupe_Record_Back_Up__c
                                                               WHERE Winner_or_Loser__c = 'Loser'];
        
        System.assert(afterWinnerIdTagging[0].Winner_ID__c == 'WinnerId1234567890');
        
    }
    
    @isTest
    static void checkWinnerDoesntGetId(){
        
        List<DeDupe_Record_Back_Up__c> beforeWinnerIdTagging = [Select Id, Winner_ID__c,Winner_or_Loser__c 
                                                                FROM DeDupe_Record_Back_Up__c
                                                                WHERE Winner_or_Loser__c = 'Winner'];
        
        System.assert(beforeWinnerIdTagging[0].Winner_ID__c == 'NA');
        
        Test.startTest();
        WinnerIdTaggingForDeDupe.setWinnerIds();
        Test.stopTest();
        
        List<DeDupe_Record_Back_Up__c> afterWinnerIdTagging = [Select Id, Winner_ID__c,Winner_or_Loser__c 
                                                               FROM DeDupe_Record_Back_Up__c
                                                               WHERE Winner_or_Loser__c = 'Winner'];
        
        System.assert(afterWinnerIdTagging[0].Winner_ID__c == 'NA');
        
    }
    
}