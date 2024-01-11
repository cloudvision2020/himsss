@IsTest
public class Fon_SearchAccountCtrl_Test {
    
    @testSetup static void setup() {
        
        OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c(Name = 'Test BG');
        insert bg;
        
        OrderApi__Item_Class__c itmClass = new OrderApi__Item_Class__c();
        itmClass.Name = 'Memberships';
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Assignment_SObject__c = 'TEST__C';
        itmClass.OrderApi__Business_Group__c = bg.Id;
        itmClass.OrderApi__Is_Active__c = true;        
        insert itmClass;
        
        OrderApi__Item_Class__c itmClassDivision = new OrderApi__Item_Class__c();
        itmClassDivision.Name = 'Young Lawyers Division';
        itmClassDivision.OrderApi__Is_Subscription__c = true;
        itmClassDivision.OrderApi__Assignment_SObject__c = 'TEST__C';
        itmClassDivision.OrderApi__Business_Group__c = bg.Id;
        itmClass.OrderApi__Is_Active__c = true;        
        insert itmClassDivision;
        
        OrderApi__Item__c itm = new OrderApi__Item__c(name='Attorney',OrderApi__Is_Subscription__c=true,OrderApi__Business_Group__c=bg.Id,OrderApi__Item_Class__c = itmClass.Id, OrderApi__Is_Active__c = true);
        insert itm;
        
        OrderApi__Item__c itmD = new OrderApi__Item__c(name='Divi',OrderApi__Is_Subscription__c=true,OrderApi__Business_Group__c=bg.Id,OrderApi__Item_Class__c = itmClassDivision.Id, OrderApi__Is_Active__c = true);
        insert itmD;
        
        // query profile
        Id p = '00eP00000013tlF';
        
        // inasert account
        Account ac = new Account(name ='TestUserAcc',Phone = '1234567890',Fax = '1234',Website = 'www.google.com',
                                 BillingPostalCode = '1234',ZI_Website__c = 'https://www.google.com',
                                 BillingStreet = 'No street',BillingCity = 'No City',BillingState = 'Test',
                                 BillingCountry = 'Test',AMS_Company_ID__c = '123456',
                                 OrderApi__Account_Email__c = 'test@testing.com') ;
        insert ac; 
        
        
        // insert contact
        Contact con = new Contact(LastName ='TestUserCon',AccountId = ac.Id,email='test123@noemail.com.fon.test');
        insert con;  
        
        
        
        // insert user
        User user = new User(alias = 'test123', email='test123@noemail.com.fon.test',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='test123@noemail.com.fon.test');
        
        insert user;
        
    }
    
    static testMethod void validate_saveAccount(){
        // getting account 
        Account acc = [SELECT ID FROM Account WHERE Name = 'TestUserAcc'];
        
        // getting contact
        Contact con = [SELECT ID FROM Contact WHERE LastName = 'TestUserCon'];
        
        // getting User
        User usr = [SELECT ID FROM User WHERE UserName = 'test123@noemail.com.fon.test']; 
        system.runAs(usr){
            Test.StartTest();
            ApexPages.currentPage().getParameters().put('id', String.valueOf(acc.Id));
            
            Fon_SearchAccountCtrl fonAcc = new Fon_SearchAccountCtrl();
            fonAcc.saveAccount();
            fonAcc.strCompanyName = 'Test';
            fonAcc.objNewAccount = acc;
            fonAcc.searchAccountByParam();
            fonAcc.createAccountByParam();
            fonAcc.assignSelectedAccount();
            Fon_SearchAccountCtrl.fetchAccountByDomain('test@test.com');
            fonAcc.searchAccountByDomain();
            fonAcc.previousStep();
            fonAcc.cancelStep();
            Test.StopTest();
        }
    }
    
    
    
    
    static testMethod void validate_nextStep(){
        // getting account 
        Account acc = [SELECT ID FROM Account WHERE Name = 'TestUserAcc'];
        
        // getting contact
        Contact con = [SELECT ID FROM Contact WHERE LastName = 'TestUserCon'];
        
        // getting User
        User usr = [SELECT ID FROM User WHERE UserName = 'test123@noemail.com.fon.test']; 
        system.runAs(usr){
            Test.StartTest();
            ApexPages.currentPage().getParameters().put('id', String.valueOf(acc.Id));
            ApexPages.currentPage().getParameters().put('order', String.valueOf(2));
            Fon_SearchAccountCtrl fonAcc = new Fon_SearchAccountCtrl();
            try{
                fonAcc.strSelectedAccId = acc.Id ;
                fonAcc.nextStep(); 
                
                //Fon_SearchAccountCtrl fonAcc = new Fon_SearchAccountCtrl();
                fonAcc.strCompanyName = 'TestUserAcc 2';
                fonAcc.website = 'https://www.google.com';
                fonAcc.phone = '1234567890';
                fonAcc.billingCountry = 'test';
                fonAcc.billingStreet = 'test';
                fonAcc.billingCity = 'test';
                fonAcc.billingState = 'test';
                fonAcc.billingPostalCode = '1234567890';
                fonAcc.saveAccount();
                
            }catch(Exception ex){
            }
            Test.StopTest();
        }
    }
    
}