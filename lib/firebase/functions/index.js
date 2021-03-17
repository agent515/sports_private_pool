const functions = require("firebase-functions");
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//

exports.calculate_result = functions.https.onCall((data, context) => {

    // console.log(data);
    // console.log(context);

    //1. retrieve auth uid of the caller
    const uid = context.auth.uid;
    console.log("uid: " + uid);
    //2. check if we already have calculated the percentile score for this match in firestore.
    //If yes go to step 6.
    const matchId = data.matchId;
    const contestId = data.contestId;
    console.log(matchId);
    console.log(contestId);
    admin.firestore().doc('/matchResult/').get(matchId)
        .then(result => {
            console.log(result.data);
            if (result.data.length == 0) {
                console.log('result does not exist');
            } else {
                console.log('result exists');
            }
        }).catch(e => {
            console.log(e);
        });
    // return { "result": "done with the execution" };
    // admin.firestore.doc('/matchResult/').get(matchId)
    //     .then(result => {
    //         console.log("inside then");
    //         if (result.status === 200) {
    //             console.log(result.data);
    //         }
    //     })
    //     .catch(err => {
    //         console.log("inside axios");
    //         console.log(err);
    //         // 3. request score to the cricApi
    //         // https://cricapi.com/api/fantasySummary?apikey=itfCIjkbOnb4vW31al0l79I7p992&unique_id=1034809
    //         const API_URL = "https://cricapi.com/api/fantasySummary?apikey=";
    //         const API_KEY = "itfCIjkbOnb4vW31al0l79I7p992";

    //         const final_url = `${API_URL}${API_KEY}&unique_id=${matchId}`;

    //         axios.get(final_url)
    //             .then(result => {
    //                 console.log("inside axios then")
    //                 if (result.status == 200) {
    //                     console.log(result.data);
    //                 }
    //                 else {
    //                     console.log(`${result.status}\nResponse: ${result.data}`);
    //                 }
    //             })
    //             .catch(e => {
    //                 console.log("inside axios catch");
    //                 console.log(e);
    //             });

    //         // 4. calculate standard percentile for each player who played in the match

    //         // 5. store that score in the firebase

    //     });


    // 6. assign score to the participants of the contest

    // 7. distribute rewards to the winner
});