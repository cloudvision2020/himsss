trigger ContactCoummnityHoursTrigger on Contact (after insert, after update, after delete) {
     TriggerDispatcher.Run(new ContactCommunityHoursTriggerHandler());

}