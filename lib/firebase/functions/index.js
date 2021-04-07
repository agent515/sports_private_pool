const functions = require("firebase-functions");
const admin = require('firebase-admin');
const axios = require('axios');
const { matchSummaryT20, matchSummaryTestMatch, matchSummaryT20Empty } = require('./sampleJsonResponses/fantasySummary');

admin.initializeApp();


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

    return admin.firestore().doc(`/matchResult/${matchId}`).get()
        .then(result => {
            console.log(result.data());
            if (result.data() === undefined) {
                console.log('result does not exist');

                const API_URL = "https://cricapi.com/api/fantasySummary?apikey=";
                const API_KEY = "itfCIjkbOnb4vW31al0l79I7p992";

                const final_url = `${API_URL}${API_KEY}&unique_id=${matchId}`;

                // const matchSummary = matchSummaryT20Empty;

                return axios.get(final_url)
                    .then(response => {
                        console.log("inside axios then")
                        if (response.status == 200) {
                            console.log(response.data);

                            var batting_percentile = {};
                            var bowling_percentile = {};
                            var mvp_percentile = {};

                            const matchSummary = response.data;

                            //* Return if the matchSummary is completely available to calculate result
                            if (!matchSummary.data.team[0].players.length || !matchSummary.data.team[1].players.length) {
                                return {
                                    "error": {
                                        "status": "Not Found",
                                        "message": "match result is not available to calculate."
                                    }
                                };
                            }

                            for (let i = 0; i < 2; i++) {
                                for (let player of matchSummary.data.team[i].players) {
                                    mvp_percentile[player.pid] = { 'runs': 0, 'wickets': 0, 'percentile': 0, 'name': player.name };
                                    batting_percentile[player.pid] = { 'runs': 0, 'percentile': 0, 'name': player.name };
                                    bowling_percentile[player.pid] = { 'wickets': 0, 'percentile': 0, 'name': player.name };
                                }
                            }
                            for (let batting_inng of matchSummary.data.batting) {
                                for (let curr of batting_inng.scores) {
                                    batting_percentile[curr.pid]['runs'] += curr.R;
                                    mvp_percentile[curr.pid]['runs'] += curr.R;
                                }
                            }

                            var maxRuns = 0;
                            for (const key in batting_percentile) {
                                const curr = batting_percentile[key];
                                if (maxRuns < curr.runs) maxRuns = curr.runs;
                            }
                            console.log(`max runs: ${maxRuns}`);

                            for (const key in batting_percentile) {
                                const curr = batting_percentile[key];
                                let percentile = (curr.runs / maxRuns) * 100;
                                batting_percentile[key]['percentile'] = percentile;
                                mvp_percentile[key]['percentile'] += percentile;
                            }

                            for (let bowling_inng of matchSummary.data.bowling) {
                                for (let curr of bowling_inng.scores) {
                                    bowling_percentile[curr.pid]['wickets'] += Number.isInteger(curr.W) ? curr.W : parseInt(curr.W);
                                    mvp_percentile[curr.pid]['wickets'] += Number.isInteger(curr.W) ? curr.W : parseInt(curr.W);
                                }
                            }

                            var maxWickets = 0;
                            for (const key in bowling_percentile) {
                                const curr = bowling_percentile[key];
                                if (maxWickets < curr.wickets) maxWickets = curr.wickets;
                            }

                            console.log(`max wickets: ${maxWickets}`);

                            for (const key in bowling_percentile) {
                                const curr = bowling_percentile[key];
                                let percentile = (curr.wickets / maxWickets) * 100;
                                bowling_percentile[key]['percentile'] = percentile;
                                mvp_percentile[key]['percentile'] += percentile;
                            }

                            const winner = ('winner_team' in matchSummary.data) ? matchSummary.data.winner_team : 'NA';
                            const matchResult = {
                                'matchId': matchId,
                                'winner': winner,
                                'batting': batting_percentile,
                                'bowling': bowling_percentile,
                                'mvp': mvp_percentile,
                            };
                            // console.log(matchResult);

                            // 4. calculate standard percentile for each player who played in the match
                            // 5. store that score in the firebase
                            admin.firestore().doc(`/matchResult/${matchId}`).set(matchResult);

                            // 6. assign score to the participants of the contest

                            // 7. distribute rewards to the winner

                            return {
                                "data": {
                                    "matchResult": matchResult,
                                }
                            };

                        }
                        else {
                            console.log(`${response.status}\nResponse: ${response.data}`);
                            return {
                                "error": {
                                    "message": "Try again",
                                    "status": "UNAUTHENTICATED",
                                    "details": {
                                        "response-data": response.data,
                                    }
                                }
                            };
                        }
                    })
                    .catch(e => {
                        console.log("inside axios catch");
                        console.log(e);
                        return {
                            "error": {
                                "message": e,
                                "status": "UNAUTHENTICATED",
                            }
                        };
                    });
            } else {
                console.log('result exists');
                return {
                    'data': result.data(),
                };
                // 6. assign score to the participants of the contest

                // 7. distribute rewards to the winner
            }
        }).catch(e => {
            console.log(e);
        });
});