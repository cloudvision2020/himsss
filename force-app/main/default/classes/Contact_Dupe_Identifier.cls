global class Contact_Dupe_Identifier implements Database.Batchable<sObject>{
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT id, FirstName, LastName,Email FROM Contact';
        return Database.getQueryLocator(query);
    }
    
    
    global static void execute(Database.BatchableContext bc, List<Contact> conList){
        
        Map<String, Integer> ContactDupeCount = new Map<String, Integer>();
        List<String> identifyDupeKeys = new List<String>();
        List<Contact> dupesToMark = new List<Contact>();
        
        for(Contact c : conList) 
        {
            Integer count = 1;
            String Mapkey = c.FirstName+','+c.LastName+','+c.Email;
            
            if(ContactDupeCount.containsKey(Mapkey)){
                count = ContactDupeCount.get(Mapkey) + 1;
            }
            
            ContactDupeCount.put(Mapkey, count);
        }
        
        for(String s : ContactDupeCount.keyset())
        {
            if(ContactDupeCount.get(s) <= 1){
                ContactDupeCount.remove(s);
            }else{
                identifyDupeKeys.add(s);
            }     
        }
               
        for(String s : identifyDupeKeys){
            String[] splitString = s.split(',');
            List<Contact> getRecords = [SELECT id,FirstName,LastName,Email,isDupe__c 
                                        FROM Contact 
                                        WHERE (FirstName = :splitString[0].toLowercase()
                                        AND LastName = :splitString[1].toLowercase()
                                        AND Email = :splitString[2].toLowercase())
                                        OR (FirstName = :splitString[0].toUpperCase()
                                        AND LastName = :splitString[1].toUpperCase()
                                        AND Email = :splitString[2].toUpperCase())
                                        OR (FirstName = :splitString[0]
                                        AND LastName = :splitString[1]
                                        AND Email = :splitString[2])];
            for(Contact c : getRecords){
                c.isDupe__c = True;
                dupesToMark.add(c);
            }
        }
        
        update dupesToMark;
        
    }
    
     global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        // Send current user an email once all processes are complete?
    }   
}