trigger ContactCommunityTrigger on Contact (after insert, after update, after delete) {
  if(Trigger.isAfter)
{
if(Trigger.isInsert)
{
    ContactCommunityTriggerHandler.Communitygroupmember(Trigger.new,Null);
}
if(Trigger.isUpdate)
{
     ContactCommunityTriggerHandler.Communitygroupmember(Trigger.new,Trigger.oldmap);
}
/*if(Trigger.isDelete)
{
}
    if((trigger.isBefore) &&(trigger.isUpdate)){
          ContactCommunityTriggerHandler.DeleteCommunitygroupmember(Trigger.new,Trigger.OldMap);
  
    }*/
}

}