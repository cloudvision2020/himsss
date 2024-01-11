@IsTest
public class AssignmentTriggerHandler_Test {
    static Boolean isInstalled = false;
    
	private static void install() {  
        if (!isInstalled) {
            Framework.Installer.install();
            //PagesApi.PackageScripts.install();
            OrderApi.PackageScripts.install();
            //EventApi.PackageScripts.install();
            isInstalled = true; 
        }
    }
	    
    @IsTest
    static void testAfterInsert(){
        install();
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule cons = new Framework.RoutingRule();
        cons.apexClass = 'Fon_AssignmentTriggerDomain';
        cons.namespace = '  ';
        cons.isEnabled = true;
        cons.sObjectName = 'OrderApi__Assignment__c';
        cons.executionOrder = 99;
        rules.add(cons);
        
        Framework.Config.push(rules);
        
        TestUtility.createTriggerSettings();
        TriggerSettings__c ts = new TriggerSettings__c();
        ts.name='Contact';
        ts.TriggerDisabled__c=false;
        insert ts;
        
        EmailTemplate[] emailTemplates = new List<EmailTemplate>();  
        string accountid = TestUtility.createAccount();
        Contact conObj = TestUtility.createContact(accountid);
        OrderApi__Item_Class__c indivItemClassObj = TestUtility.createNewItemClass('INDIV');
        OrderApi__Item_Class__c corpItemClassObj = TestUtility.createNewItemClass('CORP');
        OrderApi__Item__c itemObj = TestUtility.createNewItem(indivItemClassObj.Id);
        OrderApi__Item__c itemsObj = TestUtility.createNewItem(itemObj.id, corpItemClassObj.id);
        OrderApi__Assignment__c assignmentObj = TestUtility.createNewAssigment(conObj.id,itemsObj.Id, corpItemClassObj.Id);
     }
    /*
    @IsTest
    static void testAfterUpdate(){
		install();
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule cons = new Framework.RoutingRule();
        cons.apexClass = 'Fon_AssignmentTriggerDomain';
        cons.namespace = '  ';
        cons.isEnabled = true;
        cons.sObjectName = 'OrderApi__Assignment__c';
        cons.executionOrder = 99;
        rules.add(cons);
		Framework.Config.push(rules);
		 
        TestUtility.createTriggerSettings();
        TriggerSettings__c ts = new TriggerSettings__c();
        ts.name='Contact';
        ts.TriggerDisabled__c=false;
        insert ts;
        EmailTemplate[] emailTemplates = new List<EmailTemplate>();  
        string accountid = TestUtility.createAccount();
        Contact conObj = TestUtility.createContact(accountid);
        OrderApi__Item__c itemObj = TestUtility.createItem();
        OrderApi__Item__c itemsObj = TestUtility.createItem(itemObj.id);
        OrderApi__Item_Class__c itemClassObj = TestUtility.createItemClass('CORP');
        OrderApi__Assignment__c assignmentObj = TestUtility.createAssigment(conObj.id,itemsObj.id,itemClassObj.id);
        assignmentObj.OrderApi__Assigned_Date__c = system.today();
        update assignmentObj;
     }
	*/
    
}