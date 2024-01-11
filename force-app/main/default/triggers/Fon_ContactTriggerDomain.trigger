trigger Fon_ContactTriggerDomain on Contact (after update, before update) {
     TriggerDispatcher.Run(new Fon_ContactTriggerHandler());

}