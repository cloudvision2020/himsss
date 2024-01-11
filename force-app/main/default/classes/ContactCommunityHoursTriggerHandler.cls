public class ContactCommunityHoursTriggerHandler  implements TriggerHandlerInterface{
     public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting
    */
    public Boolean IsDisabled(){
        System.debug('CECreditHoursTriggerHandler.IsDisabled executing');
        if(TriggerSettings__c.getInstance('Contact') == null){
            return TriggerDisabled;
        }
        if (TriggerSettings__c.getInstance('Contact').TriggerDisabled__c){
            return true;
        } else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<SObject> newItems) {
    }
     
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        Communitygroupmember((Map<Id, Contact>) newItems,Null);
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Communitygroupmember((Map<Id, Contact>) newItems,(Map<Id, Contact>) oldItems);
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
    private Static Void Communitygroupmember(Map<Id,Contact> NewMap, Map<Id,Contact>Oldconlist){
        Set<Id> contactIdsToUpdate = new Set<Id>();
        Map<String, Id> communityToGroupMap = new Map<String, Id>();
        List<Sobject> groupMembersToDelete = new List<Sobject>();
        
          for(contact conObj : [SELECT Id, Name,LastName,International_Professional_Community__c,Professional_Communities__c 
                                FROM Contact where Id=:NewMap.keyset()]){
            if((Oldconlist==null) || conObj.International_Professional_Community__c != Oldconlist.get(conObj.Id).International_Professional_Community__c 
               || conObj.Professional_Communities__c != Oldconlist.get(conObj.Id).Professional_Communities__c){
                   contactIdsToUpdate.add(conObj.Id);
               }
        }
        
      if (!contactIdsToUpdate.isEmpty()) {
           
            List<PagesApi__Community_Group_Member__c> groupMembersToCreate = new List<PagesApi__Community_Group_Member__c>();
            List<PagesApi__Community_Group__c > groupToCreate = new List<PagesApi__Community_Group__c>();
            List<String> communityFields = new List<String>();
            for (Contact contact : [SELECT Id, International_Professional_Community__c, Professional_Communities__c
                                    FROM Contact WHERE Id IN :contactIdsToUpdate]) {
                if (contact.International_Professional_Community__c != null) {
                    communityFields.addAll(contact.International_Professional_Community__c.split(';'));
                }
                if (contact.Professional_Communities__c != null) {
                    communityFields.addAll(contact.Professional_Communities__c.split(';'));
                }
            }

            for (PagesApi__Community_Group__c group2 : [SELECT Id, Name FROM PagesApi__Community_Group__c ]) {
                communityToGroupMap.put(group2.Name, group2.Id);
            }
            List<string>communityFields2=New List<string>();
            for(contact contact : [SELECT Id,Name, International_Professional_Community__c, Professional_Communities__c
                                   FROM Contact WHERE Id IN :contactIdsToUpdate]){
                if (contact.International_Professional_Community__c != null ){
                    communityFields2.addAll(contact.International_Professional_Community__c.split(';'));
                }
                if (contact.Professional_Communities__c != null ){
                    communityFields2.addAll(contact.Professional_Communities__c.split(';'));
                }
                for (String communityField : communityFields2) {
                    if (communityToGroupMap.containsKey(communityField)) {
                           if (!groupMemberExists(contact.Id, communityToGroupMap.get(communityField))){
                                PagesApi__Community_Group_Member__c groupMember = new PagesApi__Community_Group_Member__c(
                                PagesApi__Community_Group__c = communityToGroupMap.get(communityField),
                                PagesApi__Contact__c = contact.Id
                            );
                            groupMembersToCreate.add(groupMember);
                        }
                    }
                }  
               
                if (Oldconlist!=null && Oldconlist.containsKey(contact.Id)) {
                    List<String> oldCommunityFields2 = new List<String>();
                    if (Oldconlist.get(contact.Id).International_Professional_Community__c != null) {
                        oldCommunityFields2.addAll(Oldconlist.get(contact.Id).International_Professional_Community__c.split(';'));
                    }
                    if (Oldconlist.get(contact.Id).Professional_Communities__c != null) {
                        oldCommunityFields2.addAll(Oldconlist.get(contact.Id).Professional_Communities__c.split(';'));
                    }
                    for (String oldCommunityField : oldCommunityFields2) {
                        if (communityToGroupMap.containsKey(oldCommunityField) && !communityFields2.contains(oldCommunityField)) {
                            deleteGroupMember(contact.Id, communityToGroupMap.get(oldCommunityField));
                        }
                    }
                }
            }
            insert groupMembersToCreate;
        }
    }

    private static Boolean groupMemberExists(Id contactId, Id communityGroupId) {
        List<PagesApi__Community_Group_Member__c> existingGroupMembers = [ SELECT Id FROM PagesApi__Community_Group_Member__c WHERE PagesApi__Is_Active__c = :true AND PagesApi__Contact__c = :contactId AND PagesApi__Community_Group__c = :communityGroupId];
        
        return !existingGroupMembers.isEmpty();
    } 
    private static void deleteGroupMember(Id contactId, Id communityGroupId) {
        List<PagesApi__Community_Group_Member__c> groupMembersToDelete = [ SELECT Id FROM PagesApi__Community_Group_Member__c WHERE PagesApi__Contact__c = :contactId AND PagesApi__Community_Group__c = :communityGroupId];
        for(PagesApi__Community_Group_Member__c groupmemb : groupMembersToDelete){
            groupmemb.PagesApi__Is_Active__c = false;
        }
        Update groupMembersToDelete;
    }
}