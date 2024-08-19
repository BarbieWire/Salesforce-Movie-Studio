import { LightningElement, track, api } from 'lwc';
import processMovieData from '@salesforce/apex/MovieDataProcessor.processMovieData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MovieDataUploader extends LightningElement {
    @api recordId; // if the component is on a specific record page
    @track toastMessage;
    @track toastTitle;
    @track toastVariant;
    @track isProcessing = false;
    @track documentIds = []; 

    filesUploaded;
    uploadedFileLength;

    connectedCallback() {

    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            // Assuming only one file is uploaded
            this.documentIds = uploadedFiles.map(file => file.documentId)
            this.uploadedFileLength = event.detail.files.length
            this.filesUploaded = true;
        }
    }

    handleProcessData() {
        if (!this.documentIds.length) {
            this.showToast('Error', 'No file uploaded', 'error');
            return;
        }   

        this.isProcessing = true;
        for (const id of this.documentIds) {
            processMovieData({ fileId: id })
            .then(result => {
                this.isProcessing = false;
                this.showToast('Success', `${result.recordsLoaded} records loaded`, 'success');
            })
            .catch(error => {
                this.isProcessing = false;
                this.showToast('Error', `Failed to process data: ${error.body.message}`, 'error');
            });
        }
    }

    showToast(title, message, variant) {
        this.toastTitle = title;
        this.toastMessage = message;
        this.toastVariant = variant;
        this.dispatchEvent(new ShowToastEvent({
            title: this.toastTitle,
            message: this.toastMessage,
            variant: this.toastVariant,
        }));
    }
}
