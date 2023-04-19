@isTest
public class Contact_Dupe_Identifier_Test {
    
    @isTest
    public static void checkDupeIsMarked(){
        
        List<Contact> insertContacts = new List<Contact>();
        
        for(Integer i=0; i < 20; i++){
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Test';
            c.Email = 'test@test.com';
            insertContacts.add(c);
        }
        
        insert insertContacts;
        
        test.startTest();
        Contact beforeTagging = [SELECT id,FirstName,LastName,Email,isDupe__c 
                                 FROM Contact
                                 LIMIT 1];
        
        Contact_Dupe_Identifier myBatchObject = new Contact_Dupe_Identifier();
		Id batchId = Database.executeBatch(myBatchObject,1000);
        
        test.stopTest();
        Contact afterTagging = [SELECT id,FirstName,LastName,Email,isDupe__c 
                                 FROM Contact
                                 LIMIT 1];
        
        
        system.assertEquals(False, beforeTagging.isDupe__c);
        system.assertEquals(True, afterTagging.isDupe__c);
    }
    
}