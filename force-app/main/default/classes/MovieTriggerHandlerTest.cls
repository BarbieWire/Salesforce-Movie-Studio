@isTest
public class MovieTriggerHandlerTest {

    // Helper method to create movie records
    private static List<Movie__c> createMovieRecords(Integer numRecords, String tmdbIdPrefix) {
        List<Movie__c> movieList = new List<Movie__c>();
        for (Integer i = 0; i < numRecords; i++) {
            Movie__c movie = new Movie__c(
                Title__c = 'Test Movie' + i, 
                TMDBid__c = tmdbIdPrefix,
                Description__c = 'Old Description',
                Revenue__c = 10000, 
                Budget__c = 5000,
                Rating__c = 5.0, 
                Poster__c = '/oldposter.jpg'
            );
            movieList.add(movie); // Add movie to the list
        }
        return movieList;
    }

    @isTest
    static void testAfterInsert_withValidTMDBid() {
        Test.setMock(HttpCalloutMock.class, new MockTmdbCallout());

        List<Movie__c> movies = createMovieRecords(2, '9437');
        insert movies;

        Test.startTest();
        List<Movie__c> insertedMovies = [SELECT Id, TMDBid__c FROM Movie__c WHERE TMDBid__c = '9437'];
        Test.stopTest();

        List<Movie__c> updatedMovies = [SELECT TMDBid__c, Description__c, Title__c, Revenue__c, Rating__c, Poster__c, Budget__c 
                                        FROM Movie__c 
                                        WHERE TMDBid__c = '9437'];
        
        for (Movie__c updatedMovie : updatedMovies) {
            System.assertEquals('Test Description', updatedMovie.Description__c, 'Description__c should be updated');
            System.assertEquals('Test Title', updatedMovie.Title__c, 'Title__c should be updated');
            System.assertEquals('/testposter.jpg', updatedMovie.Poster__c, 'Poster__c should be updated');

            System.assertEquals(500000, updatedMovie.Revenue__c, 'Revenue__c should be updated');
            System.assertEquals(7.5, updatedMovie.Rating__c, 'Rating__c should be updated');
            System.assertEquals(200000, updatedMovie.Budget__c, 'Budget__c should be updated');
        }
    }

    @isTest
    static void testAfterInsert_withInvalidTMDBid() {
        Test.setMock(HttpCalloutMock.class, new MockTmdbErrorCallout());
        List<Movie__c> movies = createMovieRecords(2, '9437');

        Test.startTest();

        try {
            insert movies;
            System.assert(false, 'MovieTriggerHandler.afterInsert should throw a CalloutException');
        } catch (Exception e) {
            System.assert(e instanceof CalloutException, 'MovieTriggerHandler.afterInsert threw a CalloutException');
        }
        
        Test.stopTest();
    }

    // @isTest
    // static void testAfterUpdate_TMDBidChanged() {
    //     // Test the afterUpdate method when TMDBid__c is updated

    //     String newTMDBId = '9437';

    //     List<Movie__c> movies = new List<Movie__c>{
    //         new Movie__c(Title__c = 'Test Movie 1', TMDBid__c = '9778', Description__c = 'Description 1'),
    //         new Movie__c(Title__c = 'Test Movie 2', TMDBid__c = '9778', Description__c = 'Description 2')
    //     };
    //     insert movies;

    //     Test.startTest();
    //     List<Movie__c> insertedMovies = [SELECT Id, Title__c, TMDBid__c, Description__c FROM Movie__c WHERE Title__c LIKE 'Test Movie%'];
    //     for (Movie__c movie : insertedMovies) {
    //         movie.TMDBid__c = newTMDBId;
    //     }
    //     update insertedMovies;

    //     List<Movie__c> updatedMovies = [SELECT Id, Title__c, TMDBid__c, Description__c FROM Movie__c WHERE Title__c LIKE 'Test Movie%'];
    //     Test.stopTest();

    //     /// Step 5: Assertions
    //     for (Integer i = 0; i < updatedMovies.size(); i++) {
    //         System.assertEquals(newTMDBId, updatedMovies[i].TMDBid__c, 'TMDBid__c should be updated to 9437.');
    //         System.assertNotEquals(insertedMovies[i].Description__c, updatedMovies[i].Description__c, 'Description__c should be changed.');
    //         System.assertNotEquals(insertedMovies[i].Title__c, updatedMovies[i].Title__c, 'Title__c should be changed.');
    //     }
    // }
}