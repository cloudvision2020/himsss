/**
 * @description       : A reg handler that uses email as the primary identifier
 * @author            : Cesar Meraz
 * @group             : HIMSS IT
 * @last modified on  : 09-14-2023
 * @last modified by  : 
**/

global class AppDevRegistrationHandler implements Auth.RegistrationHandler{
    final string COMMUNITYPROFILE = 'Fonteva Customer Community Login';
    final string DEFAULTACCOUNTTYPE = 'Household';



    global User createUser(Id portalId, Auth.UserData data){
        /**
            0. Search for the user by user id, if it exists.
        */


        /**
            1. Search for the contact. If there are too many contacts with that email, it throws error.
         */
        Contact mycontact = findContact(data.FirstName, data.LastName, data.Email);
        
        /**
            2. Search for the user. If there are too many users with that email, it throws error.
         */
        User myuser = findUser(data.FirstName, data.LastName, data.Email);


        if(mycontact == null){
            mycontact = contactGeneration(data.FirstName, data.LastName, data.Email);
        }

        if (myuser == null){
            myuser = userGeneration(data.FirstName, data.LastName, data.Email, mycontact);
        }

        return myuser;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        //on subsequence logins it is assumed that all is setup, but testing will bear this out
    }


    global boolean canCreateUser(Auth.UserData data) {
        List<Contact> lstCon = new List<Contact>();
        Boolean flag = TRUE;
        lstCon = [SELECT Id, AccountId, Account.OrderApi__Primary_Contact__c FROM Contact WHERE Email = :data.email LIMIT 1];
        return lstCon.isEmpty();
        
        //why do we need this? What if I'm not the primary contact for a Corp or OA but I still need
        //to log in and update my preferences or demographics or make a purchase?
        //All Non-primary contacts can currently create Auth0 accounts and access Marketplace and 
        //I think we need to allow this for Fonteva Users.
        // for(Contact con : lstCon){
        //     if(con.Id != con.Account.OrderApi__Primary_Contact__c){
        //         flag = FALSE;
        //     }
        // }
        // return flag;
        
    }

    
    private string aliasGenerator(String FirstNameString, String LastNameString){
        String aliasString = FirstNameString.substring(0,1) + LastNameString.substring(0,1)+string.valueOf(Math.round((Math.random() * (9000) + 1000)));
        List<User> existingUsersWithAlias = [SELECT Id, Alias FROM User WHERE Alias = :aliasString];
        if(!existingUsersWithAlias.isEmpty()){
            String s = aliasGenerator(FirstNameString,LastNameString);
            return s;
        }else{
            return aliasString;
        }
    }

    private Account accountGeneration(String FirstNameString, String LastNameString){
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(DEFAULTACCOUNTTYPE).getRecordTypeId();
        Account act = new Account(
            RecordTypeId = personAccountRecordTypeId,
            Name = FirstNameString + ' ' + LastNameString
        );
        Database.insert(act);
        return act;
    }

    private Contact contactGeneration(String FirstNameString, String LastNameString, String EmailString){           
        Account act = accountGeneration(FirstNameString, LastNameString);     
        Contact c = new Contact(
            FirstName = FirstNameString,
            LastName = LastNameString,
            Email = EmailString,
            AccountId = act.id
        );
        Database.insert(c);
        return c;
    }

    private User userGeneration(String FirstNameString, String LastNameString, String EmailString, Contact c){
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name= :COMMUNITYPROFILE Limit 1];
        User user1 = new User(
            UserName = EmailString,
            FirstName = FirstNameString,
            LastName = LastNameString,
            Alias = aliasGenerator(FirstNameString,LastNameString),
            Email = EmailString,
            ContactId = c.id,
            ProfileId = portalProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user1);
        return user1;
    }

    private User findUser(String FirstNameString, String LastNameString, String EmailString){            
        List<User> matchOnEmail = [SELECT Id, FirstName, LastName FROM user WHERE username= :EmailString AND IsActive=:true];
        if (matchOnEmail.size()==0){
            return null;
        }
        if (matchOnEmail.size() == 1){
            return matchOnEmail[0];
        }
        for (User match : matchOnEmail) {
            if (match.FirstName == FirstNameString && match.LastName == LastNameString){
                return match;
            }
        }

        throw new System.QueryException('Too many matches on User email');
    }

    private Contact findContact(String FirstNameString, String LastNameString, String EmailString){            
        List<Contact> matchOnEmail = [SELECT Id, FirstName, LastName FROM Contact WHERE Email= :EmailString];
        if (matchOnEmail.isEmpty()){
            return null;
        }
        if (matchOnEmail.size() == 1){
            return matchOnEmail[0];
        }
        Contact matchOnName = null;
        for (Contact match : matchOnEmail) {
            if (match.FirstName == FirstNameString && match.LastName == LastNameString){
                if (matchOnName != null){
                    matchOnName = null;
                    throw new System.QueryException('Too many matches on Contact email and name.');
                }
                matchOnName = match;
            }
        }
        if (matchOnName != null){
            return matchOnName;
        }

        throw new System.QueryException('Too many matches on Contact email');
    }


}