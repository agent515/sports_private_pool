const PAYMENT_URL =
    "http://10.0.2.2:5001/envision-sports/us-central1/customFunctions/payment";

const ORDER_DATA = {
  "custID": "USER_1122334455",
  "custEmail": "myemail@gmail.com",
  "custPhone": "0987654321"
};

const STATUS_LOADING = "PAYMENT_LOADING";
const STATUS_SUCCESSFUL = "PAYMENT_SUCCESSFUL";
const STATUS_PENDING = "PAYMENT_PENDING";
const STATUS_FAILED = "PAYMENT_FAILED";
const STATUS_CHECKSUM_FAILED = "PAYMENT_CHECKSUM_FAILED";
