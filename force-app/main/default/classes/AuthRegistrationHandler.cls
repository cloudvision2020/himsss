/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//TODO:This autogenerated class includes the basics for a Registration
//Handler class. You will need to customize it to ensure it meets your needs and
//the data provided by the third party.

global class AuthRegistrationHandler implements Auth.RegistrationHandler{

    global boolean canCreateUser(Auth.UserData data) {
        List<Contact> lstCon = new List<Contact>();
        Boolean flag = TRUE;
        lstCon = [SELECT Id, AccountId, Account.OrderApi__Primary_Contact__c FROM Contact WHERE Email = :data.email LIMIT 1];
        
        for(Contact con : lstCon){
            if(con.Id != con.Account.OrderApi__Primary_Contact__c){
                flag = FALSE;
            }
        }
        return flag;
        
    }

    global User createUser(Id portalId, Auth.UserData data){
        if(!canCreateUser(data)) {
            //Returning null or throwing an exception fails the SSO flow
            //throw new applicationException('This person is a secondary contact.');
            List<User> lstU = [Select Id from User where Email=:data.email];
            if(lstU.size() > 0 ){
                return lstU[0];
            }
            return null;
        }
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            //We have a community id, so create a user with community access
            List<Contact> con = new List<Contact>();
            con = [SELECT Id FROM Contact WHERE Email = :data.email ];
            Contact c = new Contact();
            if(con.size() == 0){   
                c.email = data.email;
                c.firstName = data.firstName;
                c.lastName = data.lastName;
                c.MobilePhone = data.attributeMap.get('mobile_number');
                system.debug(LoggingLevel.Info,'**Sandeep BIRTHDATE**'+data.attributeMap.get('birth_date'));
                if(String.isNotBlank(data.attributeMap.get('birth_date')) && data.attributeMap.get('birth_date') != 'null'){
                    
                    date birthDay = date.valueOf(data.attributeMap.get('birth_date'));
                    Integer d = birthDay.day();
                    Integer mo = birthDay.month();
                    Integer yr = birthDay.year();
                    DateTime DT = DateTime.newInstance(yr, mo, d);                  
                    string birthDate = DT.format('yyyy-mm-dd');
                    system.debug('\n--birthDate--'+birthDate);
                    
                    if(birthDate.indexOf('0000-00-00') == -1
                        && birthDate.indexOf('1907-01-01') == -1){                      
                        c.Birthdate = date.valueOf(data.attributeMap.get('birth_date'));
                    }
                }
                c.MailingCity = data.attributeMap.get('city');
                c.MailingCountry = data.attributeMap.get('country');
                c.MailingState = data.attributeMap.get('state');
                c.MailingStreet = data.attributeMap.get('street_address_1') + ' ' + data.attributeMap.get('street_address_2');
                c.MailingStreet = c.MailingStreet.trim();
                c.MailingPostalCode = data.attributeMap.get('zip_code');
                system.debug('**Sandeep INSERT**'+c);
                insert c;
            } else {
                c = new Contact(Id = con[0].Id);
                c.email = data.email;
                c.firstName = data.firstName;
                c.lastName = data.lastName;
                c.MobilePhone = data.attributeMap.get('mobile_number');
                if((String.isNotBlank(data.attributeMap.get('birth_date')) && data.attributeMap.get('birth_date') != 'null')
                    || data.attributeMap.get('birth_date') == '0000-00-00'|| data.attributeMap.get('birth_date')=='1907-01-01'){
                    c.Birthdate = date.valueOf(data.attributeMap.get('birth_date'));
                }
                c.MailingCity = data.attributeMap.get('city');
                c.MailingCountry = data.attributeMap.get('country');
                c.MailingState = data.attributeMap.get('state');
                c.MailingStreet = data.attributeMap.get('street_address_1') + ' ' + data.attributeMap.get('street_address_2');
                c.MailingStreet = c.MailingStreet.trim();
                c.MailingPostalCode = data.attributeMap.get('zip_code');
                update c;
            }
    
            //TODO: Customize the username and profile. Also check that the username doesn't already exist and
            //possibly ensure there are enough org licenses to create a user. Must be 80 characters or less.
            User u = new User();
            //List<String> ven = data.attributeMap.get('venue').split('-');
            String pName = 'Fonteva Customer Community Login';
            Profile p = [SELECT Id FROM profile WHERE name= :pName];
            u.username = data.email + '@topgolf.members'; 
            u.email = data.email;
            u.lastName = data.lastName;
            u.firstName = data.firstName;
            String alias = data.lastName + data.firstName;
            //Alias must be 8 characters or less
            if(alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            u.alias = alias;
            u.languagelocalekey = UserInfo.getLocale();
            u.localesidkey = UserInfo.getLocale();
            u.emailEncodingKey = 'UTF-8';
            u.timeZoneSidKey = 'America/Los_Angeles';
            u.profileId = p.Id;
            u.contactId = c.Id;
            
            return u;
        } else {
            //This is not a community, so don't do anything     
            return null;
        }
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        Id pId = [SELECT profileId FROM User WHERE Id = :userId LIMIT 1].profileId;
        String pName = [SELECT Name FROM Profile WHERE Id = :pId LIMIT 1].Name;
        String cName = [SELECT Name FROM Network WHERE Id = :data.attributeMap.get('sfdc_networkid') LIMIT 1].Name;
        
        if(pName.contains(cName)){
            User u = new User(id=userId);
            u.email = data.email;
            u.lastName = data.lastName;
            u.firstName = data.firstName; 
            update u;
            Id conId = [SELECT Id, ContactId FROM User WHERE Id = :u.Id LIMIT 1][0].contactId;
            Contact c = new Contact(Id=conId);
            //Check contacts subscription, if platinum DO NOT update, else update
            List<OrderApi__Subscription__c> lstSub = new List<OrderApi__Subscription__c>();
            lstSub = [SELECT Id, OrderApi__Item__r.Name FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c = :c.Id];
            System.debug(LoggingLevel.Info,'u.ContactId'+lstSub);
            Boolean isPlatinum = FALSE;
            
            if(!lstSub.isEmpty()){
                for(OrderApi__Subscription__c sub : lstSub){
                    if(sub.OrderApi__Item__r.Name.contains('Platinum')){
                        isPlatinum = TRUE;
                        break;
                    }
                }
            } else {
                isPlatinum = FALSE;
            }
            
            if(!isPlatinum){
                c.email = data.email;
                c.firstName = data.firstName;
                c.lastName = data.lastName;
                c.MobilePhone = data.attributeMap.get('mobile_number');
                if((String.isNotBlank(data.attributeMap.get('birth_date')) && data.attributeMap.get('birth_date') != 'null')
                    || data.attributeMap.get('birth_date') == '0000-00-00'|| data.attributeMap.get('birth_date')=='1907-01-01'){
                    c.Birthdate = date.valueOf(data.attributeMap.get('birth_date'));
                }
                //c.Birthdate = date.valueOf(data.attributeMap.get('birth_date'));
                c.MailingCity = data.attributeMap.get('city');
                c.MailingCountry = data.attributeMap.get('country');
                c.MailingState = data.attributeMap.get('state');
                c.MailingStreet = data.attributeMap.get('street_address_1') + ' ' + data.attributeMap.get('street_address_2');
                c.MailingStreet = c.MailingStreet.trim();
                c.MailingPostalCode = data.attributeMap.get('zip_code');
                system.debug(LoggingLevel.Info,'***c**'+c);
                update c;
            }
                
        } else {
            //throw new applicationException('Wrong community. You are part of '+pName.split(' ')[1]);
        }
        
    }
}