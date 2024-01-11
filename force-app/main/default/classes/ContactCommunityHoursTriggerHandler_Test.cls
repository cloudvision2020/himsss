@IsTest
public class ContactCommunityHoursTriggerHandler_Test {
    @IsTest 
    static void communityhourstest(){
        string accountid = TestUtility.createAccount();
        TriggerSettings__c ts = new TriggerSettings__c();
        ts.name='Contact';
        ts.TriggerDisabled__c=false;
        insert ts;
        
             
        PagesApi__Community_Group__c  Cgroup= new PagesApi__Community_Group__c();
        Cgroup.Name = 'DACH Community';
        insert Cgroup;
        
        PagesApi__Community_Group__c  Cgroup1= new PagesApi__Community_Group__c();
        Cgroup1.Name = 'French Community';
        insert Cgroup1;
        
        
        Contact conObj = TestUtility.createContactRecord(accountid);
        conObj.International_Professional_Community__c='DACH Community';
        conObj.Professional_Communities__c = 'HIMSS Expert Network';
        insert conObj;
        update conObj;
        
        
        conObj.International_Professional_Community__c= '';
        conObj.Professional_Communities__c = '';
        update conObj;
        
    }
  
}