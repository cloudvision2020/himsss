@isTest
public class TranscriptCEHoursControllerTest {
    
    @isTest 
        public static void testFetchCEHoursActive() {
        Test.startTest();
        List<TranscriptCEHoursController.CEHoursWrapper> ceHours = TranscriptCEHoursController.fetchCEHoursActive(true);
        Test.stopTest();
    }
    
    @isTest
        public static void testFetchCEHoursInActive() {
        Test.startTest();
        List<TranscriptCEHoursController.CEHoursWrapper> ceHours = TranscriptCEHoursController.fetchCEHoursInActive(false);
        Test.stopTest();    
	}
    
	@isTest
    public static void testTranscriptCEHoursController(){
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'CE_Hours__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);

        insert triggerSettingsList;
    
    	Account accountObj = new Account();
        	
        	accountObj.Name = 'Test Account';
        	accountObj.No_Known_Address__c =true;        
        	accountObj.Media_Account_Owner__c=UserInfo.getUserId();
        
        insert accountObj;
        
      /*  User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Fonteva System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert testUser;*/
        
        Contact newValidContactToInsert = new Contact(
            FirstName = 'Test Valid',
            LastName = 'Contact',
            AccountId = accountObj.Id
        );
        insert newValidContactToInsert;
        
        OrderApi__Item_Class__c itmcl = new OrderApi__Item_Class__c();
        	itmcl.Name = 'Certification';
        insert itmcl;

        //insert Item
        OrderApi__Item__c itm =new OrderApi__Item__c();
        	itm.name='Certification';
        	itm.OrderApi__Item_Class__c = itmcl.Id;
        insert itm;
        
        Set<OrderApi__Subscription__c> lstSub = new Set<OrderApi__Subscription__c>();
        //insert Subscriptions
        OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
        	sub.Active_Term_Non_Approved_CE_Hours__c = 2;
        	sub.Active_Term_CE_Hours__c = 1;
        	sub.Active_Term_Approved_HIMSS_CE_Hours__c = 2;
        	sub.No__c = 1;
        	sub.FON_Override_Submit_Logic__c = true;
            sub.OrderApi__Account__c = accountObj.Id;
            sub.OrderApi__Contact__c = newValidContactToInsert.Id;
            sub.OrderApi__Entity__c ='Contact';
            sub.OrderApi__Activated_Date__c = Date.today();
            sub.OrderApi__Paid_Through_Date__c = Date.today().addDays(1);
            sub.OrderApi__Days_To_Lapse__c = 365;
            sub.OrderApi__Enable_Auto_Renew__c = true;
            sub.OrderApi__Item__c = itm.Id;
            sub.OrderApi__status__C = 'Active'; //'Pending';
        	sub.OrderApi__Is_Active__c = true;
        	lstSub.add(sub);
		insert sub;
        
        OrderApi__Subscription__c sub2 = new OrderApi__Subscription__c();
            sub2.OrderApi__Account__c = accountObj.Id;
            sub2.OrderApi__Contact__c = newValidContactToInsert.Id;
            sub2.OrderApi__Entity__c ='Contact';
            sub2.OrderApi__Activated_Date__c = Date.today();
            sub2.OrderApi__Paid_Through_Date__c = Date.today().addDays(1);
            sub2.OrderApi__Days_To_Lapse__c = 365;
            sub2.OrderApi__Enable_Auto_Renew__c = true;
            sub2.OrderApi__Item__c = itm.Id;
            sub2.OrderApi__status__C = 'Pending';
        	sub2.OrderApi__Is_Active__c = true;
        	lstSub.add(sub2);
		insert sub2;
        
        
        OrderApi__Renewal__c term = new OrderApi__Renewal__c();
        	term.OrderApi__Subscription__C = sub.id;
        	
        insert term;
        
        List<CE_Hours__c> cl = new List<CE_Hours__c>();
        CE_Hours__c ceho1 = new CE_Hours__c();
            ceho1.Education_Provider__c = 'NON-HIMSS';
            ceho1.Activity_Type__c = 'Ethics';
            ceho1.Number_Of_Credits__c = 2;
            ceho1.Credit_Date__c = date.today();
            ceho1.Program_Title__c = 'forResfresh';
            ceho1.Term__c = term.Id;
        	cl.add(ceho1);
        insert cl;
        
        List<TranscriptCEHoursController.CEHoursWrapper> ceWrapList = new List<TranscriptCEHoursController.CEHoursWrapper>();
        TranscriptCEHoursController.CEHoursWrapper ceWrap = new TranscriptCEHoursController.CEHoursWrapper();
        ceWrap.subscription = sub;
        ceWrap.termId = term.id;
		ceWrap.ceHours = cl;      
        
        Test.startTest();
        List<TranscriptCEHoursController.CEHoursWrapper> ceHours = TranscriptCEHoursController.getData(true);
        system.debug('ceHours'+ceHours);
        String errorMsg = TranscriptCEHoursController.deleteSelectedRecord(ceho1.Id);
        TranscriptCEHoursController.createSalesOrder(accountObj.id,sub);
        TranscriptCEHoursController.processSubscription(sub.Id);
        Test.stopTest();
        
    }
    
        
}