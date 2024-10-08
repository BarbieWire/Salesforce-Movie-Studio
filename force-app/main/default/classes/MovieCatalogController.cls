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
    public static Integer getMoviesCountByGenre(String genre) {
        String query = 'SELECT COUNT() FROM Movie__c';
        
        if (genre != 'all') {
            query += ' WHERE Genre__c INCLUDES (:genre)'; 
        }

        Integer result = Database.countQuery(query);
        return result;
    }


    @AuraEnabled(cacheable=true)
    public static List<Movie__c> getMoviesByGenre(String genre, Integer limitSize, Integer offsetSize) {
        String query = 'SELECT Id, Title__c, RatingCalculated__c, Genre__c, Poster__c FROM Movie__c';
        if (genre != 'all') {
            query += ' WHERE Genre__c INCLUDES (:genre)';
        }

        query += ' ORDER BY Title__c';
        query += ' LIMIT :limitSize OFFSET :offsetSize';

        return Database.query(query);
    }
}
