import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class MovieCard extends NavigationMixin(LightningElement) {
    @api poster;
    @api rating;
    @api genre;
    @api title;
    @api id;

    @track isHorror = false;

    connectedCallback() {
        let genres = this.genre.split(";")
        let containsHorror = genres.includes("Horror")

        if (containsHorror) {
            this.isHorror = true;
        }
    }

    handleDetailsClick() {
        const cleanRecordId = (recordId) => recordId.split('-')[0];

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: cleanRecordId(this.id),
                objectApiName: 'Movie__c',  
                actionName: 'view'
            }
        });
    }
}