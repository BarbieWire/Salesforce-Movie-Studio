import { LightningElement, api, track } from 'lwc';
import getReviewsByMovieId from '@salesforce/apex/TMBDIntegrationController.getReviewsByMovieId';
import { NavigationMixin } from 'lightning/navigation';


export default class MovieReviews extends NavigationMixin(LightningElement) {
    @api recordId;
    @track reviews;
    @track error;

    pageSize = 3; 
    @track currentPage = 1;

    defaultImageURL = 'https://via.placeholder.com/150';

    connectedCallback() {
        this.loadReviews();
    }

    trimComment(comment) {
        const maxLength = 500;
        if (comment.length > maxLength) {
            return comment.substring(0, maxLength) + '...';
        }
        return comment;
    }

    get trimmedReviews() {
        return this.reviews.map(review => ({
            ...review,
            trimmedComment: this.trimComment(review.Comment__c)
        }));
    }

    get paginatedReviews() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.trimmedReviews.slice(start, end);
    }

    get totalPages() {
        return Math.ceil(this.reviews.length / this.pageSize);
    }

    get hasPreviousPage() {
        return !(this.currentPage > 1);
    }

    get hasNextPage() {
        return !(this.currentPage < this.totalPages);
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.scrollToTop();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.scrollToTop();
        }
    }

    scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }
    
    loadReviews() {
        if (!this.recordId) {
            console.error('RecordId is not available.');
            return;
        }

        getReviewsByMovieId({ movieId: this.recordId })
            .then(result => {
                console.log('Data:', result);
                this.reviews = result;
                this.error = undefined;
            })
            .catch(error => {
                console.error('Error:', error);
                this.error = error;
                this.reviews = undefined;
            });
    }

    handleTitleClick(event) {
        const reviewId = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: reviewId,
                objectApiName: 'Review__c',
                actionName: 'view'
            }
        });
    }
}
