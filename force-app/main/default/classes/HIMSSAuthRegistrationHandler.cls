global class HIMSSAuthRegistrationHandler{
    //implements Auth.RegistrationHandler
    // depractated
    /*
    //Id from AUTH0 = Auth.UserData.SFID?
    
    global boolean canCreateUser(Auth.UserData data) {
        Boolean flag = TRUE;
        
        Contact con = [SELECT Id, AccountId, Account.OrderApi__Primary_Contact__c FROM Contact WHERE Email = :data.email LIMIT 1];
        
        if(con.id != con.Account.OrderApi__Primary_Contact__c){
            flag = FALSE;
        }
        return flag;   
    }
    
    global User createUser(Id portalId, Auth.UserData data){
        if(!canCreateUser(data)){
            //If we cant create a user - find a user with the same email and return the first found
            //If no user found, return null
            List<User> lstU = [Select Id from User where Email=:data.email];
            if(lstU.size() > 0 ){
                return lstU[0];
            }
            return null;
        }
        return null;
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        
    } 
    */
}