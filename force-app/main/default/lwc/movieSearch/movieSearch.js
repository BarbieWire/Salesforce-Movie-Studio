import { LightningElement, track, api } from 'lwc';

import searchMovie from '@salesforce/apex/TMBDIntegrationController.searchMovie';
import getTitleOfExistingRecord from '@salesforce/apex/TMBDIntegrationController.getTitleOfExistingRecord';
import updateMovieRecord from '@salesforce/apex/TMBDIntegrationController.updateMovieRecord';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class MovieSearch extends LightningElement {
    @api recordId;
    @track message = '';

    @track movieTitle = '';

    @track searchResults = [];
    @track selectedMovie = null;

    handleButtonClick(event) {
        const movieId = event.target.dataset.id;
        this.selectedMovie = this.searchResults.find(movie => movie.record_id === parseInt(movieId, 10));
        this.saveMovieRecord();
    }
    
    saveMovieRecord() {
        if (this.selectedMovie && this.recordId) {
            updateMovieRecord({
                movieNewData: this.selectedMovie,
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
        getTitleOfExistingRecord({ recordId: this.recordId })
            .then(result => {
                this.movieTitle = result;
            })
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
