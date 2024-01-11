@isTest
public class StandardizeAMSIDContact_Test {
    
    @TestSetup
    public static void setup(){
        TestUtility.createTriggerSettings();
        TestUtility.createAccount();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'Contact', TriggerDisabled__c = False);
        insert triggerSettingsObj;
    }
    
    @isTest
    public static void testAMSIDUpdate(){       
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.Lastname = 'Person';
        c.AccountId = a.id;
        c.AMS_ID__c = '12345';
        insert c;
        
        String amsIdBefore = c.AMS_ID__c;
        Test.StartTest();
        Id batchJobId = Database.executeBatch(new StandardizeAMSCompanyIDs_Contact(), 200);
        Test.StopTest();
        
        Contact cAfter = [SELECT Id, AMS_ID__c FROM Contact WHERE Name = 'Test Person' LIMIT 1];
        
        Assert.areNotEqual(amsIdBefore,cAfter.AMS_ID__c);
        Assert.isTrue(cAfter.AMS_ID__c.length() == 12);
    }
    
    @isTest
    public static void testAMSCIDNoUpdate(){
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.Lastname = 'Person';
        c.AccountId = a.id;
        c.AMS_ID__c = '000000012345';
        insert c;
        
        String amsIdBefore = c.AMS_ID__c;
        Test.StartTest();
        Id batchJobId = Database.executeBatch(new StandardizeAMSCompanyIDs_Contact(), 200);
        Test.StopTest();
        
        Contact cAfter = [SELECT Id, AMS_ID__c FROM Contact WHERE Name = 'Test Person' LIMIT 1];
        
        Assert.areEqual(amsIdBefore,cAfter.AMS_ID__c);
        Assert.isFalse(cAfter.AMS_ID__c.length() != 12);
    }
    
    @isTest
    public static void testAMSContactIDUpdate(){
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.Lastname = 'Person';
        c.AccountId = a.id;
        c.AMS_Contact_ID__c = '12345';
        insert c;
        
        String amsIdBefore = c.AMS_Contact_ID__c;
        Test.StartTest();
        Id batchJobId = Database.executeBatch(new StandardizeAMSCompanyIDs_Contact(), 200);
        Test.StopTest();
        
        Contact cAfter = [SELECT Id, AMS_Contact_ID__c FROM Contact WHERE Name = 'Test Person' LIMIT 1];
        
        Assert.areNotEqual(amsIdBefore,cAfter.AMS_Contact_ID__c);
        Assert.isTrue(cAfter.AMS_Contact_ID__c.length() == 12);
    }
    
    @isTest
    public static void testAMSContactIDNoUpdate(){
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.Lastname = 'Person';
        c.AccountId = a.id;
        c.AMS_Contact_ID__c = '000000012345';
        insert c;
        
        String amsIdBefore = c.AMS_Contact_ID__c;
        Test.StartTest();
        Id batchJobId = Database.executeBatch(new StandardizeAMSCompanyIDs_Contact(), 200);
        Test.StopTest();
        
        Contact cAfter = [SELECT Id, AMS_Contact_ID__c FROM Contact WHERE Name = 'Test Person' LIMIT 1];
        
        Assert.areEqual(amsIdBefore,cAfter.AMS_Contact_ID__c);
        Assert.isFalse(cAfter.AMS_Contact_ID__c.length() != 12);  
    }
    
}