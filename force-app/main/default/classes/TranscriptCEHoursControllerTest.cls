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
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'OrderApi__Subscription__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);

        insert triggerSettingsList;
        
        List<TriggerSettings__c> triggerSettingsList1 = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj1 = new TriggerSettings__c(Name = 'OrderApi__Renewal__c', TriggerDisabled__c = false);
        triggerSettingsList1.add(triggerSettingsObj1);

        insert triggerSettingsList1;
        
        List<TriggerSettings__c> triggerSettingsList2 = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj2 = new TriggerSettings__c(Name = 'CE_Hours__c', TriggerDisabled__c = false);
        triggerSettingsList2.add(triggerSettingsObj2);

        insert triggerSettingsList2;
        
        List<TriggerSettings__c> triggerSettingsList3 = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj3 = new TriggerSettings__c(Name = 'OrderApi__Sales_Order_Line__c', TriggerDisabled__c = false);
        triggerSettingsList3.add(triggerSettingsObj3);

        insert triggerSettingsList3;
    
        Account accountObj = new Account();
            
            accountObj.Name = 'Test Account';
            accountObj.No_Known_Address__c =true;        
            accountObj.Media_Account_Owner__c=UserInfo.getUserId();
        
        insert accountObj;
        
        Contact newValidContactToInsert = new Contact(
            FirstName = 'Test Valid',
            LastName = 'Contact',
            AccountId = accountObj.Id
        );
        insert newValidContactToInsert;
        
        User testUser = new User(
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
            LocaleSidKey = 'en_US',
            Contact = newValidContactToInsert
        );
        /*insert testUser;*/
        
        
        
        OrderApi__Item_Class__c itmcl = new OrderApi__Item_Class__c();
            itmcl.Name = 'Certification';
        insert itmcl;
        
        SDOC__SDTemplate__c sdoc = new SDOC__SDTemplate__c();
        sdoc.Name = 'Test Certificate';
        sdoc.SDOC__Base_Object__c = 'OrderApi__Subscription__c';
        sdoc.SDOC__Template_Format__c = 'PDF';
        insert sdoc;

        //insert Item
        OrderApi__Item__c itm =new OrderApi__Item__c();
            itm.name='Certification';
            itm.OrderApi__Item_Class__c = itmcl.Id;
        	itm.SDoc_Template__c = sdoc.Id;
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
            sub.OrderApi__Contact__c = testUser.Id;
            sub.OrderApi__Entity__c ='Contact';
            sub.OrderApi__Activated_Date__c = Date.today();
            sub.OrderApi__Paid_Through_Date__c = Date.today().addDays(1);
            sub.OrderApi__Days_To_Lapse__c = 365;
            sub.OrderApi__Enable_Auto_Renew__c = true;
            sub.OrderApi__Item__c = itm.Id;
            sub.OrderApi__status__C = 'Active'; //'Pending';
            sub.OrderApi__Is_Active__c = true;
            sub.Is_Renewal__c = true;
            sub.OrderApi__Grace_Period_End_Date__c = date.today()+2;
        	
        
            lstSub.add(sub);
        insert sub;
        
        OrderApi__Subscription__c sub2 = new OrderApi__Subscription__c();
            sub2.OrderApi__Account__c = accountObj.Id;
            sub2.OrderApi__Contact__c = testUser.Id;
            sub2.OrderApi__Entity__c ='Contact';
            sub2.OrderApi__Activated_Date__c = Date.today();
            sub2.OrderApi__Paid_Through_Date__c = Date.today().addDays(1);
            sub2.OrderApi__Days_To_Lapse__c = 365;
            sub2.OrderApi__Enable_Auto_Renew__c = true;
            sub2.OrderApi__Item__c = itm.Id;
            sub2.OrderApi__status__C = 'Pending';
            sub2.OrderApi__Is_Active__c = true;
        	sub2.Is_Renewal__c = true;
            sub2.OrderApi__Grace_Period_End_Date__c = date.today()+2;
            lstSub.add(sub2);
        insert sub2;
        
        //OrderApi__Sales_Order__c salesOrderObj = TestUtility.createSalesOrder();
       // OrderApi__Sales_Order_Line__c salesOrderLineObj = TestUtility.createSalesOrderLine(salesOrderObj.id);
        
        
        OrderApi__Renewal__c term = new OrderApi__Renewal__c();
            term.OrderApi__Subscription__C = sub.id;
            term.OrderApi__Term_Start_Date__c = date.today();
            term.OrderApi__Term_End_Date__c = date.today();
            term.OrderApi__Grace_Period_End_Date__c = date.today()+2;
        	term.OrderApi__Is_Active__c = true;
            //term.Renewal_SalesOrder__c = salesOrderObj.Id;
        insert term;
        
        List<CE_Hours__c> cl = new List<CE_Hours__c>();
        CE_Hours__c ceho1 = new CE_Hours__c();
        	//ceho1.Legacy_CE_Hours_Id__c = sub.id;
            ceho1.Education_Provider__c = 'NON-HIMSS';
            ceho1.Activity_Type__c = 'Ethics';
            ceho1.Number_Of_Credits__c = 2;
            ceho1.Credit_Date__c = date.today();
            ceho1.Program_Title__c = 'forResfresh';
            ceho1.Term__c = term.Id;
            cl.add(ceho1);
        insert cl;
        
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = sub.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        
        insert attachment;
        
        List<TranscriptCEHoursController.CEHoursWrapper> ceWrapList = new List<TranscriptCEHoursController.CEHoursWrapper>();
        TranscriptCEHoursController.CEHoursWrapper ceWrap = new TranscriptCEHoursController.CEHoursWrapper();
        ceWrap.subscription = sub;
        ceWrap.termId = term.id;
        ceWrap.ceHours = cl;      
        
        Test.startTest();
        User resultUser = TranscriptCEHoursController.getUserInfo();
        List<TranscriptCEHoursController.CEHoursWrapper> ceHours = TranscriptCEHoursController.getData(true);
        system.debug('ceHours'+ceHours);
        String errorMsg = TranscriptCEHoursController.deleteSelectedRecord(ceho1.Id);
        TranscriptCEHoursController.createSalesOrder(accountObj.id,sub);
        TranscriptCEHoursController.processSubscription(sub.Id);
        String jobId = TranscriptCEHoursController.createCertificate(sub.Id);
        String attachmentId = TranscriptCEHoursController.viewCertificate(sub.Id);
        TranscriptCEHoursController.CEHoursEditWrapper ceEditWrapper = TranscriptCEHoursController.editCEHours(sub.Id);
        OrderApi__Renewal__c resultRenewal = TranscriptCEHoursController.getTerm(term.Id);
        
        Test.stopTest();
        
    }
}