public with sharing class MovieCatalogController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getGenrePicklistValues() {
        List<Map<String, String>> genreOptions = new List<Map<String, String>>();
        
        Schema.DescribeFieldResult fieldResult = Movie__c.Genre__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistEntries) {
            Map<String, String> genreOption = new Map<String, String>();
            genreOption.put('label', entry.getLabel());
            genreOption.put('value', entry.getValue());
            genreOptions.add(genreOption);
        }
        
        return genreOptions;
    }

    @AuraEnabled(cacheable=true)
    public static List<Movie__c> getMoviesByGenre(String genre) {
        return [SELECT Id, Title__c, Genre__c FROM Movie__c WHERE Genre__c = :genre];
    }
}
