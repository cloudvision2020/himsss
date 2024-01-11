public class ContactCommunityTriggerHandler {
    Public Static Void Communitygroupmember(List<Contact>NewConlist, Map<Id,Contact>Oldconlist)
    {
        Set<Id> contactIdsToUpdate = new Set<Id>();
        Map<String, Id> communityToGroupMap = new Map<String, Id>();
        List<Sobject> groupMembersToDelete = new List<Sobject>();
        for (Contact contact : newconlist) {
            
            
            if ((Oldconlist==null)||(contact.International_Professional_Community__c != Oldconlist.get(contact.Id).International_Professional_Community__c ||
                                     contact.Professional_Communities__c != Oldconlist.get(contact.Id).Professional_Communities__c) ) {
                                         contactIdsToUpdate.add(contact.Id);
                                         
                                     }
        }
        
        if (!contactIdsToUpdate.isEmpty()) {
            // Map<String, Id> communityToGroupMap = new Map<String, Id>();
            
            for (PagesApi__Community_Group__c group1 : [SELECT Id, Name FROM PagesApi__Community_Group__c ]) {
                communityToGroupMap.put(group1.Name, group1.Id);
            }
            
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
            for (String communityField : communityFields) {
                if (!communityToGroupMap.containsKey(communityField)) {
                    PagesApi__Community_Group__c CommunityGroup = New PagesApi__Community_Group__c();
                    CommunityGroup.Name=communityField;
                    groupToCreate.add(CommunityGroup);
                    
                }
                
            }
            insert groupToCreate;
            
            for (PagesApi__Community_Group__c group2 : [SELECT Id, Name FROM PagesApi__Community_Group__c ]) {
                communityToGroupMap.put(group2.Name, group2.Id);
            }
            List<string>communityFields2=New List<string>();
            for(contact contact : [SELECT Id,Name, International_Professional_Community__c, Professional_Communities__c
                                   FROM Contact WHERE Id IN :contactIdsToUpdate])
                
            {
                if (contact.International_Professional_Community__c != null )
                {
                    communityFields2.addAll(contact.International_Professional_Community__c.split(';'));
                }
                if (contact.Professional_Communities__c != null ) 
                {
                    
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
                //        }
                
                
                if (Oldconlist!=null && Oldconlist.containsKey(contact.Id)) {
                    List<String> oldCommunityFields2 = new List<String>();
                    if (Oldconlist.get(contact.Id).International_Professional_Community__c != null) {
                        oldCommunityFields2.addAll(Oldconlist.get(contact.Id).International_Professional_Community__c.split(';'));
                    }
                    if (Oldconlist.get(contact.Id).Professional_Communities__c != null) {
                        oldCommunityFields2.addAll(Oldconlist.get(contact.Id).Professional_Communities__c.split(';'));
                    }
                    
                    for (String oldCommunityField : oldCommunityFields2) {
                        if (communityToGroupMap.containsKey(oldCommunityField) &&
                            !communityFields2.contains(oldCommunityField)) {
                                deleteGroupMember(contact.Id, communityToGroupMap.get(oldCommunityField));
                            }
                    }
                }
            }
            insert groupMembersToCreate;
        }
        
    }
    private static Boolean groupMemberExists(Id contactId, Id communityGroupId) {
        List<PagesApi__Community_Group_Member__c> existingGroupMembers = [
            SELECT Id
            FROM PagesApi__Community_Group_Member__c
            WHERE PagesApi__Contact__c = :contactId
            AND PagesApi__Community_Group__c = :communityGroupId
        ];
        
        return !existingGroupMembers.isEmpty();
    } 
    private static void deleteGroupMember(Id contactId, Id communityGroupId) {
        List<PagesApi__Community_Group_Member__c> groupMembersToDelete = [
            SELECT Id
            FROM PagesApi__Community_Group_Member__c
            WHERE PagesApi__Contact__c = :contactId
            AND PagesApi__Community_Group__c = :communityGroupId
        ];
        
        delete groupMembersToDelete;
    }
}