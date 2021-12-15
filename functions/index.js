const functions = require("firebase-functions");
const escapeHtml = require("escape-html");
// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const rtDb = admin.database();
const FieldValue = admin.firestore.FieldValue;

exports.status = functions.database
  .ref("/users/{uid}/dummyKey")
  .onDelete((change, context) => {
    const ts = FieldValue.serverTimestamp();
    const uid = context.params.uid;
    const userRef = rtDb.ref("users/" + uid);
    const storeUserRef = db.collection("users").doc(uid);

    console.log("Firebase User Disconnected: ", uid);

    return vacateSeat(uid)
    .then(res => {
      console.log("Successfully vacating seat: ", res);
      return storeUserRef
        .update(
          {
            online: false,
            room: "",
            game: "",
            seat: "",
            timestamp: ts
          },
          { merge: true }
        )
      })
      .catch(err => console.log("Error vacating seat: ", err));
  });

const vacateSeat = uid => {
  return db.collection('users').doc(uid).get()
    .then(user => {
      if (!user.exists) {
        return console.log('No such user!');
      } else {
        const { room, game, seat } = user.data();
        return db.doc(`rooms/${room}/games/${game}/seats/seat${seat}`)
         .update({
           avatar: null,
           pos: null,
           uid: null,
           username: null
         })
      }
    })
};

exports.seat0Listener = functions.firestore
  .document(`rooms/{roomId}/games/{gameId}/seats/seat0`)
  .onWrite((change, context) => updateSeatStatus(change, context));

exports.seat1Listener = functions.firestore
  .document(`rooms/{roomId}/games/{gameId}/seats/seat1`)
  .onWrite((change, context) => updateSeatStatus(change, context));

exports.seat2Listener = functions.firestore
  .document(`rooms/{roomId}/games/{gameId}/seats/seat2`)
  .onWrite((change, context) => updateSeatStatus(change, context));

exports.seat3Listener = functions.firestore
  .document(`rooms/{roomId}/games/{gameId}/seats/seat3`)
  .onWrite((change, context) => updateSeatStatus(change, context));

const setGameSeatInfo = (roomId, gameId, count) => {
  return db
    .doc(`/rooms/${roomId}/games/${gameId}`)
    .set({ available: count < 4, empty: count === 0 }, { merge: true })
    .then(res => {
      return console.log("successfully updated availability/empty: ", res);
    });
};

const updateSeatStatus = (change, context) => {
  const roomId = context.params.roomId;
  const gameId = context.params.gameId;
  console.log("room ID: ", roomId);
  console.log("game ID: ", gameId);
  const oldDoc = change.before.data();
  const newDoc = change.after.exists ? change.after.data() : null;
  if (!(newDoc || {}).uid) {
    db.doc(`rooms/${roomId}/games/${gameId}`).update({users: FieldValue.arrayRemove(oldDoc.uid)})
  } else if ((newDoc || {}).uid !== oldDoc.uid) {
    db.doc(`rooms/${roomId}/games/${gameId}`).update({users: FieldValue.arrayUnion(newDoc.uid)})
  }

  return db.collection(`rooms/${roomId}/games/${gameId}/seats`)
    .listDocuments()
    .then(documentRefs => db.getAll(documentRefs))
    .then(documentSnapshots => {
      var count = 0;
      for (let snap of documentSnapshots) {
        if (snap.exists) {
          // console.log(`seat data: ${JSON.stringify(snap.data())}`);
          if (snap.data().uid) {
            count += 1;
            console.log(`${snap.id} is filled: ${snap.data().uid}`);
          } else {
            console.log(`${snap.id} is empty`);
          }
        } else {
          console.log(`snapshot doesnt exist`);
        }
      }
      console.log(`${count} seats filled`);
      return setGameSeatInfo(roomId, gameId, count);
    });
};

exports.testFunction = functions.https.onRequest((req, res) => {
  // Works
  // Grab the text parameter.
  const name = req.query.name;
  const desc = req.query.desc;
  const timestamp = Number(new Date());

  // Push the new message into the Realtime Database using the Firebase Admin SDK.
  return (
    db
      .collection("/rooms")
      .add({ name, desc, timestamp })
      // .then(docRef => console.log("id: ", docRef.id));
      .then(docRef => {
        console.log(
          docRef.id,
          `Hello ${name || desc || "World"} at ${timestamp}!`
        );
        return res.send(
          escapeHtml(`Hello ${name || desc || "World"} at ${timestamp}!`)
        );
      })
  );
});

exports.updateFunction = functions.https.onRequest((req, res) => {
  // Works
  // Grab the text parameter.
  const name = req.query.name;
  const desc = req.query.desc;
  const timestamp = Number(new Date());

  return (
    db
      .collection("/rooms")
      .set({ name, desc, timestamp })
      // .then(docRef => console.log("id: ", docRef.id));
      .then(docRef => {
        console.log(
          docRef.id,
          `Hello ${name || desc || "World"} at ${timestamp}!`
        );
        return res.send(
          escapeHtml(`Hello ${name || desc || "World"} at ${timestamp}!`)
        );
      })
  );
});

exports.deleteFunction = functions.https.onRequest((req, res) => {
  // Works
  var query = db.collection("rooms").where("name", "==", req.query.room);
  return query.get().then(querySnapshot => {
    return querySnapshot.forEach(doc => {
      doc.ref.delete();
    });
  });
});

// Take the txt parameter passed to this HTTP endpoint and insert it into the
// Realtime Database under the path /messages/:pushId/original
exports.addMessage = functions.https.onRequest((req, res) => {
  // Grab the text parameter.
  const original = req.query.text;
  // Push the new message into the Realtime Database using the Firebase Admin SDK.
  return db
    .ref("/messages")
    .push({ original: original })
    .then(snapshot => {
      // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
      return res.redirect(303, snapshot.ref.toString());
    });
});

// Listens for new messages added to /messages/:pushId/original and creates an
// uppercase version of the message to /messages/:pushId/uppercase
exports.makeUppercase = functions.database
  .ref("/messages/{pushId}/original")
  .onCreate((snapshot, context) => {
    // Grab the current value of what was written to the Realtime Database.
    const original = snapshot.val();
    console.log("Uppercasing", context.params.pushId, original);
    const uppercase = original.toUpperCase();
    // You must return a Promise when performing asynchronous tasks inside a Functions such as
    // writing to the Firebase Realtime Database.
    // Setting an "uppercase" sibling in the Realtime Database returns a Promise.
    return snapshot.ref.parent.child("uppercase").set(uppercase);
  });
