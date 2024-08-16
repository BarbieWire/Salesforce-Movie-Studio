import { LightningElement, api } from 'lwc';

export default class MovieCard extends LightningElement {
    @api poster;
    @api rating;
    @api genre;
    @api title;
}