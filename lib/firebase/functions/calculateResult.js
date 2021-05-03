const functions = require("firebase-functions");
const admin = require('firebase-admin');
const axios = require('axios');
const { matchSummaryT20, matchSummaryTestMatch, matchSummaryT20Empty } = require('./sampleJsonResponses/fantasySummary');


exports.calculate_result = functions.https.onCall((data, context) => {

    //1. retrieve auth uid of the caller
    const uid = context.auth.uid;
    console.log("uid: " + uid);
    //2. check if we already have calculated the percentile score for this match in firestore.
    //If yes go to step 6.
    const matchId = data.matchId;
    const contestId = data.contestId;
    console.log(matchId);
    console.log(contestId);

    // TODO: Refactor duplicate code using Promises.

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
                    .then((response) => {
                        console.log("inside axios then")
                        if (response.status == 200) {
                            console.log(response.data);

                            var batting_percentile = {};
                            var bowling_percentile = {};
                            var mvp_percentile = {};

                            const matchSummary = response.data;

                            //* Return if the matchSummary is completely available to calculate result
                            if (!matchSummary.data.team[0].players.length || !matchSummary.data.team[1].players.length) {
                                console.log("Match result not available. returning");
                                return {
                                    "error": {
                                        "status": "Not Found",
                                        "message": "match result is not available to calculate."
                                    }
                                };
                            }

                            // 4. calculate standard percentile for each player who played in the match

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

                            // 5. store that score in the firebase
                            admin.firestore().doc(`/matchResult/${matchId}`).set(matchResult);

                            // 6. assign score to the participants of the contest
                            return admin.firestore().doc(`/contests/cricketMatchContest/cricketMatchContestCollection/${contestId}`).get()
                                .then((contestData) => {
                                    const contest = contestData.data();
                                    console.log(contestData['predictions']);
                                    // console.log(matchResult);
                                    let result = {};
                                    for (let key in contest['predictions']) {
                                        let value = contest['predictions'][key];

                                        const battingScore = matchResult['batting'][value['mostRuns']] == undefined ? 0 : parseFloat(matchResult['batting'][value['mostRuns']]['percentile']);
                                        const bowlingScore = matchResult['bowling'][value['mostWickets']] == undefined ? 0 : parseFloat(matchResult['bowling'][value['mostWickets']]['percentile']);
                                        const mvpScore = matchResult['mvp'][value['MVP']] == undefined ? 0 : parseFloat(matchResult['mvp'][value['MVP']]['percentile']);

                                        result[key] = battingScore + bowlingScore + mvpScore;

                                        if (matchResult['winner'] != undefined) {
                                            if (matchResult['winner'] == 'draw' && value['matchResult'] == matchResult['winner']) {
                                                result[key] += 150.0;
                                            }
                                            else if (value['matchResult'] == matchResult['winner']) {
                                                result[key] += 100.0;
                                            }
                                        }
                                        console.log(result);
                                    }
                                    result = Object.entries(result).sort((a, b) => b[1] - a[1]);
                                    console.log("result: " + result);

                                    let resultObjectArray = [];
                                    for (let i = 0; i < result.length; i++) {
                                        resultObjectArray[i] = {
                                            'index': i,
                                            'username': result[i][0],
                                            'points': result[i][1],
                                        };
                                    }

                                    console.log(resultObjectArray);

                                    let max = 0;
                                    let winners = [];
                                    for (let i = 0; i < result.length; i++) {
                                        if (i == 0) max = result[0][1];
                                        if (result[i][1] != max) {
                                            break;
                                        };
                                        winners.push(result[0][0]);
                                    }
                                    console.log('winners: ' + winners);

                                    admin.firestore().doc(`/contests/cricketMatchContest/cricketMatchContestCollection/${contestId}`).update({
                                        result: {
                                            "leaderboard": resultObjectArray,
                                            "winners": winners,
                                        }
                                    }).then((_) => console.log(_)).catch(e => console.log(e));


                                    // 7. distribute rewards to the winner
                                    const distributeMoney = contest['prizeMoney'] / winners.length;

                                    for (let i = 0; i < winners.length; i++) {
                                        admin.firestore().doc(`users/${winners[i]}`).get()
                                            .then(winnerUser => {
                                                let currPurse = winnerUser.data()['purse'];
                                                console.log("updated purse:" + currPurse + distributeMoney);

                                                console.log(typeof (currPurse));
                                                console.log(typeof (distributeMoney));

                                                admin.firestore().doc(`users/${winners[i]}`).update({ purse: currPurse + distributeMoney });

                                                const payload = {
                                                    notification: {
                                                        title: "Congratulations!!",
                                                        text: winners.length == 1 ? `You're the winner of the contest ${contest['contestId']}. Amount of ${distributeMoney} is transferred to your wallet.` : `You're one of the winners of the contest ${contest['contestId']}. Amount of ${distributeMoney} is transferred to your wallet.`,
                                                    },
                                                    data: {
                                                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                                        message: winners.length == 1 ? `You're the winner of the contest ${contest['contestId']}. Amount of ${distributeMoney} is transferred to your wallet.` : `You're one of the winners of the contest ${contest['contestId']}. Amount of ${distributeMoney} is transferred to your wallet.`,
                                                        type: 'result',
                                                        contestId: contestId,
                                                        matchId: matchId.toString(),
                                                    },
                                                }

                                                const options = {
                                                    priority: "high"
                                                };
                                                console.log(winnerUser.data()['currentToken']);
                                                admin.messaging().sendToDevice(winnerUser.data()['currentToken'], payload, options);
                                            })
                                            .catch(e => console.log(e));
                                    }

                                    return {
                                        "data": {
                                            "leaderboard": resultObjectArray,
                                            "winners": winners,
                                        }
                                    };

                                })
                                .catch((e) => {
                                    console.log(e);
                                    return {
                                        "error": {
                                            "message": "Could not calculate contest result",
                                            "status": "CALCULATION_ERROR",
                                        }
                                    };
                                });

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
                const matchResult = result.data();

                // 6. assign score to the participants of the contest
                return admin.firestore().doc(`/contests/cricketMatchContest/cricketMatchContestCollection/${contestId}`).get()
                    .then((contestData) => {
                        const contest = contestData.data();
                        let result = {};
                        for (let key in contest['predictions']) {
                            let value = contest['predictions'][key];

                            const battingScore = matchResult['batting'][value['mostRuns']] == undefined ? 0 : parseFloat(matchResult['batting'][value['mostRuns']]['percentile']);
                            const bowlingScore = matchResult['bowling'][value['mostWickets']] == undefined ? 0 : parseFloat(matchResult['bowling'][value['mostWickets']]['percentile']);
                            const mvpScore = matchResult['mvp'][value['MVP']] == undefined ? 0 : parseFloat(matchResult['mvp'][value['MVP']]['percentile']);

                            result[key] = battingScore + bowlingScore + mvpScore;
                            if (matchResult['winner'] != undefined) {
                                if (matchResult['winner'] == 'draw' && value['matchResult'] == matchResult['winner']) {
                                    result[key] += 150.0;
                                }
                                else if (value['matchResult'] == matchResult['winner']) {
                                    result[key] += 100.0;
                                }
                            }
                        }
                        result = Object.entries(result).sort((a, b) => b[1] - a[1]);
                        console.log(typeof (result));
                        console.log("result: " + result);
                        console.log("contestId: " + contestId);

                        let resultObjectArray = [];
                        for (let i = 0; i < result.length; i++) {
                            resultObjectArray[i] = {
                                'index': i,
                                'username': result[i][0],
                                'points': result[i][1],
                            };
                        }

                        console.log(resultObjectArray);

                        let max = 0;
                        let winners = [];
                        for (let i = 0; i < result.length; i++) {
                            if (i == 0) max = result[i][1];
                            if (result[i][1] != max) {
                                break;
                            };
                            winners.push(result[i][0]);
                        }
                        console.log('winners: ' + winners);

                        admin.firestore().doc(`/contests/cricketMatchContest/cricketMatchContestCollection/${contestId}`).update({
                            result: {
                                "leaderboard": resultObjectArray,
                                "winners": winners,
                            }
                        }).then((_) => console.log(_)).catch(e => console.log(e));

                        // 7. distribute rewards to the winner
                        const distributeMoney = contest['prizeMoney'] / winners.length;

                        for (let i = 0; i < winners.length; i++) {
                            admin.firestore().doc(`users/${winners[i]}`).get()
                                .then(winnerUser => {
                                    let currPurse = winnerUser.data()['purse'];
                                    admin.firestore().doc(`users/${winners[i]}`).update({ purse: parseFloat(currPurse) + distributeMoney });

                                    const payload = {
                                        notification: {
                                            title: "Congratulations!!",
                                            text: winners.length == 1 ? `You're the winner of the contest ${contest['contestId']}. Amount of ${distributeMoney} is transferred to your wallet.` : `You're one of the winners of the contest ${contest['contestId']}. Amount of ${distributeMoney} is transferred to your wallet.`,
                                        },
                                        data: {
                                            click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                            message: winners.length == 1 ? `You're the winner of the contest ${contest['contestId']}. Amount of ${distributeMoney} is transferred to your wallet.` : `You're one of the winners of the contest ${contest['contestId']}. Amount of ${distributeMoney} is transferred to your wallet.`,
                                            type: 'result',
                                            contestId: contestId,
                                            matchId: matchId.toString(),
                                        },
                                    }

                                    const options = {
                                        priority: "high"
                                    };

                                    console.log(winnerUser.data()['currentToken']);
                                    admin.messaging().sendToDevice(winnerUser.data()['currentToken'], payload, options);
                                })
                                .catch(e => console.log(e));
                        }

                        return {
                            "data": {
                                "leaderboard": resultObjectArray,
                                "winners": winners,
                            }
                        };

                    })
                    .catch((e) => {
                        console.log(e);
                        return {
                            "error": {
                                "message": "Could not calculate contest result",
                                "status": "CALCULATION_ERROR",
                            }
                        };
                    });
            }
        }).catch(e => {
            console.log(e);
        });
});