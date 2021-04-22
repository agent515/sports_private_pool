 module.exports = {
   paytm_config: {
     PAYTM_ENVIRONMENT: 'TEST', //possible values:  TEST | PROD
     MID: 'KglSma28503920757612', // Get it From https://dashboard.paytm.com/next/apikeys use Test id for test purpose and Production id for Production Purpose
     WEBSITE: 'WEBSTAGING', // USE WEBSTAGING for testing, You Will get it for Production here https://dashboard.paytm.com/next/apikeys
     CHANNEL_ID: 'WAP', // Use WEB for Desktop Website and WAP for Mobile Website
     INDUSTRY_TYPE_ID: 'Retail', // Use Retail for Testing, For Production You Can Get it from here https://dashboard.paytm.com/next/apikeys
     MERCHANT_KEY: 'QxHV%kbw23KJC_&2', // Get it From https://dashboard.paytm.com/next/apikeys use Test key for test purpose and Production key for Production Purpose
     CALLBACK_URL: 'https://asia-south1-envision-sports.cloudfunctions.net/DonationCallback', // Modify and Use this url for verifying payment, we will use cloud function DonationCallback function for Our usage

     // Additional Config

    //  MinAmount: 100, // Munimum amount you waana accept for donation
    //  PaymentInitURL: 'http://myblogurl/donateViaPaytm', // Initial Location where the payment begin
    //  PaymentSuccessURL: 'http://myblogurl/donationSuccessful', // Success Page URL
    //  PaymentFailureURL: 'http://myblogurl/donationFailture' // Failture page URL

   }
  }