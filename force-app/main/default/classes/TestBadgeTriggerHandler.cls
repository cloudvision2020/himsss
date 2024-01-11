@isTest(SeeAllData = true)
public class TestBadgeTriggerHandler {
    @isTest
    public static void methodData() {
        Account acc = new Account();
        acc.Name = 'Test Person';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Demo';
        insert con;
        
        PagesApi__Community_Group__c cGroup = new PagesApi__Community_Group__c();
        cGroup.Name = 'Test Member'; 
        cGroup.Badge_Name__c = 'Test Member';
        insert cGroup;
        
        OrderApi__Badge_Type__c Badgety =new OrderApi__Badge_Type__c();
        Badgety.Name='Test Member ';
        insert Badgety;
        
        OrderApi__Badge__c Bdg = new OrderApi__Badge__c();
        Bdg.OrderApi__Contact__c = con.Id;
        Bdg.OrderApi__Badge_Type__c = Badgety.Id; 
        Bdg.OrderApi__Is_Active__c = True;
        insert Bdg;
        
        OrderApi__Badge__c Bdg1 = new OrderApi__Badge__c();
        Bdg1.OrderApi__Contact__c = con.Id;
        Bdg1.OrderApi__Badge_Type__c = Badgety.Id; 
        Bdg1.OrderApi__Is_Active__c = True;
        insert Bdg1;
        
        Bdg.OrderApi__Is_Active__c = false;  
       
        update Bdg;
        
        Bdg.OrderApi__Is_Active__c = True;
        
        update Bdg;
        
        delete Bdg ;
        
    }
  }