import { LightningElement, wire } from 'lwc';

import getMenus
from '@salesforce/apex/COSMenuController.getMenus';

export default class CosNavbar extends LightningElement {

    menus = [];

    parentMenus = [];

    @wire(getMenus)
    wiredMenus({data,error}){

        if(data){

            this.menus = data;

            this.buildMenu();
        }

        if(error){

            console.log(error);
        }
    }

    buildMenu(){

        let parents = [];

        let subMenus = [];

        this.menus.forEach(menu => {

            if(menu.Parent_Menu__c){

                subMenus.push(menu);

            }else{

                parents.push({
                    label: menu.Menu_Label__c,
                    url: menu.Menu_URL__c,
                    subMenus: []
                });
            }
        });

        parents.forEach(parent => {

            subMenus.forEach(sub => {

                if(sub.Parent_Menu__c === parent.label){

                    parent.subMenus.push({
                        label: sub.Menu_Label__c,
                        url: sub.Menu_URL__c
                    });
                }
            });
        });

        this.parentMenus = parents;
    }
}