/*
 *  Automatically generated and deployed by Hooked (aptk_hooked)
 *  DO NOT REMOVE THIS TRIGGER MANUALLY
 *  USE THE WEBHOOK BUILDER TO DELETE THIS TRIGGER
 */
trigger APTKHookedContactTrigger on Contact (before insert, before update,  before delete, after insert, after update, after delete, after undelete) {

    try { aptk_hooked.HookedTriggerHandler handler = new aptk_hooked.HookedTriggerHandler();
    handler.onCall(); } catch(Exception e) { System.debug(e); }
}