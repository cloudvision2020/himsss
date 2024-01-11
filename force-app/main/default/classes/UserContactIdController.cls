public with sharing class UserContactIdController {
    public static Id getUserContactId() {
        Id contactId;

        // Get the current user's Id
        Id currentUserId = UserInfo.getUserId();
        
        User userDetails = [SELECT Id FROM User WHERE Id = :currentUserId AND (Profile.Name = 'Fonteva Customer Community Login' OR Profile.Name = 'Fonteva Customer Community Plus')];

        // Query the User record to get the ContactId
        User currentUser = [SELECT ContactId FROM User WHERE Id = :userDetails.Id ];

        // Retrieve the ContactId from the User record
        if (currentUser != null) {
            contactId = currentUser.ContactId;
        }

        return contactId;
    }
}