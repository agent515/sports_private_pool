const admin = require('firebase-admin');

const calculateResult = require('./calculateResult');
const payment = require('./payment/payment');
const userJoinsContest = require('./notifications/userJoinsContest');

var serviceAccount = require("./envision-sports-firebase-adminsdk-j8lj1-5f54cd31ea.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://envision-sports.firebaseio.com",
});

exports.customFunctions = payment.customFunctions;
exports.calculate_result = calculateResult.calculate_result;
exports.userJoinsContest = userJoinsContest.userJoinsContest;