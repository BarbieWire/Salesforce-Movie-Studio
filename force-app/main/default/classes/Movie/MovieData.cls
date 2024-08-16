public class MovieData {
    public List<Movie> movies;

    public class Movie {
        public String id;
        public String name;
        public String tmdb_id;
        public String genre;
        public Decimal rating;
        public Decimal budget;
        public Decimal actual_budget;
        public Decimal revenue;
        public Script script;
        public String release_date;
        public String status;
        public String poster_path;
    }

    public class Script {
        public String id;
        public String name;
        public String description;
    }
}