@RestResource(urlMapping='/portalUser/*')
global with sharing class CustomerPortalUserCreationEndpoints {
    
    global class errorBuilder {
        public String Message;
        
        public errorBuilder(String Message) {
            this.Message = Message;
        }
    }
    
    @HttpPost
    global static void createCustomerPortalUser(String FirstNameString, String LastNameString, String EmailString, Boolean isCreate){
        
        
        RestRequest  req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<Contact> MatchingContacts = [SELECT Id
                                          FROM   Contact 
                                          WHERE  Email = :EmailString];
                                        
                                        //Removed Kieran's original WHERE clause to increase matching to email addresses   JS 20231208   
                                        //AND LastName = :LastNameString 
                                        //AND FirstName = :FirstNameString
        
        final string COMMUNITYPROFILE = 'Fonteva Customer Community Login';
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name= :COMMUNITYPROFILE Limit 1];
        
        if(MatchingContacts.Size() > 1){
            //Multiple Contacts Found
            List<User> existingUsers = [SELECT id,Contact.FirstName,Contact.LastName,Contact.Company__c,Contact.Account.BillingAddress,Contact.Email,Contact.Title
                                        FROM   User
                                        WHERE  Email = : EmailString];
                                        
                                        //Removed Kieran's original WHERE clause to increase matching to email addresses   JS 20231208
                                        //WHERE FirstName = :FirstNameString AND LastName = :LastNameString AND
            
            system.debug(system.JSON.serialize(existingUsers));
            ///Return
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(existingUsers));
            
        }else if(!MatchingContacts.isEmpty()){
            //only 1 contact found
            //check if user associated with contact exists
            List<User> u = [SELECT id,Contact.FirstName,Contact.LastName,Contact.Company__c,Contact.Account.BillingAddress,Contact.Email,Contact.Title, isActive 
                            FROM User 
                            WHERE Email = :EmailString AND ContactId = :MatchingContacts[0].id];
            if(u.isEmpty()){
                //if no users were found
                //create the user for the contact
                if(isCreate){           
                    User user1 = userGeneration(FirstNameString,LastNameString,EmailString,MatchingContacts[0],portalProfile);
                    user1.CommunityNickname = user1.FirstName+string.valueOf(Math.round((Math.random() * (9000) + 1000)));
                    Database.insert(user1);
                    //Return
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf(JSON.serialize(user1));
                }else{
                    //Return
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResponse()));
                }
            }else{
                //One or more Users were found
                if(u[0].isActive){
                    system.debug(JSON.serialize(u[0]));
                    //Return
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf(JSON.serialize(u[0])); 
                }else{
                    //Return
                    res.statusCode = 400;
                }
            }
        }else{
            //No contact was found
            //Create Personal Account and Contact
            //CREATE User and Link to Contact
            if(isCreate){
                Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
                Account act = new Account(
                    RecordTypeId = personAccountRecordTypeId,
                    Name = FirstNameString + ' ' + LastNameString
                );
                Database.insert(act);
                
                Contact c = new Contact(
                    FirstName = FirstNameString,
                    LastName = LastNameString,
                    Email = EmailString,
                    AccountId = act.id
                );
                Database.insert(c);
                
                User user1 = userGeneration(FirstNameString,LastNameString,EmailString,c,portalProfile);
                user1.CommunityNickname = user1.FirstName+string.valueOf(Math.round((Math.random() * (9000) + 1000)));
                Database.insert(user1);
                system.debug(JSON.serialize(user1));
                //Return
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(user1));
            }else{ 
                //Return
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(errorResponse()));
            }
            
        }
    }
    
    global static errorBuilder errorResponse(){
        errorBuilder obj = new errorBuilder('No User Found');
        return obj;
    }
    
    public static string aliasGenerator(String FirstNameString, String LastNameString){
        String aliasString = FirstNameString.substring(0,1) + LastNameString.substring(0,1)+string.valueOf(Math.round((Math.random() * (9000) + 1000)));
        List<User> existingUsersWithAlias = [SELECT Id, Alias FROM User WHERE Alias = :aliasString];
        if(!existingUsersWithAlias.isEmpty()){
            String s = aliasGenerator(FirstNameString,LastNameString);
            return s;
        }else{
            return aliasString;
        }
    }
    
    
    public static User userGeneration(String FirstNameString, String LastNameString, String EmailString,Contact c, Profile portalProfile){
        User user1 = new User(
            UserName = EmailString,
            FirstName = FirstNameString,
            LastName = LastNameString,
            Alias = aliasGenerator(FirstNameString,LastNameString),
            Email = EmailString,
            FederationIdentifier = EmailString,
            ContactId = c.id,
            ProfileId = portalProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        return user1;
    }
    
    
}