const admin = require('firebase-admin');
const functions = require("firebase-functions");

exports.userJoinsContest = functions.https.onCall(async (data, context) => {
    const title = data.title;
    const body = data.body;
    const receiverUsername = data.receiverUsername;

    const response = await admin.firestore().doc(`users/${receiverUsername}`).get();
    const token = response.data()['currentToken'];

    //* Skip sending notification if the contest creator joins the contest.
    // if (sender == receiver) return

    const payload = {
        notification: {
            title: title,
            body: body,
            sound: "default",
        }
    };

    const options = {
        priority: "high"
    };

    return admin.messaging().sendToDevice(token, payload, options);
});