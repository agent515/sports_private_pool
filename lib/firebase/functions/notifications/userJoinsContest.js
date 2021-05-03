const admin = require('firebase-admin');
const functions = require("firebase-functions");

exports.userJoinsContest = functions.https.onCall(async (data, context) => {
    const title = data.title;
    const body = data.body;
    const receiverUsername = data.receiverUsername;
    const contestId = data.contestId;
    const matchId = data.matchId;

    const response = await admin.firestore().doc(`users/${receiverUsername}`).get();
    const token = response.data()['currentToken'];


    const payload = {
        notification: {
            title: title,
            body: body,
            sound: "default",
        },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            message: body,
            type: 'joinContest',
            contestId: contestId,
            matchId: matchId,
        }
    };

    const options = {
        priority: "high"
    };

    return admin.messaging().sendToDevice(token, payload, options);
});