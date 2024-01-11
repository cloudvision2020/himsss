public class AMS_Leading_Nine{
    
    public static void updateAccountsAMS(){
        
        STRING LEADINGNUMBER = '9';
        List<Account> updateAccounts = new List<Account>();
        
        Set<String> duplicateAMS = new Set<String>();
        for (AggregateResult aggregate : [SELECT AMS_Company_ID__c,count(id) FROM  Account group by AMS_Company_ID__c having  count(AMS_Company_ID__c)>1])
        {
            duplicateAMS.add((String)aggregate.get('AMS_Company_ID__c'));
        }
        
        List<Account> relevantAccounts = [SELECT ID, NAME, AMS_Company_ID__c FROM Account WHERE AMS_Company_ID__c IN :duplicateAMS];
        
        List<String> splitString = new List<String>();
        for(Account a : relevantAccounts){
            splitString = a.AMS_Company_ID__c.split('');
            splitstring[0] = LEADINGNUMBER;
            String newAMS = String.join(splitstring,'');
            a.AMS_Company_ID__c = newAMS;
            updateAccounts.add(a);
        }
        
        update updateAccounts;
        
    }
    
    public static void updateContactAMSContact(){
        STRING LEADINGNUMBER = '9';
        List<Contact> updateContacts = new List<Contact>();
        
        Set<String> duplicateAMS = new Set<String>();
        for (AggregateResult aggregate : [SELECT AMS_Contact_ID__c,count(id) FROM  Contact group by AMS_Contact_ID__c having  count(AMS_Contact_ID__c)>1])
        {
            duplicateAMS.add((String)aggregate.get('AMS_Contact_ID__c'));
        }
        
        List<Contact> relevantContacts = [SELECT ID, NAME, AMS_Contact_ID__c FROM Contact WHERE AMS_Contact_ID__c IN :duplicateAMS];
        
        List<String> splitString = new List<String>();
        for(Contact c : relevantContacts){
            splitString = c.AMS_Contact_ID__c.split('');
            splitstring[0] = LEADINGNUMBER;
            String newAMS = String.join(splitstring,'');
            c.AMS_Contact_ID__c = newAMS;
            updateContacts.add(c);
        }
        
        update updateContacts;
    }
    
    public static void updateContactAMSID(){
        STRING LEADINGNUMBER = '9';
        List<Contact> updateContacts = new List<Contact>();
        
        Set<String> duplicateAMS = new Set<String>();
        for (AggregateResult aggregate : [SELECT AMS_ID__c,count(id) FROM  Contact group by AMS_ID__c having  count(AMS_ID__c)>1 ORDER BY AMS_ID__c])
        {
            duplicateAMS.add((String)aggregate.get('AMS_ID__c'));
        }
        
        List<Contact> relevantContacts = [SELECT ID, NAME, AMS_ID__c FROM Contact WHERE AMS_ID__c IN :duplicateAMS AND AMS_ID__c LIKE '0%' LIMIT 200];
        
        List<String> splitString = new List<String>();
        
        for(Contact c : relevantContacts){
            splitString = c.AMS_ID__c.split('');
            if(splitstring[0] == '0'){
                splitstring[0] = LEADINGNUMBER;
                String newAMS = String.join(splitstring,'');
                c.AMS_ID__c = newAMS;
                updateContacts.add(c);
            }
        }
        
        update updateContacts;
    }
    
    
}