import { LightningElement, wire } from 'lwc';

import getCosBanner from '@salesforce/apex/CosBannerController.getCosBanner';

export default class CosHeader extends LightningElement {

    bannerMessage;

    @wire(getCosBanner)
    wiredBanner({data,error}){

        if(data){

            this.bannerMessage = data;
        }
    }
}