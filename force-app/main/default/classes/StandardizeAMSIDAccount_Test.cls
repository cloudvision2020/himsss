@isTest
public class StandardizeAMSIDAccount_Test {
    
    @TestSetup
    public static void setup(){
        TestUtility.createTriggerSettings();
        TestUtility.createAccount();
    }
	
    @isTest
    public static void testAMSCompanyIDUpdate(){
        Account a = [SELECT Id,AMS_Company_ID__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        a.AMS_Company_ID__c = '0123456789';        
        update a;
        
        String amsBefore = a.AMS_Company_ID__c;
        
        Test.StartTest();
        Id batchJobId = Database.executeBatch(new StandardizeAMSCompanyIDs_Account(), 200);
        Test.StopTest();
        
        Account aAfter = [SELECT Id,AMS_Company_ID__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        String amsAfter = aAfter.AMS_Company_ID__c;
        
        Assert.areNotEqual(amsBefore,amsAfter);
        Assert.isTrue(amsAfter.length() == 12);
        
    }
    
    @isTest
    public static void testAMSCompanyIDNoUpdate(){
        Account a = [SELECT Id,AMS_Company_ID__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        a.AMS_Company_ID__c = '000123456789';        
        update a;
        
        String amsBefore = a.AMS_Company_ID__c;
        
        Test.StartTest();
        Id batchJobId = Database.executeBatch(new StandardizeAMSCompanyIDs_Account(), 200);
        Test.StopTest();
        
        Account aAfter = [SELECT Id,AMS_Company_ID__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        String amsAfter = aAfter.AMS_Company_ID__c;
        
        Assert.areEqual(amsBefore,amsAfter);
        Assert.isFalse(amsAfter.length() != 12); 
    }
}