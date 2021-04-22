const functions = require("firebase-functions");

const express = require("express");
const checksum_lib = require("./checksum.js");

var app = express();
app.use(express.json());
app.use(express.urlencoded({
    extended: true
}));

//PAYTM CONFIGURATION
var PaytmConfig = {
    mid: "KglSma28503920757612",
    key: "QxHV%kbw23KJC_&2",
    website: "WEBSTAGING"
};

var txn_url = "https://securegw-stage.paytm.in/order/process"; // for staging
// var txn_url = "https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?mid={mid}&orderId={order-id}";

// var callbackURL = "YOUR_CALLBACK_URL/paymentReceipt";
// var callbackURL = " https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=<order_id>";
var callbackURL = "http://10.0.2.2:5001/envision-sports/us-central1/customFunctions/paymentReceipt";
// var callbackURL = 'https://asia-south1-envision-sports.cloudfunctions.net/paymentReceipt'

//CORS ACCESS CONTROL
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Controle-Allow-Methods", "Post, Get");
    res.header(
        "Access-Control-Allow-Headers",
        "Origin, X-Requested-With, Content-Type, Accept"
    );
    next();
});

app.post("/payment", (req, res) => {
    let paymentData = req.body;
    var params = {};
    params["MID"] = PaytmConfig.mid;
    params["WEBSITE"] = PaytmConfig.website;
    params["CHANNEL_ID"] = "WEB";
    params["INDUSTRY_TYPE_ID"] = "Retail";
    params["ORDER_ID"] = paymentData.orderID;
    params["CUST_ID"] = paymentData.custID;
    params["TXN_AMOUNT"] = paymentData.amount;
    params["CALLBACK_URL"] = callbackURL;
    params["EMAIL"] = paymentData.custEmail;
    params["MOBILE_NO"] = paymentData.custPhone;

    checksum_lib.genchecksum(params, PaytmConfig.key, (err, checksum) => {
        if (err) {
            console.log("Error: " + e);
        }

        var form_fields = "";
        for (var x in params) {
            form_fields +=
                "<input type='hidden' name='" + x + "' value='" + params[x] + "' >";
        }
        form_fields +=
            "<input type='hidden' name='CHECKSUMHASH' value='" + checksum + "' >";

        res.writeHead(200, { "Content-Type": "text/html" });
        res.write(
            '<html><head><title>Merchant Checkout Page</title></head><body><center><h1>Please do not refresh this page...</h1></center><form method="post" action="' +
            txn_url +
            '" name="f1">' +
            form_fields +
            '</form><script type="text/javascript">document.f1.submit();</script></body></html>'
        );
        res.end();
    });
});

app.post("/paymentReceipt", (req, res) => {
    let responseData = req.body;
    var checksumhash = responseData.CHECKSUMHASH;
    var result = checksum_lib.verifychecksum(
        responseData,
        PaytmConfig.key,
        checksumhash
    );
    if (result) {
        return res.send({
            status: 0,
            data: responseData
        });
    } else {
        return res.send({
            status: 1,
            data: responseData
        });
    }
});

exports.customFunctions = functions.https.onRequest(app);