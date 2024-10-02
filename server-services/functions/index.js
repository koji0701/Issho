const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Define the function to increment the streak for every user

/*
export function incrementStreak() {
  const usersRef = admin.firestore().collection('users');

  // Get all the users from the Firestore collection
  const usersSnapshot = await usersRef.get();

  // Iterate over each user document and update the streak attribute based on the progress attribute
  usersSnapshot.forEach((userDoc) => {
    const hasFinishedToday = userDoc.get('hasFinishedToday');
    const currentStreak = userDoc.get('streak');
    const streakIsLate = userDoc.get('streakIsLate');

    let newStreak;
    let newStreakIsLate;

    if (hasFinishedToday === true) {
      newStreak = currentStreak + 1;
      console.log("incrementing streak for " + userDoc.id);
      newStreakIsLate = false;
    }
    else if (streakIsLate === false) {
      newStreak = currentStreak;
      streakIsLate = true;
      console.log("provide a warning for "+ userDoc.id);
    }
    else {
      newStreak = 0;
      newStreakIsLate = false;
      console.log("reset the streak for "+ userDoc.id);
    }

    userDoc.ref.update({
      streak: newStreak,
      likes: [],
      todaysLikes: [],
      progress: 0,
      streakIsLate: newStreakIsLate,
      hasFinishedToday: false
    });

  });
    console.log('Streaks incremented successfully.');
}*/


exports.testingDailyIncrement = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("testing daily increment function working");
  const usersRef = admin.firestore().collection('users');

  // Get all the users from the Firestore collection
  const usersSnapshot = await usersRef.get();

  // Iterate over each user document and update the streak attribute based on the progress attribute
  usersSnapshot.forEach((userDoc) => {
    const hasFinishedToday = userDoc.get('hasFinishedToday');
    const currentStreak = userDoc.get('streak');
    const streakIsLate = userDoc.get('streakIsLate');

    let newStreak;
    let newStreakIsLate;

    if (hasFinishedToday === true) {
      newStreak = currentStreak + 1;
      response.send("incrementing streak for " + userDoc.id);
      newStreakIsLate = false;
    }
    else if (streakIsLate === false) {
      newStreak = currentStreak;
      streakIsLate = true;
      response.send("provide a warning for "+ userDoc.id);
    }
    else {
      newStreak = 0;
      newStreakIsLate = false;
      response.send("reset the streak for "+ userDoc.id);
    }

    userDoc.ref.update({
      streak: newStreak,
      likes: [],
      todaysLikes: [],
      progress: 0,
      streakIsLate: newStreakIsLate,
      hasFinishedToday: false
    });

  });
    response.send('Streaks incremented successfully.');

})

// Define the Firebase Cloud Function that runs at midnight daily using a scheduled function trigger
/*
exports.dailyStreakIncrement = functions.pubsub
  .schedule('every day 00:00')
  .onRun(incrementStreak);
*/

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started


exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});


/*

exports.newDayUpdates = functions.pubsub.schedule('0 0 * * *')
  .timeZone('America/New_York') // Users can choose timezone - default is America/Los_Angeles
  .onRun((context) => {
  console.log('This will be run every day at 12:00 AM Eastern!');
  return null;
});*/
