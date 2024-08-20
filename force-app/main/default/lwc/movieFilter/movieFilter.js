import { LightningElement, track } from 'lwc';
import getMoviesByGenre from '@salesforce/apex/MovieCatalogController.getMoviesByGenre';
import getMoviesCountByGenre from '@salesforce/apex/MovieCatalogController.getMoviesCountByGenre';
import getGenrePicklistValues from '@salesforce/apex/MovieCatalogController.getGenrePicklistValues';

export default class MovieFilter extends LightningElement {
    @track selectedGenre = '';
    @track filteredMovies = [];
    @track genreOptions = [];
        
    @track limitSize = 10;
    @track limitSizeDisplay = '10';
    @track offsetSize = 0;

    @track totalMovieCount;

    get displayPagination() {
        return !!this.filteredMovies.length;
    }

    get isFirstPage() {
        return this.offsetSize === 0;
    }

    get isLastPage() {
        return this.offsetSize + this.filteredMovies.length >= this.totalMovieCount;
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

    @track limitOptions = [
        { label: '10', value: '10' },
        { label: '20', value: '20' },
        { label: '50', value: '50' }
    ];

    connectedCallback() {
        this.fetchGenreOptions();
        this.fetchMovies();
    }

    fetchTotalMovieCount() {
        getMoviesCountByGenre({ genre: this.selectedGenre })
            .then(result => {
                this.totalMovieCount = result;
            })
            .catch(error => {
                console.error('Error fetching total movie count:', error);
            });
    }

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
        this.fetchTotalMovieCount();
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
}
