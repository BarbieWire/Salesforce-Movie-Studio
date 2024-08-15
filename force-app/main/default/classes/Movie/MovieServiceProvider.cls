public with sharing class MovieServiceProvider {
    @future(callout=true)
    public static void updateMovieRecords(Set<Id> movieIds) {
        List<Movie__c> moviesToUpdate = new List<Movie__c>();
        
        for (String movieId : movieIds) {
            Movie__c movie = [SELECT Id, TMDBid__c, Description__c, Title__c, Revenue__c, 
                  Rating__c, Poster__c, Budget__c
                  FROM Movie__c WHERE Id = :movieId LIMIT 1];

            tmdb tmdbClient = new tmdb();
            tmdMovieDetailResponse result = tmdbClient.movieDetailResponse(movie.TMDBid__c);

            movie.Description__c = result.overview;
            movie.Title__c = result.original_title;
            movie.Revenue__c = result.revenue;
            movie.Rating__c = result.vote_average;
            movie.Poster__c = result.poster_path;
            movie.Budget__c = result.budget;
            movie.TMDBSyncDate__c = Date.today();

            moviesToUpdate.add(movie);
        }

        update moviesToUpdate;
    }

    public void importJSON(String jsonString) {
        // Disable triggers on import
        TriggerControl.isTriggerDisabled = true;

        try {
            // Lists to store records to be inserted
            List<Movie__c> moviesToInsert = new List<Movie__c>();
            List<Script__c> scriptsToInsert = new List<Script__c>();
            List<Script__c> scriptsToUpdate = new List<Script__c>();

            // Maps to check existing records
            Map<String, Movie__c> existingMoviesMap = new Map<String, Movie__c>();
            Map<String, Script__c> existingScriptsMap = new Map<String, Script__c>();
            Map<String, String> scriptIdMap = new Map<String, String>();
            Map<String, String> movieScriptIdMap = new Map<String, String>();

            // Fetch existing movies and scripts
            fetchExistingRecords(existingMoviesMap, existingScriptsMap);

            // Parse the JSON
            List<MovieData.Movie> movieList = (List<MovieData.Movie>) JSON.deserialize(jsonString, List<MovieData.Movie>.class);

            // Process movies and scripts
            processMoviesAndScripts(movieList, existingMoviesMap, existingScriptsMap, moviesToInsert, scriptsToInsert, scriptsToUpdate, scriptIdMap);

            // Insert records
            insertRecords(moviesToInsert, scriptsToInsert, scriptsToUpdate, scriptIdMap, movieScriptIdMap);
        } finally {
            // Re-enable triggers
            TriggerControl.isTriggerDisabled = false;
        }
    }

    // Method to fetch existing Movies and Scripts
    private void fetchExistingRecords(Map<String, Movie__c> existingMoviesMap, Map<String, Script__c> existingScriptsMap) {
        // Query existing movies and scripts
        for (Movie__c movie : [SELECT tmdbId__c, LegacyId__c FROM Movie__c]) {
            existingMoviesMap.put(movie.tmdbId__c, movie);
        }

        for (Script__c script : [SELECT LegacyId__c, Id FROM Script__c]) {
            existingScriptsMap.put(script.LegacyId__c, script);
        }
    }

    // Method to process Movies and Scripts from the parsed JSON
    private void processMoviesAndScripts(
        List<MovieData.Movie> movieList,
        Map<String, Movie__c> existingMoviesMap,
        Map<String, Script__c> existingScriptsMap,
        List<Movie__c> moviesToInsert,
        List<Script__c> scriptsToInsert,
        List<Script__c> scriptsToUpdate,
        Map<String, String> scriptIdMap
    ) {
        for (MovieData.Movie movieData : movieList) {
            // Check if the movie already exists by tmdb_id
            if (!existingMoviesMap.containsKey(movieData.tmdb_id)) {
                Movie__c newMovie = createNewMovie(movieData);

                // Handle script data
                handleScriptData(movieData, existingScriptsMap, scriptsToInsert, scriptsToUpdate, scriptIdMap);

                moviesToInsert.add(newMovie);
            }
        }
    }

    // Method to create new Movie__c record
    private Movie__c createNewMovie(MovieData.Movie movieData) {
        Movie__c newMovie = new Movie__c();
        newMovie.LegacyId__c = movieData.id;
        newMovie.Title__c = movieData.name;
        newMovie.tmdbId__c = movieData.tmdb_id;
        newMovie.genre__c = movieData.genre;
        newMovie.rating__c = movieData.rating;
        newMovie.budget__c = movieData.budget;
        newMovie.Revenue__c = movieData.revenue;
        newMovie.Description__c = movieData.script != null ? movieData.script.description : null;

        // Date conversion with try-catch
        if (movieData.release_date != null) {
            try {
                // Parse string and convert date format from dd/MM/yyyy to yyyy-MM-dd
                String release = movieData.release_date.replaceAll('(\\d{1,2})\\/(\\d{1,2})\\/(\\d{4})', '$3-$2-$1');
                newMovie.ReleaseDate__c = Date.valueOf(release);
            } catch (Exception e) {
                System.debug('Invalid date format for movie: ' + movieData.name);
            }
        }
        return newMovie;
    }

    // Method to handle the Script data
    private void handleScriptData(
        MovieData.Movie movieData,
        Map<String, Script__c> existingScriptsMap,
        List<Script__c> scriptsToInsert,
        List<Script__c> scriptsToUpdate,
        Map<String, String> scriptIdMap
    ) {
        if (movieData.script != null) {
            Script__c script;
            if (existingScriptsMap.containsKey(movieData.script.id)) {
                // Use existing script
                script = existingScriptsMap.get(movieData.script.id);
                scriptsToUpdate.add(script);
            } else {
                // Create new script record
                script = new Script__c();
                script.LegacyId__c = movieData.script.id;
                script.Title__c = movieData.script.name;
                script.Description__c = movieData.script.description;
                scriptsToInsert.add(script);
            }

            scriptIdMap.put(movieData.id, movieData.script.id);
        }
    }

    // Method to insert and update records
    private void insertRecords(
        List<Movie__c> moviesToInsert,
        List<Script__c> scriptsToInsert,
        List<Script__c> scriptsToUpdate,
        Map<String, String> scriptIdMap,
        Map<String, String> movieScriptIdMap
    ) {
        // Insert scripts first to get their Ids
        if (!scriptsToInsert.isEmpty()) {
            insert scriptsToInsert;
        }

        scriptsToInsert.addAll(scriptsToUpdate);
        for (Script__c script : scriptsToInsert) {
            movieScriptIdMap.put(script.LegacyId__c, script.Id);
        }

        // Assign the correct Script__c Ids to movies before inserting them
        for (Movie__c movie : moviesToInsert) {
            if (scriptIdMap.containsKey(movie.LegacyId__c)) {
                movie.Script__c = movieScriptIdMap.get(scriptIdMap.get(movie.LegacyId__c));
            }
        }

        // Insert movies
        if (!moviesToInsert.isEmpty()) {
            insert moviesToInsert;
        }
    }
}
