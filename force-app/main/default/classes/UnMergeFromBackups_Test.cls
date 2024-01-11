@isTest
public class UnMergeFromBackups_Test {
    
    @TestSetup
    public static void setupData(){
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'Opportunity', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);
        insert triggerSettingsList;
        
        //Create Accounts Winner and Loser
        List<Account> aToInsert = new List<Account>();        
        Account lAccount = new Account();
        lAccount.Name = 'LOSER ACCOUNT';
        lAccount.BillingStreet = '3022  Strother Street';
        lAccount.BillingCity = 'Into';
        lAccount.BillingState = 'Alabama';
        lAccount.BillingPostalCode = '35222';
        lAccount.BillingCountry = 'US';
        aToInsert.add(lAccount);
        
        Account wAccount = new Account();
        wAccount.Name = 'WINNER ACCOUNT';
        wAccount.BillingStreet = '3022  Strother Street';
        wAccount.BillingCity = 'Into';
        wAccount.BillingState = 'Alabama';
        wAccount.BillingPostalCode = '35222';
        wAccount.BillingCountry = 'US';
        aToInsert.add(wAccount);
        
        insert aToInsert;
        
        //Create Contacts under Winner
        List<Contact> cToInsert = new List<Contact>();
        Contact c1 = new Contact();
        c1.FirstName = 'Contact';
        c1.LastName = '1';
        c1.AccountId = wAccount.Id;
        cToInsert.add(c1);
        
        Contact c2 = new Contact();
        c2.FirstName = 'Contact';
        c2.LastName = '2';
        c2.AccountId = wAccount.Id;
        cToInsert.add(c2);
        
        Contact c3 = new Contact();
        c3.FirstName = 'Contact';
        c3.LastName = '3';
        c3.AccountId = wAccount.Id;
        cToInsert.add(c3);
        
        insert cToInsert;
        
        //Create Opportunities under Winner
        List<Opportunity> oToInsert = new List<Opportunity>();
        
        Opportunity o1 = new Opportunity();
        o1.Name = 'Opportunity-1';
        o1.AccountId  = wAccount.Id;
        o1.StageName = 'Proposal';
        o1.CloseDate = System.today();
        oToInsert.add(o1);
        
        Opportunity o2 = new Opportunity();
        o2.Name = 'Opportunity-2';
        o2.AccountId  = wAccount.Id;
        o2.StageName = 'Proposal';
        o2.CloseDate = System.today();
        oToInsert.add(o2);
        
        Opportunity o3 = new Opportunity();
        o3.Name = 'Opportunity-3';
        o3.AccountId  = wAccount.Id;
        o3.StageName = 'Proposal';
        o3.CloseDate = System.today();
        oToInsert.add(o3);
        
        insert oToInsert;
        
        //Create DeDupe Backup Records Winner and Loser
        List<DeDupe_Record_Back_Up__c> dbrToInsert = new List<DeDupe_Record_Back_Up__c>();
        DeDupe_Record_Back_Up__c lDbr = new DeDupe_Record_Back_Up__c();
        lDbr.Original_Object__c = 'Account';
        lDbr.Winner_or_Loser__c = 'Loser';
        lDbr.De_Dupe_Key_Description__c = 'Name';
        lDbr.De_Dupe_Key_Value__c = 'Test';
        //lDbr.Re_Parented_Contacts__c = c1.Name + ', ' + c2.Name + ', ' + c3.Name;
        //system.debug('lDbr.Re_Parented_Contacts__c ==> ' + lDbr.Re_Parented_Contacts__c);
        lDbr.Re_Parented_Contacts__c = c1.FirstName+' '+c1.LastName+', '+c2.FirstName+' '+c2.LastName+', '+c3.FirstName+' '+c3.LastName;
        system.debug('lDbr.Re_Parented_Contacts__c ==> ' + lDbr.Re_Parented_Contacts__c);
        lDbr.Re_Parented_Opportunities__c = o1.Name + ', ' + o2.Name + ', ' + o3.Name;
        lDbr.Original_Record_Id__c = Id.valueOf(lAccount.Id);
        lDbr.Winner_ID__c = Id.valueOf(wAccount.Id);
        dbrToInsert.add(lDbr);
        
        DeDupe_Record_Back_Up__c wDbr = new DeDupe_Record_Back_Up__c();
        wDbr.Original_Object__c = 'Account';
        wDbr.Winner_or_Loser__c = 'Winner';
        wDbr.De_Dupe_Key_Description__c = 'Name';
        wDbr.De_Dupe_Key_Value__c = 'Test';
        wDbr.Re_Parented_Contacts__c = '';
        wDbr.Re_Parented_Opportunities__c = '';
        wDbr.Original_Record_Id__c = Id.valueOf(wAccount.Id);
        wDbr.Winner_ID__c = 'N/A';
        dbrToInsert.add(wDbr);
        
        insert dbrToInsert;
    }
    
    @IsTest
    public static void testOpportunityReparent(){
        
        List<Opportunity> oppsBeforeReParent = [SELECT id, Account.Name, AccountId FROM Opportunity];
        Assert.areEqual('WINNER ACCOUNT', oppsBeforeReParent[0].Account.Name);
        Assert.areEqual('WINNER ACCOUNT', oppsBeforeReParent[1].Account.Name);
        Assert.areEqual('WINNER ACCOUNT', oppsBeforeReParent[2].Account.Name);
        
        Test.startTest();
        //UnMergeFromBackups.reverseReparentingOpportunities();
        UnMergeFromBackupsBatched batch = new UnMergeFromBackupsBatched(); 
        Id batchId = Database.executeBatch(batch,100);
        Test.stopTest();
        
        List<Opportunity> oppsAfterReParent = [SELECT id, Account.Name, AccountId FROM Opportunity];
        //Assert.areEqual('LOSER ACCOUNT', oppsAfterReParent[0].Account.Name);
        //Assert.areEqual('LOSER ACCOUNT', oppsAfterReParent[1].Account.Name);
        //Assert.areEqual('LOSER ACCOUNT', oppsAfterReParent[2].Account.Name);

        
        
        
    }
    
    @IsTest
    public static void testContactReparent(){
        List<Contact> contsBeforeReParent = [SELECT id, Account.Name, AccountId FROM Contact];
        Assert.areEqual('WINNER ACCOUNT', contsBeforeReParent[0].Account.Name);
        Assert.areEqual('WINNER ACCOUNT', contsBeforeReParent[1].Account.Name);
        Assert.areEqual('WINNER ACCOUNT', contsBeforeReParent[2].Account.Name);
        
        Test.startTest();
        //UnMergeFromBackups.reverseReparentingContacts();
        UnMergeFromBackupsBatched batch = new UnMergeFromBackupsBatched(); 
        Id batchId = Database.executeBatch(batch,100);
        Test.stopTest();
        
        List<Contact> contsAfterReParent = [SELECT id, Account.Name, AccountId FROM Contact];
        Assert.areEqual('LOSER ACCOUNT', contsAfterReParent[0].Account.Name);
        Assert.areEqual('LOSER ACCOUNT', contsAfterReParent[1].Account.Name);
        Assert.areEqual('LOSER ACCOUNT', contsAfterReParent[2].Account.Name);
        
    }
   
    @isTest
    public static void checkNonReparentedOpps(){
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'WINNER ACCOUNT'];
        Opportunity o = new Opportunity();
        o.Name = 'DO NOT REPARENT';
        o.AccountId  = a.Id;
        o.StageName = 'Proposal';
        o.CloseDate = System.today();
        insert o;
        
        List<Opportunity> oppsBeforeReParent = [SELECT id, Account.Name,Name, AccountId FROM Opportunity];
        for(Opportunity op : oppsBeforeReParent){
            if(op.Name != 'DO NOT REPARENT'){
              Assert.areEqual('WINNER ACCOUNT', op.Account.Name);  
            }else{
              Assert.areEqual('WINNER ACCOUNT', op.Account.Name); 
            }
        }
        
        Test.startTest();
        //UnMergeFromBackups.reverseReparentingOpportunities();
        UnMergeFromBackupsBatched batch = new UnMergeFromBackupsBatched(); 
        Id batchId = Database.executeBatch(batch,100);
        Test.stopTest();
        
        List<Opportunity> oppsAfterReParent = [SELECT id, Account.Name,Name, AccountId FROM Opportunity];
        for(Opportunity op : oppsAfterReParent){
            if(op.Name != 'DO NOT REPARENT'){
              //Assert.areEqual('LOSER ACCOUNT', op.Account.Name);  
            }else{
              //Assert.areEqual('WINNER ACCOUNT', op.Account.Name); 
            }
        }    
    }
    
    @isTest
    public static void checkNonReparentedContacts(){
        
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'WINNER ACCOUNT'];
        Contact c = new Contact();
        c.FirstName = 'DONOT';
        c.LastName = 'Reparent';
        c.AccountId  = a.Id;
        insert c;
        
        List<Contact> contsBeforeReParent = [SELECT id, Account.Name,Name,FirstName,LastName,AccountId FROM Contact];
        for(Contact co : contsBeforeReParent){
            if(co.FirstName + ' ' + co.LastName != 'DONOT REPARENT'){
              Assert.areEqual('WINNER ACCOUNT', co.Account.Name);  
            }else{
              Assert.areEqual('WINNER ACCOUNT', co.Account.Name); 
            }
        }
        
        Test.startTest();
        //UnMergeFromBackups.reverseReparentingContacts();
        UnMergeFromBackupsBatched batch = new UnMergeFromBackupsBatched(); 
        Id batchId = Database.executeBatch(batch,100);
        Test.stopTest();
        
        List<Contact> contAfterReParent = [SELECT id, Account.Name,Name,FirstName,LastName,AccountId FROM Contact];
        for(Contact co : contAfterReParent){
            if(co.FirstName + ' ' + co.LastName != 'DONOT REPARENT'){
              Assert.areEqual('LOSER ACCOUNT', co.Account.Name);  
            }else{
              Assert.areEqual('WINNER ACCOUNT', co.Account.Name); 
            }
        }
    }
}