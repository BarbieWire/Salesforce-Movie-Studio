import { LightningElement, track } from 'lwc';
import getMoviesByGenre from '@salesforce/apex/MovieCatalogController.getMoviesByGenre';
import getGenrePicklistValues from '@salesforce/apex/MovieCatalogController.getGenrePicklistValues';

export default class MovieFilter extends LightningElement {
    @track selectedGenre = '';
    @track filteredMovies = [];
    @track genreOptions = [];
        
    @track limitSize = 10;
    @track limitSizeDisplay = '10';
    @track offsetSize = 0;

    // Default limit options for the user to choose from
    @track limitOptions = [
        { label: '10', value: '10' },
        { label: '20', value: '20' },
        { label: '50', value: '50' }
    ];

    connectedCallback() {
        this.fetchGenreOptions();
        this.fetchMovies();
    }

    // Fetch genre picklist values from Apex
    fetchGenreOptions() {
        getGenrePicklistValues()
            .then(result => {
                this.genreOptions = result.map(genre => ({
                    label: genre.label,
                    value: genre.value
                }));
            })
            .catch(error => {
                console.error('Error fetching genre picklist values:', error);
            });
    }

    handleGenreChange(event) {
        this.selectedGenre = event.detail.value;
        this.offsetSize = 0;
    }

    handleLimitChange(event) {
        this.limitSize = parseInt(event.detail.value, 10);
        this.limitSizeDisplay = event.detail.label;
        this.offsetSize = 0;
    }

    fetchMovies() {
        if (!this.selectedGenre) {
            return;
        }

        getMoviesByGenre({ 
            genre: this.selectedGenre, 
            limitSize: this.limitSize, 
            offsetSize: this.offsetSize 
        })
        .then(result => {
            this.filteredMovies = result;
        })
        .catch(error => {
            console.error('Error retrieving movies:', error);
        });
    }

    handleNext() {
        this.offsetSize += this.limitSize;
        this.fetchMovies();
    }

    handlePrevious() {
        if (this.offsetSize > 0) {
            this.offsetSize -= this.limitSize;
            this.fetchMovies();
        }
    }
}
