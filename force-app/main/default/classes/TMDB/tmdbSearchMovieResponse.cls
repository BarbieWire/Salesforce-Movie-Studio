public with sharing class tmdbSearchMovieResponse {
    public Integer page { get; set; }
    public List<tmdbSearchMovieResult> results { get; set; }
    public Integer total_pages { get; set; }
    public Integer total_results { get; set; }
}

