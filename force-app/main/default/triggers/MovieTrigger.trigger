trigger MovieTrigger on Movie__c (after insert, after update) {
    new MovieTriggerHandler().run();
}