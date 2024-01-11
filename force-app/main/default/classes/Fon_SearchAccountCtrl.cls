/**************************************************************************************************************************************************************************************************************************************************************
Name            :-  Fon_SearchAccountCtrl
Created Date    :-  12-06-2023
Created By      :-  Vikas Rajput
Dependencies    :-  Fon_SearchAccount (VF Page)
Description     :-  Custom Controller will be used to search and create account
**************************************************************************************************************************************************************************************************************************************************************/



public without sharing class Fon_SearchAccountCtrl extends PagesApi.DefaultTemplateController {
    public Account objTempAccount{get;set;}
    public String strSelectedAccId{get;set;}
    public List<Fon_SearchAccountWrapper> lstAccWrapper{get;set;}
    public String strTempName{get;set;}
    public Account objNewAccount{get;set;}
    public boolean isNotFound{get; Set;}
    public string errorMessage {get; set;}
    public Boolean isError {get; set;}
    public User usr { get; set; }
    public Contact con { get; set; }
	
	public String strCompanyName{get;set;}
    public String website{get;set;}
    public String phone{get;set;}
    public String billingCountry{get;set;}
    public String billingStreet{get;set;}
    public String billingCity{get;set;}
    public String billingState{get;set;}
    public String billingPostalCode{get;set;}
    
    public Fon_SearchAccountCtrl(){
        isNotFound = false;
        isError = false;
        objTempAccount = new Account();
        objNewAccount = new Account();
        lstAccWrapper = new List<Fon_SearchAccountWrapper>();
        //lstAccWrapper = Fon_SearchAccountWrapper.fetchAccountWrapper(lstAccount);
    }
    
    public PageReference previousStep() {
        String stepId = Framework.PageUtils.getParam('id');
        if(!Test.isRunningTest()){
            joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
            return new PageReference(joinUtil.getPreviousStep('{}'));
            //return new PageReference(joinUtil.navStepsMap.get('Previous'));
        }
        return null;
    }
    
    public PageReference cancelStep() {
        String stepId = Framework.PageUtils.getParam('id');
        if(String.isBlank(stepId)){
            return null;
        }
        joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);        
        if(joinUtil.navStepsMap.get('First') == null){
            return null;
        }
        return new PageReference(joinUtil.navStepsMap.get('First'));
    }

    public PageReference nextStep() {
        isError = false;
        system.debug('***nextStep***');
        system.debug('this.strSelectedAccId : '+this.strSelectedAccId);
        if(!String.isBlank(this.strSelectedAccId) || this.strSelectedAccId != null){
            
            Id uId = UserInfo.getUserId();
            usr = [SELECT ContactId FROM User WHERE Id =: uID LIMIT 1];
            con = [SELECT Id, AccountId, Name FROM Contact WHERE Id =: usr.ContactId LIMIT 1];
            //con = [SELECT Id, AccountId, Name FROM Contact WHERE Id ='003P000001dZ0FzIAK' LIMIT 1];
            Id conid = con.id;
            
            Account acc = new Account();
            acc.id = con.AccountId;
            acc.OrderApi__Primary_Contact__c = null;
            
            Contact contactUpdate = new Contact(Id = con.Id);
            contactUpdate.AccountId = this.strSelectedAccId;
            //contactUpdate.AccountId = '001P000001uaVv4IAE';
            system.debug('***contactUpdate : '+contactUpdate);
            
             
            try{
            	update contactUpdate; 
                update acc;
            }
            catch(exception ex){
                System.debug('Message: ' + ex.getMessage());
                System.debug('Cause: ' + ex.getCause());
                System.debug('Line number: ' + ex.getLineNumber());
                System.debug('Stack trace: ' + ex.getStackTraceString());
                errorMessage = 'Oops! Something went wrong, please contact your administrator.';
                isError = true;
            }
        }
        
        System.debug('isError : '+isError);
        if(!isError){
            
            String stepId = Framework.PageUtils.getParam('id');
            String redirectURL = '';
            if(!Test.isRunningTest()){
                    joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
                    redirectURL = joinUtil.navStepsMap.get('Next');
                    //==========================JSONGenerator Code==================//
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeStringField('stepId', stepId);
                    gen.writeStringField('redirectURL', redirectURL);
                    gen.writeEndObject();
                    system.debug('gen.getAsString : '+gen.getAsString());
                    joinUtil.setRedirectURLCookie(gen.getAsString());
                    //==========================JSONGenerator Code==================//
            }else{
                redirectURL = 'https://www.google.com/';
            }    
            return new PageReference(redirectURL);
        }
        return null;
        
    }
    
    public List<Account> fetchAccount(String strName, String strCountry){
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Account') ;
        Schema.DescribeSObjectResult cfrSchema = s.getDescribe() ;
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = RecordTypeInfo.get('Organization').getRecordTypeId();
        Id vtId = RecordTypeInfo.get('Vendor').getRecordTypeId();
        Id ptId = RecordTypeInfo.get('Provider').getRecordTypeId();
        system.debug('rtId : '+rtId);
        
        List<Account> lstAccount = [SELECT Id,Name,BillingStreet,
                                        BillingCity,BillingState,BillingCountry,BillingPostalCode  
                                    FROM Account 
                                    WHERE Name LIKE :'%'+strName+'%' AND (RecordTypeId =: rtId OR RecordTypeId =: vtId OR RecordTypeId =: ptId) ];
        return lstAccount;
    }
    
    public PageReference assignSelectedAccount() {
        //this.strSelectedAccId = strAccId;
        System.debug('==============this.strSelectedAccId==============='+this.strSelectedAccId);
        return null;
    }
    
    public boolean searchAccountByParam() {
        this.isNotFound = false;
        this.lstAccWrapper = new List<Fon_SearchAccountWrapper>();
        System.debug('==============strCompanyName=============='+strCompanyName);
        System.debug('==============objTempAccount=============='+objTempAccount.BillingCountry);
        if(String.isBlank(strCompanyName)){
            
            return null;
        }
        List<Account> lstAccount = fetchAccount(strCompanyName, objTempAccount.BillingCountry);
        this.lstAccWrapper = Fon_SearchAccountWrapper.fetchAccountWrapper(lstAccount);
        System.debug('==============lstAccount=============='+lstAccount);
        System.debug('==============this.lstAccWrapper=============='+this.lstAccWrapper);
        if(lstAccount.Size() ==0){
            this.isNotFound = true;
        }
        return null;
    }
    
    public PageReference createAccountByParam() {
        system.debug('***PageReference createAccountByParam***');
        String id = Framework.PageUtils.getParam('id');
        PageReference pageRef = new PageReference('/apex/Fon_CreateAccount?id='+id+'&order=2');
        pageRef.setRedirect(true);
        //redirectPage.getParameters().put('id',controller.getId());
        return pageRef;
        
    }
    
    public pageReference saveAccount(){
        system.debug('***saveAccount***');
        errorMessage = '';
        isError = false;
        
        // code for validation
        if(string.isBlank(strCompanyName)){
            errorMessage += 'Company name can not be blank <br/>';
            isError = true;
        }
        
        if(string.isBlank(website)){
            errorMessage += 'Website can not be blank <br/>';
            isError = true;
        }
        else{
            try
            {
                URL urltest = new URL(website);
                system.debug('url : '+urltest);
            }
            catch(System.StringException e)
            {
                System.debug(e.getMessage());
                errorMessage += 'Please enter valid url, ex. https://www.sample.com. <br/>';
            	isError = true;
                //throw new CustomException(e.getMessage());
            }
        }
        if(string.isBlank(phone)){
            errorMessage += 'Phone can not be blank <br/>';
            isError = true;
        }
        if(string.isBlank(billingCountry)){
            errorMessage += 'Country can not be blank <br/>';
            isError = true;
        }
        if(string.isBlank(billingStreet)){
            errorMessage += 'Street can not be blank <br/>';
            isError = true;
        }
        
        if(string.isBlank(billingCity)){
            errorMessage += 'City can not be blank <br/>';
            isError = true;
        }
        if(string.isBlank(billingState)){
            errorMessage += 'State can not be blank <br/>';
            isError = true;
        }
        if(string.isBlank(billingPostalCode)){
            errorMessage += 'Postalcode can not be blank <br/>';
            isError = true;
        }
        
        
        // checking if all validation passes then created accounts
        if(!isError){
            Id uId = UserInfo.getUserId();
            usr = [SELECT ContactId FROM User WHERE Id =: uID LIMIT 1];
            con = [SELECT Id, AccountId, Name FROM Contact WHERE Id =: usr.ContactId LIMIT 1];
            //con = [SELECT Id, AccountId, Name FROM Contact WHERE Id ='003P000001dZ0FzIAK' LIMIT 1];
            Id conid = con.id;
            
            User activeSystemAdminUser = [SELECT Id,IsActive FROM User WHERE IsActive = true AND Profile.Name='System Administrator' LIMIT 1];
            Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
            Schema.SObjectType s = m.get('Account') ;
            Schema.DescribeSObjectResult cfrSchema = s.getDescribe() ;
            Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
            Id rtId = RecordTypeInfo.get('Organization').getRecordTypeId();
            system.debug('rtId : '+rtId);
            
            Account acc = new account();
            acc.RecordTypeId = rtId;
            acc.Name = strCompanyName;
            //acc.ownerId = '005P000000C3RtXIAV';
            //acc.Name = objNewAccount.Name;
            acc.Website = website;
            acc.Phone = phone;
            acc.ownerId = activeSystemAdminUser.Id;
            acc.BillingStreet = billingStreet;
            acc.BillingCity = billingCity;
            acc.BillingState = billingState;
            acc.BillingPostalCode = billingPostalCode;
            acc.BillingCountry = billingCountry;
                        
            try{
                String stepId = Framework.PageUtils.getParam('id');
            	String orderId = Framework.PageUtils.getParam('order');
            	system.debug('stepId : '+stepId);
            	system.debug('orderId : '+orderId);
                
                if(string.isBlank(orderId)){
                    errorMessage = 'Oops! something went wrong, please contact your administrator';
                    system.debug('errorMessage : '+errorMessage);
                    isError = true;
                    return null;
                }
                system.debug('***acc : '+acc);
                insert acc;              
                
                Contact contactUpdate =  new Contact(Id = con.Id);
                contactUpdate.AccountId = acc.Id;
                contactUpdate.MailingStreet = billingStreet;
                contactUpdate.MailingCity = billingCity;
                contactUpdate.MailingState = billingState;
                contactUpdate.MailingPostalCode = billingPostalCode;
                contactUpdate.MailingCountry = billingCountry;
                
                Framework.Dispatcher.disableTriggerInContext.put('Contact', true);
            		update contactUpdate;
            	Framework.Dispatcher.disableTriggerInContext.put('Contact', false);
				
				system.debug('***contactUpdate : '+contactUpdate);
            
            
            	joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
                String redirectURL = joinUtil.navStepsMap.get('Next');
                JSONGenerator gen = JSON.createGenerator(true);
                
                gen.writeStartObject();
                gen.writeStringField('stepId', stepId);
                gen.writeStringField('redirectURL', redirectURL);
                gen.writeEndObject();
                system.debug('gen.getAsString : '+gen.getAsString());
                joinUtil.setRedirectURLCookie(gen.getAsString());
                return new PageReference(redirectURL);
                
                
                
            }
            catch(exception ex){
                errorMessage = ex.getMessage();
                system.debug('errorMessage : '+errorMessage);
                isError = true;
                if(errorMessage.contains('DUPLICATES_DETECTED')){
                    errorMessage = 'We found the Account record with similar details';
                }
                else{
                    errorMessage = 'Oops! something went wrong, please contact your administrator';
                }
                
            }
        }
        return null;
    }
    
    public boolean searchAccountByDomain() {
        
        this.lstAccWrapper = new List<Fon_SearchAccountWrapper>();
        
        Id uId = UserInfo.getUserId();
        usr = [SELECT ContactId FROM User WHERE Id =: uID LIMIT 1];
        con = [SELECT Id, AccountId, Name,email FROM Contact WHERE Id =: usr.ContactId LIMIT 1];
        List<Account> lstAccount = fetchAccountByDomain(con.email);
        
		//List<Account> lstAccount = fetchAccountByDomain('fake_ehoyt1@atu.edu');
		//List<Account> lstAccount = fetchAccountByDomain('fake_abuzov@fonteva.com');
        this.lstAccWrapper = Fon_SearchAccountWrapper.fetchAccountWrapper(lstAccount);
        System.debug('==============lstAccount=============='+lstAccount);
        System.debug('==============this.lstAccWrapper=============='+this.lstAccWrapper);
        
        return null;
    }
    
    public static List<Account> fetchAccountByDomain(String email){
        String emailDomain = email.split('@')[1];
        
        //isolates last part of domain after final '.' - for .mil and .osd checks        
        Integer endPosition = emailDomain.countMatches('.');
        String splitDomainEnd = emailDomain.split('\\.')[endPosition];
		
		//Check to see if the domain meets the criteria of .mil OR .osd        
        if(splitDomainEnd == 'osd' || splitDomainEnd == 'mil'){
            splitDomainEnd = ('.'+splitDomainEnd);
            emailDomain = splitDomainEnd;
        }

        
        Set<Id> AccountIds = new Set<Id>();
        List<OrderApi__AccountDomain__c> accDomain = [Select id,OrderApi__Company__c,OrderApi__Value__c,Fon_Value__c 
                                                      from OrderApi__AccountDomain__c 
                                                      where Fon_Value__c =: emailDomain];
        
        for(OrderApi__AccountDomain__c ad: accDomain){
            AccountIds.add(ad.OrderApi__Company__c);
        }
        
        List<Account> selectedAccounts = new List<Account>();
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,Name,BillingStreet,
                                        BillingCity,BillingState,BillingCountry,BillingPostalCode  
                                    FROM Account 
                                    WHERE Id IN: AccountIds]);
                                    //WHERE Id IN: AccountIds AND RecordTypeId =: rtId];
        List<OrderApi__Subscription__c> OaSubscriptions = [Select Id,OrderApi__Account__c, OrderApi__Item__r.Name, OrderApi__Item__r.Is_Entity__c 
                                                           	from OrderApi__Subscription__c 
                                                           where OrderApi__Account__c IN : AccountIds 
                                                           AND OrderApi__Item__r.Is_Entity__c = true
                                                           AND OrderApi__Is_Active__c = true
                                                           AND OrderApi__Status__c = 'Active'
                                                           AND OrderApi__Item__r.Name Like '%Organizational Affiliate%'];
        for(OrderApi__Subscription__c subs: OaSubscriptions){
            if(accountmap.ContainsKey(subs.OrderApi__Account__c)){
                selectedAccounts.add(accountmap.get(subs.OrderApi__Account__c));
            }
        }
        
        return selectedAccounts;
    }
    
    
}