public class BadgeContactTriggerhandler {
	public static void contactBadge(List<OrderApi__Badge__c> newList, Map<Id, OrderApi__Badge__c> oldMap){

    List<Contact> contactsToUpdate = new List<Contact>();

        for (OrderApi__Badge__c badge : newList) {
         
            if (Badge.OrderApi__Is_Active__c == false && Badge.OrderApi__Badge_Type__c == '+Member+') {

                Contact relatedContact = [SELECT Id, Professional_Communities__c, International_Professional_Community__c
                                         FROM Contact
                                         WHERE Id = :Badge.OrderApi__Contact__c];

   
                relatedContact.Professional_Communities__c = null;
                relatedContact.International_Professional_Community__c = null;


                contactsToUpdate.add(relatedContact);
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}