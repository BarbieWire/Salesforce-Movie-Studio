trigger MovieTrigger on Movie__c (after insert, after update) {
    if (TriggerControl.isTriggerDisabled) {
        return;
    }
    
    new MovieTriggerHandler().run();
}