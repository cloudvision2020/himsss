public class Fon_UpdateContactBySubscription {
    public class FlowInput {
        @InvocableVariable(label='contact Id')
        public Id ContactIds;
    }
    
    
    @InvocableMethod(
        category='Contact'
        label='Update Contact by Subscription'
        description='Update Contact by Subscription'
    )
    public static void updateContact(List<FlowInput> flowInputs) {
        System.debug('***Fon_UpdateContactBySubscription updateContact***');
        system.debug('ContactIds : '+flowInputs[0].ContactIds);
        List<Contact> contactList = [Select Id, Name, Chapter_Complimentary_Membership__c, Opt_out_of_Chapter_Membership__c 
                                     from contact
                                     where Id =: flowInputs[0].ContactIds
                                     AND Chapter_Complimentary_Membership__c != null
                                     AND Opt_out_of_Chapter_Membership__c = 'No'];
        Framework.Dispatcher.disableTriggerInContext.put('Contact', true);
        	//FON_ContactAssignmentTriggerService.createSalesOrder(contactList);
        Framework.Dispatcher.disableTriggerInContext.put('Contact', false);
        /*
        List<Contact> contacts = [Select Id,IsUpdateRequired__c 
                                  from Contact 
                                  Where Id = : flowInputs[0].ContactIds];
        system.debug('contacts : '+contacts);
        
        for(Contact con: contacts){
            con.IsUpdateRequired__c = true;
        }
        
        if(contacts.size() > 0){
            Framework.Dispatcher.disableTriggerInContext.put('Contact', true);
            	update contacts;
            Framework.Dispatcher.disableTriggerInContext.put('Contact', false);
        }
		*/
    }
}