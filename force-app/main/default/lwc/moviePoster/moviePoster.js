import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Movie__c.Poster__c'
];

export default class MoviePoster extends LightningElement {
    @api recordId;
    posterUrl;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record({ error, data }) {
        if (data) {
            this.posterUrl = data.fields.Poster__c.value;
        } else if (error) {
            // Handle error case
            console.error(error);
        }
    }
}