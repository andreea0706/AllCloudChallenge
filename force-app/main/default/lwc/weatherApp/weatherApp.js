import { LightningElement, api, wire } from 'lwc';
import checkWeather from "@salesforce/apex/MeteoAppController.checkWeather";
import getGeoCoordinates from "@salesforce/apex/MeteoAppController.getGeoCoordinates";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord , updateRecord} from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import CITY_FIELD from "@salesforce/schema/Account.City__c";
import COUNTRY_FIELD from "@salesforce/schema/Account.Country__c";
import POST_CODE_FIELD from "@salesforce/schema/Account.PostCode__c";
import STREET_FIELD from "@salesforce/schema/Account.Street__c";
import ID_FIELD from "@salesforce/schema/Account.Id";

const fields = [CITY_FIELD, COUNTRY_FIELD, POST_CODE_FIELD, STREET_FIELD];

export default class WeatherApp extends LightningElement {

    @api recordId;
   
    showData;
    displayText;
    isLoading;

    maxTemp;
    minTemp;
    meteoCode;

    address = '';
    addressForDisplay = '';
    postCode = '';
    street = '';
    city = '';
    country = '';

    latitude;
    longitude;
    record;


    @wire(getRecord, { recordId: "$recordId", fields })
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
            let postCodeFromRecord = data?.fields?.PostCode__c?.value !== null ? data.fields.PostCode__c.value : '';
            let streetFromRecord = data?.fields?.Street__c?.value !== null ? data.fields.Street__c.value : '';
            let cityFromRecord = data?.fields?.City__c?.value !== null ? data.fields.City__c.value : '';
            let countryFromRecord = data?.fields?.Country__c?.value !== null ? data.fields.Country__c.value : '';
            this.addressForDisplay = cityFromRecord + ' ' + streetFromRecord + ' ' + countryFromRecord;

            this.buildAddress(postCodeFromRecord, streetFromRecord, cityFromRecord, countryFromRecord);
            if (this.address !== '') {
                this.displayText = undefined;
                this.getMeteoConditions();
            } else {
                this.displayText = 'Please provide an address to show tomorrow\'s meteo conditions';
            }
        } else if (error) {
            console.log(error);
        }
    }

    handleChangePostCode(event) {
        this.address = '';
        this.postCode = event.target.value;
    }

    handleChangeStreet(event) {
        this.address = '';
        this.street = event.target.value;
    }

    handleChangeCity(event) {
        this.address = '';
        this.city = event.target.value;
    }

    handleChangeCountry(event) {
        this.address = '';
        this.country = event.target.value;
    }

    async handleClick() {
        this.buildAddress(this.postCode, this.street, this.city, this.country);
        if (this.address !== undefined && this.address !== '') {
            this.displayText = undefined;
            this.isLoading = true;
            this.getMeteoConditions();
            this.updateAddress();
        } else {
            this.showNotification('Address invalid', 'Please insert a valid address!', 'error');
        }
    }

    async getMeteoConditions() {
        let googleResponse = await getGeoCoordinates({address: this.address})
        let respObj = JSON.parse(googleResponse);

        if (respObj?.results !== undefined && respObj?.status !== undefined && respObj.status == 'OK') {
            this.latitude = respObj.results[0]?.geometry?.location?.lat;
            this.longitude = respObj.results[0]?.geometry?.location?.lng;

            if (this.latitude !== undefined && this.longitude !== undefined) {
                let response = await checkWeather({ latitude: this.latitude, longitude: this.longitude });
    
                if (response != null && response?.length > 0) {
                    this.maxTemp = response[1]?.maxTemp;
                    this.minTemp = response[1]?.minTemp;
                    this.meteoCode = response[1]?.weatherCode;
                    this.clearDataForNextSearch();
                    this.isLoading = false;
                    this.showData = true;
                } else {
                    console.log('check Weather conditions');
                    console.log(response);
                    this.isLoading = false;
                    this.showNotification( "Error", "There was an error provisioning meteo conditions. Please try again!", "error");
                }
            }
        } else {
            console.log('Get google coords');
            console.log(googleResponse);
            this.isLoading = false;
            this.showNotification( "Error", "There was an error provisioning meteo conditions. Please try again!", "error");
        }
    }

    buildAddress(postCode, street, city, country) {
        this.latitude = undefined;
        this.longitude = undefined;
        this.address = (postCode !== undefined && postCode !== '') ? postCode : this.address;
        this.address = (street !== undefined && street !== '') ? this.address + '+' + street : this.address;
        this.address = (city !== undefined && city !== '') ? this.address + '+' + city : this.address;
        this.address = (country !== undefined && country !== '') ? this.address + '+' + country : this.address;
    }

    showNotification(titleText, messageText, variant) {
        const evt = new ShowToastEvent({
          title: titleText,
          message: messageText,
          variant: variant,
        });
        this.dispatchEvent(evt);
    }

    updateAddress() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[CITY_FIELD.fieldApiName] = this.city;
        fields[COUNTRY_FIELD.fieldApiName] = this.country;
        fields[POST_CODE_FIELD.fieldApiName] = this.postCode;
        fields[STREET_FIELD.fieldApiName] = this.street;
  
        const recordInput = { fields };
  
        updateRecord(recordInput)
          .then(() => {
            this.showNotification( "Success", "Address updated sucessfully!", "success");
            return refreshApex(this.record);
          })
          .catch((error) => {
            this.isLoading = false;
            this.showNotification( "Error updating record", error.body.message, "error");
            
          });
    }

    clearDataForNextSearch() {
        this.city = '';
        this.country = '';
        this.street = '';
        this.postCode = '';
    }

}