@isTest
public class ContactCommunityTriggerHandler_Test {
    @IsTest 
    static void testcommunitygroupmember(){
        string accountid = TestUtility.createAccount();
        Contact conObj = TestUtility.createContactRecord(accountid);
        conObj.International_Professional_Community__c='DACH Community';
        insert conObj;
        conObj.International_Professional_Community__c='Dutch Community';
       update conObj;
      
        
    }
}