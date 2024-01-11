@isTest
global class CustomerPortalUserCreationEndpoints_Test{
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
        
    }
    
    /*
    @isTest
    public static void testPostCallout(){
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        // Create a fake request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('/services/apexrest/portalUser/');
        request.setBody('{"FirstNameString" : "KT-User3_TEST","LastNameString" : "EndPoint_TEST","EmailString" : "testUser3@test.com.TEST"}');        
        request.setMethod('POST');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        Test.StopTest();
        
        List<User> u = [SELECT ID FROM User WHERE email = 'testUser3@test.com.TEST'];
        
        Assert.areEqual(200, response.getStatusCode());
    }
*/
    
    @isTest
    public static void testPortalUserCreation(){
        TestUtility.createTriggerSettings();        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'Contact', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);
        insert triggerSettingsList;
        
        String firstNameString, lastNameString, email;
        firstNameString = 'User_TEST';
        lastNameString = 'EndPoint_TEST';
        email = 'User_TEST@test.com.test';
        String accountNameExpected = firstNameString + ' ' + lastNameString;
        
        List<User> uBefore = [SELECT ID FROM User WHERE email = 'User_TEST@test.com.test'];
        List<Contact> cBefore = [SELECT ID, firstName FROM Contact WHERE firstName = :firstNameString];
        List<Account> aBefore = [SELECT ID, Name FROM Account WHERE Name = :accountNameExpected];
        
        Test.startTest();
        CustomerPortalUserCreationEndpoints.createCustomerPortalUser(firstNameString,lastNameString,email,TRUE);
        
        List<User> uAfter = [SELECT ID, FirstName, LastName, Email, ContactId, isActive FROM User WHERE email = 'User_TEST@test.com.test'];
        List<Contact> cAfter = [SELECT ID, firstName FROM Contact WHERE firstName = :firstNameString];
        List<Account> aAfter = [SELECT ID, Name FROM Account WHERE Name = :accountNameExpected];
        
        Assert.areEqual(TRUE, uBefore.isEmpty());
        Assert.areEqual(TRUE, cBefore.isEmpty());
        Assert.areEqual(TRUE, aBefore.isEmpty());
        
        Assert.areEqual(FALSE, uAfter.isEmpty());
        Assert.areEqual(FALSE, cAfter.isEmpty());
        Assert.areEqual(FALSE, aAfter.isEmpty());
        
        //String returnjson = CustomerPortalUserCreationEndpoints.createCustomerPortalUser(firstNameString,lastNameString,email,FALSE);
        CustomerPortalUserCreationEndpoints.createCustomerPortalUser(firstNameString,lastNameString,email,FALSE);
        //Assert.isNotNull(returnjson);
        Test.stopTest();
    }
    
    @isTest
    public static void testPortalUserReturn(){
        TestUtility.createTriggerSettings();        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'Contact', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);
        insert triggerSettingsList;
        
        String firstNameString, lastNameString, email;
        firstNameString = 'User_TEST';
        lastNameString = 'EndPoint_TEST';
        email = 'User_TEST@test.com.test';
        String accountNameExpected = firstNameString + ' ' + lastNameString;
        
        List<User> uBefore = [SELECT ID FROM User WHERE email = 'User_TEST@test.com.test'];
        List<Contact> cBefore = [SELECT ID, firstName FROM Contact WHERE firstName = :firstNameString];
        List<Account> aBefore = [SELECT ID, Name FROM Account WHERE Name = :accountNameExpected];
        
        CustomerPortalUserCreationEndpoints.createCustomerPortalUser(firstNameString,lastNameString,email,TRUE);
        
        List<User> uAfter = [SELECT ID, FirstName, LastName, Email, ContactId, isActive FROM User WHERE email = 'User_TEST@test.com.test'];
        List<Contact> cAfter = [SELECT ID, firstName FROM Contact WHERE firstName = :firstNameString];
        List<Account> aAfter = [SELECT ID, Name FROM Account WHERE Name = :accountNameExpected];
        
        Assert.areEqual(TRUE, uBefore.isEmpty());
        Assert.areEqual(TRUE, cBefore.isEmpty());
        Assert.areEqual(TRUE, aBefore.isEmpty());
        
        Assert.areEqual(FALSE, uAfter.isEmpty());
        Assert.areEqual(FALSE, cAfter.isEmpty());
        Assert.areEqual(FALSE, aAfter.isEmpty());
        
        //String returnjson = CustomerPortalUserCreationEndpoints.createCustomerPortalUser(firstNameString,lastNameString,email,FALSE);
        //Assert.isNotNull(returnjson);
        
        Test.startTest();
        //User u = (User)JSON.deserialize(CustomerPortalUserCreationEndpoints.createCustomerPortalUser(firstNameString,lastNameString,email,False), User.Class);
        //Test.stopTest();
        //Assert.areEqual(uAfter[0].id, u.id);      
    }
    
}