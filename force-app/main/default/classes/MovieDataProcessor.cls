public class MovieDataProcessor {
    @AuraEnabled
    public static Result processMovieData(Id fileId) {
        Result result = new Result();
        try {
            // Get file content
            ContentVersion fileVersion = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :fileId LIMIT 1];
            Blob fileBody = fileVersion.VersionData;
            String jsonContent = fileBody.toString();

            MovieServiceProvider movieProvider = new MovieServiceProvider();
            Integer createdMovieCount = movieProvider.importJSON(jsonContent);

            result.recordsLoaded = createdMovieCount;
            result.errorMessage = null;

            return result;
        } catch (Exception e) {
            result.errorMessage = e.getMessage();
        }
        return result;
    }

    public class Result {
        @AuraEnabled
        public Integer recordsLoaded;
        @AuraEnabled
        public String errorMessage;
    }
}
