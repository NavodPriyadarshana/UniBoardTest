const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// ─────────────────────────────────────────────
// SEND PUSH NOTIFICATION
// Triggered when a new document is added
// to the notifications collection in Firestore
// ─────────────────────────────────────────────
exports.sendPushNotification = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    const token = data.token;
    const title = data.title;
    const body = data.body;

    if (!token) {
      console.log("No FCM token found");
      return null;
    }

    // ── Build FCM message ──
    const message = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
      android: {
        notification: {
          channelId: "high_importance_channel",
          priority: "high",
          sound: "default",
        },
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log("Notification sent successfully:", response);

      // Mark notification as sent
      await snap.ref.update({ isSent: true });

      return response;
    } catch (error) {
      console.error("Error sending notification:", error);
      return null;
    }
  });