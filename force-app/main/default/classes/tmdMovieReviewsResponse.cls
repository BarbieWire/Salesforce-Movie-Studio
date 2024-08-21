public with sharing class tmdMovieReviewsResponse {
    public Integer id { get; set; }
    public Integer page { get; set; }
    public List<Review> results { get; set; }

    public class Review {
        public String author { get; set; }
        public AuthorDetails author_details { get; set; }
        public String content { get; set; }
        public String id { get; set; }
    }

    public class AuthorDetails {
        public String name { get; set; }
        public String username { get; set; }
        public String avatar_path { get; set; }
        public Decimal rating { get; set; }
    }
}