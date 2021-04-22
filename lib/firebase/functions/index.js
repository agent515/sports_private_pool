const admin = require('firebase-admin');

const calculateResult = require('./calculateResult');
const payment = require('./payment');

admin.initializeApp();

exports.customFunctions = payment.customFunctions;
exports.calculate_result = calculateResult.calculate_result;