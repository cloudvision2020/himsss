@isTest
public class CECreditHoursTriggerHandlerTest {

    @isTest
    public static void testCECreditHoursTriggerHandler(){
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSettingsObj = new TriggerSettings__c(Name = 'CE_Hours__c', TriggerDisabled__c = false);
        triggerSettingsList.add(triggerSettingsObj);

        insert triggerSettingsList;
        
        
        //insert Account
        Account accountObj = new Account();
        	
        	accountObj.Name = 'Test Account';
        	accountObj.No_Known_Address__c =true;        
        	accountObj.Media_Account_Owner__c=UserInfo.getUserId();
        
        insert accountObj;

        //insert Contact
        Contact newValidContactToInsert = new Contact(FirstName = 'Test Valid',
                                                      LastName = 'Contact',
                                                      AccountId = accountObj.Id);

        insert newValidContactToInsert;
        
        OrderApi__Item_Class__c itmcl = new OrderApi__Item_Class__c();
        	itmcl.Name = 'Certification';
        insert itmcl;

        //insert Item
        OrderApi__Item__c itm =new OrderApi__Item__c();
        	itm.name='Certification';
        	itm.OrderApi__Item_Class__c = itmcl.Id;
        insert itm;
        
        //insert Subscriptions
        OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
        
            sub.OrderApi__Account__c = accountObj.Id;
            sub.OrderApi__Contact__c = newValidContactToInsert.Id;
            sub.OrderApi__Entity__c ='Contact';
            sub.OrderApi__Activated_Date__c = Date.today();
            sub.OrderApi__Paid_Through_Date__c = Date.today().addDays(1);
            sub.OrderApi__Days_To_Lapse__c = 365;
            sub.OrderApi__Enable_Auto_Renew__c = true;
            sub.OrderApi__Item__c = itm.Id;
            sub.OrderApi__status__C = 'Active';
        
        insert sub;
        
        //insert Terms
        OrderApi__Renewal__c term =new OrderApi__Renewal__c();
        	term.OrderApi__Subscription__C=sub.Id;
        insert term;
        
        List<CE_Hours__c> ceList = new List<CE_Hours__c>();
           
        	CE_Hours__c ceho = new CE_Hours__c();
            ceho.Education_Provider__c = 'NON-HIMSS';
            ceho.Activity_Type__c = 'Ethics';
            ceho.Number_Of_Credits__c = 1;
            ceho.Credit_Date__c = date.today();
            ceho.Program_Title__c = 'testing';
            ceho.Term__c = term.Id;
            ceList.add(ceho);
            
            CE_Hours__c ceho1 = new CE_Hours__c();
            ceho1.Education_Provider__c = 'HIMSS';
            ceho1.Activity_Type__c = 'Ethics';
            ceho1.Number_Of_Credits__c = 1;
            ceho1.Credit_Date__c = date.today();
            ceho1.Program_Title__c = 'testing';
            ceho1.Term__c = term.Id;
            ceList.add(ceho1);
        
        insert ceList;
        
        OrderApi__Subscription__c subAsrt =[SELECT Id, Active_Term_Approved_HIMSS_CE_Hours__c, Active_Term_CE_Hours__c,
                                       Active_Term_Non_Approved_CE_Hours__c, No__c 
                                       FROM OrderApi__Subscription__c WHERE Id  =: sub.id];
        assert.areEqual(subAsrt.Active_Term_Approved_HIMSS_CE_Hours__c, 1);
		assert.areEqual(subAsrt.Active_Term_CE_Hours__c, 2);
        assert.areEqual(subAsrt.Active_Term_Non_Approved_CE_Hours__c, 1);
        assert.areEqual(subAsrt.No__c, 2);
     }
}