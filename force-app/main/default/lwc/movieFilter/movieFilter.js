import { LightningElement, track } from 'lwc';
import getMoviesByGenre from '@salesforce/apex/MovieCatalogController.getMoviesByGenre';
import getGenrePicklistValues from '@salesforce/apex/MovieCatalogController.getGenrePicklistValues';

export default class MovieFilter extends LightningElement {
    @track selectedGenre = '';
    @track filteredMovies = [];
    @track genreOptions = [];

    connectedCallback() {
        this.fetchGenreOptions();
    }

    // Fetch genre picklist values from Apex
    fetchGenreOptions() {
        getGenrePicklistValues()
            .then(result => {
                // Use the result to populate the combobox options
                this.genreOptions = result.map(genre => {
                    return { label: genre.label, value: genre.value };
                });
            })
            .catch(error => {
                console.error('Error fetching genre picklist values:', error);
            });
    }

    handleGenreChange(event) {
        this.selectedGenre = event.detail.value;
    }

    filterMovies() {
        getMoviesByGenre({ genre: this.selectedGenre })
            .then(result => {
                this.filteredMovies = result;
            })
            .catch(error => {
                console.error('Error retrieving movies:', error);
            });
    }
}
