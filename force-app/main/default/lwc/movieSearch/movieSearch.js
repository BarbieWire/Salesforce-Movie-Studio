import { LightningElement, track, api } from 'lwc';

import searchMovie from '@salesforce/apex/TMDBIntegration.searchMovie';
import getMovieTitle from '@salesforce/apex/TMDBIntegration.getMovieTitle';
import getOfficialGenres from '@salesforce/apex/TMDBIntegration.getOfficialGenres';
import updateMovieRecord from '@salesforce/apex/TMDBIntegration.updateMovieRecord';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class MovieSearch extends LightningElement {
    @api recordId;
    @track movieTitle = '';
    @track searchResults = [];
    @track officialGenres = {};
    @track message = '';

    @track selectedMovie = null;

    handleButtonClick(event) {
        const movieId = event.target.dataset.id;
        this.selectedMovie = this.searchResults.find(movie => movie.record_id === parseInt(movieId, 10));
        this.saveMovieRecord();
    }
    
    saveMovieRecord() {
        if (this.selectedMovie && this.recordId) {
            const genres = this.selectedMovie.genre_ids.map(id => this.officialGenres[id]);
            const movie = {...this.selectedMovie, genres: genres};

            updateMovieRecord({
                movieNewData: movie,
                recordId: this.recordId
            })
                .then(() => {
                    this.showToast('Success', 'Movie data saved successfully!', 'success');
                    console.log('Record updated successfully');
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to save movie data.', 'error');
                    console.error('Error updating movie record:', error);
                });
        } else {
            this.showToast('Error', 'No movie selected or record ID missing.', 'error');
        }
    }

    connectedCallback() {
        getMovieTitle({ recordId: this.recordId })
            .then(result => {
                this.movieTitle = result;
            })

        getOfficialGenres()
            .then(result => {
                this.officialGenres = result;
            })
            .catch(error => {
                console.error('Error retrieving official genres:', error);
                this.message = 'Error retrieving official genres from server.';
            });
    }

    handleTitleChange(event) {
        this.movieTitle = event.target.value;
    }

    searchMovies() {
        if (!this.movieTitle) {
            this.showToast('Error', 'Please Provide Title', 'error');
            return;
        }

        searchMovie({ title: this.movieTitle })
            .then(result => {
                this.searchResults = result;
                this.message = '';
            })
            .catch(error => {
                console.error('Error searching movies:', error);
                this.message = 'Error searching for movies. Please try again.';
            });
    }

    handleRowAction(event) {
        const selectedRow = event.detail.row;
        this.copyMovieData(selectedRow);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }
}
