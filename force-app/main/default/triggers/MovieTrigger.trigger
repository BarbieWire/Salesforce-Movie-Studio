trigger MovieTrigger on Movie__c (after insert) {
    new MovieTriggerHandler().run();
}