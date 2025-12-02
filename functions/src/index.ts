// --- v2 IMPORTS ---
import * as functions from "firebase-functions/v1"; // For v1 RTDB trigger
import {onDocumentCreated, onDocumentDeleted, onDocumentUpdated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {logger} from "firebase-functions";
import algoliasearch from "algoliasearch";
import {getMessaging, SendResponse, MulticastMessage} from "firebase-admin/messaging";

// --- FIX: Import the new parameter system ---
import {defineString} from "firebase-functions/params";

admin.initializeApp();
const firestore = admin.firestore();

// --- FIX: Define the new 2nd Gen parameters ---
// These will be loaded from Secret Manager, not .env
const algoliaAppId = defineString("ALGOLIA_APPID");
const algoliaApiKey = defineString("ALGOLIA_APIKEY");


// --- FIX: This function now handles BOTH online and offline ---
// This function is still v1, which is fine.
export const onUserStatusChanged = functions.database
  .ref("/status/{uid}")
  .onWrite(async (change, context) => {
    const userDocRef = firestore.doc(`users/${context.params.uid}`);

    // Check if data exists AFTER the change
    if (!change.after.exists()) {
      // The node was deleted (user disconnected)
      logger.log(`User ${context.params.uid} disconnected, setting offline.`);
      return userDocRef.update({
        status: "offline",
        // Use server time for lastSeen on disconnect
        lastSeen: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Data exists, get its value
    const eventStatus = change.after.val();

    if (eventStatus.status === "online") {
      logger.log(`User ${context.params.uid} is online.`);
      return userDocRef.update({
        status: "online",
      });
    }

    // This will catch "offline"
    if (eventStatus.status === "offline") {
      logger.log(`User ${context.params.uid} is offline.`);
      return userDocRef.update({
        status: "offline",
        lastSeen: eventStatus.timestamp,
      });
    }

    logger.log("Status change was not 'online' or 'offline', ignoring.");
    return null;
  });


let algoliaClient: ReturnType<typeof algoliasearch>;
let userIndex: ReturnType<typeof algoliaClient.initIndex>;
let projectIndex: ReturnType<typeof algoliaClient.initIndex>;

/**
 * Initializes the Algolia client.
 * This is called inside functions to ensure secrets are loaded.
 */
function ensureAlgoliaClient() {
  if (!algoliaClient) {
    // FIX: Use .value() to get the secret
    const appId = algoliaAppId.value();
    const apiKey = algoliaApiKey.value();

    if (!appId || !apiKey) {
      logger.error("Algolia App ID or API Key is not set in secrets.");
      return;
    }

    algoliaClient = algoliasearch(appId, apiKey);
    userIndex = algoliaClient.initIndex("users");
    projectIndex = algoliaClient.initIndex("projects");
  }
}

// --- v2 ALGOLIA TRIGGERS (No changes needed here) ---

export const onUserUpdated = onDocumentUpdated("users/{userId}", async (event) => {
  ensureAlgoliaClient(); // FIX: Initialize client
  if (!event.data) return;
  const newData = event.data.after.data();

  const objectToSave = {
    objectID: event.data.after.id,
    fullName: newData.fullName,
    skills: newData.skills,
    genres: newData.genres,
    headline: newData.headline,
    location: newData.location,
    keyRoles: newData.keyRoles,
  };
  try {
    await userIndex.saveObject(objectToSave);
    logger.log("User data synced to Algolia:", event.data.after.id);
  } catch (error) {
    logger.error("Error syncing to Algolia:", error);
  }
});

export const onProjectCreated = onDocumentCreated("projects/{projectId}", async (event) => {
  ensureAlgoliaClient(); // FIX: Initialize client
  if (!event.data) return;
  const data = event.data.data();
  const objectToSave = {
    objectID: event.data.id,
    title: data.title,
    description: data.description,
    projectType: data.projectType,
    year: data.year,
  };
  try {
    await projectIndex.saveObject(objectToSave);
    logger.log("Project created in Algolia:", event.data.id);
  } catch (error) {
    logger.error("Error creating project in Algolia:", error);
  }
});

export const onProjectUpdated = onDocumentUpdated("projects/{projectId}", async (event) => {
  ensureAlgoliaClient(); // FIX: Initialize client
  if (!event.data) return;
  const newData = event.data.after.data();
  const objectToSave = {
    objectID: event.data.after.id,
    title: newData.title,
    description: newData.description,
    projectType: newData.projectType,
    year: newData.year,
  };
  try {
    await projectIndex.saveObject(objectToSave);
    logger.log("Project updated in Algolia:", event.data.after.id);
  } catch (error) {
    logger.error("Error updating project in Algolia:", error);
  }
});

export const onProjectDeleted = onDocumentDeleted("projects/{projectId}", async (event) => {
  ensureAlgoliaClient(); // FIX: Initialize client
  if (!event.data) return;
  try {
    await projectIndex.deleteObject(event.data.id);
    logger.log("Project deleted from Algolia:", event.data.id);
  } catch (error) {
    logger.error("Error deleting project from Algolia:", error);
  }
});

// --- NOTIFICATION TRIGGERS (v2) ---


// Assume the necessary imports and firestore initialization are present

export const onCreditAdded = onDocumentCreated("credits/{creditId}", async (event) => {
  if (!event.data) {
    logger.warn("No data found in credit document snapshot. Aborting.");
    return;
  }

  const credit = event.data.data();
  const creditId = event.data.id;

  // 1. Read the Project Document (Crucial Check)
  const projectDoc = await firestore.doc(`projects/${credit.projectId}`).get();

  // Defensive Check 1: Ensure the Project document exists
  if (!projectDoc.exists) {
    logger.error(`Project document ${credit.projectId} not found. Cannot proceed with notification.`);
    return;
  }
  const project = projectDoc.data();

  // Defensive Check 2: Ensure the data is not null (TS safety)
  if (!project) {
    logger.error(`Project data for ID ${credit.projectId} is empty. Aborting notification.`);
    return;
  }

  // 2. CORE SECURITY CHECK: Skip notification if recipient is the creator
  if (credit.userId === project.createdBy) {
    logger.info(`Credit recipient is the project creator (${credit.userId}). Skipping notification.`);
    return;
  }

  // 3. Use creatorName from credit doc (denormalized data is assumed correct)
  const creatorName = credit.creatorName || "A Project Manager";

  // 4. Read the Recipient's User Document (for FCM Token)
  const userDoc = await firestore.doc(`users/${credit.userId}`).get();

  // Defensive Check 3: Ensure the Recipient exists before proceeding
  if (!userDoc.exists) {
    logger.error(`Recipient user document ${credit.userId} not found. Cannot send notification.`);
    return;
  }

  const fcmToken = userDoc.data()?.fcmToken;

  // 5. Final Notification Logic

  // Construct the message once
  const notificationMessage = `${creatorName} added you as '${credit.role}' on '${credit.projectTitle}'`;

  // 5a. Save the notification document to Firestore (for the 'Others' tab)
  const notification = {
    recipientId: credit.userId,
    senderName: creatorName,
    type: "credit_request",
    message: notificationMessage,
    referenceId: creditId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
  };
  await firestore.collection("notifications").add(notification);
  logger.log("Successfully saved notification to Firestore.");


  // 5b. Send the push notification (FCM)
  const payload = {
    token: fcmToken,

    notification: {
      title: "New Project Credit Request",
      body: notificationMessage,
    },


    data: {
      type: "credit_request",
      creditId: creditId,
      projectId: credit.projectId || "", // Ensure it's defined
      senderId: credit.createdBy || "",
    },


    android: {
      notification: {
        channelId: "credit_requests_channel",
      // You can add more Android-specific settings here
      },
    },
  };

  await admin.messaging().send(payload);

  return null;
});

export const onNewNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
  if (!event.data) return;
  const notificationData = event.data.data();

  if (!notificationData) {
    logger.log("No notification data found");
    return;
  }

  const recipientId = notificationData.recipientId;
  const type = notificationData.type;
  const senderName = notificationData.senderName;
  const message = notificationData.message;

  let title = "New Notification";
  let body = "You have a new update.";

  if (type === "connection_request") {
    title = "New Connection Request";
    body = `${senderName} wants to connect with you.`;
  } else if (type === "credit_request") {
    title = "New Project Credit";
    body = message;
  }

  await sendPushNotification(recipientId, title, body);
});

export const onNewChatMessage = onDocumentCreated("chats/{chatId}/messages/{messageId}", async (event) => {
  if (!event.data) return;
  const messageData = event.data.data();

  if (!messageData) {
    logger.log("No message data found");
    return;
  }

  const senderId = messageData.senderId;
  const messageText = messageData.text;
  const chatId = event.params.chatId;

  const chatDoc = await admin.firestore().doc(`chats/${chatId}`).get();
  const chatData = chatDoc.data();
  if (!chatData) {
    logger.log("No chat data found");
    return;
  }

  const participants = chatData.participants as string[];
  const recipientId = participants.find((id) => id !== senderId);

  if (!recipientId) {
    logger.log("Could not find a recipient.");
    return;
  }

  const senderDoc = await admin.firestore().doc(`users/${senderId}`).get();
  const senderName = senderDoc.data()?.fullName || "Someone";

  const title = `New Message from ${senderName}`;
  const body = messageText;

  await sendPushNotification(recipientId, title, body);
});

// --- 3. Re-usable Helper Function  ---
async function sendPushNotification(
  recipientId: string,
  title: string,
  body: string
) {
  const userDoc = await admin.firestore().doc(`users/${recipientId}`).get();
  const userData = userDoc.data();

  if (!userData || !userData.fcmTokens || !Array.isArray(userData.fcmTokens) || userData.fcmTokens.length === 0) {
    logger.log("User has no FCM tokens, cannot send notification.");
    return;
  }

  const tokens = userData.fcmTokens as string[];

  const payload: MulticastMessage = {
    notification: {
      title: title,
      body: body,
    },
    android: {
      notification: {
        sound: "default",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
    },
    tokens: tokens,
  };

  try {
    const response = await getMessaging().sendEachForMulticast(payload);
    logger.log("Successfully sent message:", response.successCount);

    const tokensToRemove: string[] = [];
    response.responses.forEach((result: SendResponse, index: number) => {
      if (!result.success) {
        logger.warn(`Failed to send to token: ${tokens[index]}`, result.error);

        if (result.error) {
          const error = result.error.code;
          if (
            error === "messaging/invalid-registration-token" ||
            error === "messaging/registration-token-not-registered"
          ) {
            tokensToRemove.push(tokens[index]);
          }
        }
      }
    });

    if (tokensToRemove.length > 0) {
      logger.log("Cleaning up invalid tokens:", tokensToRemove);
      await userDoc.ref.update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...tokensToRemove),
      });
    }
  } catch (error) {
    logger.error("Error sending message:", error);
  }
}

export const onNewJoinRequest = onDocumentCreated("joinRequests/{requestId}", async (event) => {
  if (!event.data) return; // Guard clause
  const requestData = event.data.data();

  // Only proceed if the status is 'pending' (initial creation)
  if (!requestData || requestData.status !== "pending") {
    logger.log("Join request not pending or data missing, skipping notification.");
    return;
  }

  const creatorId = requestData.projectCreatorId;
  const requesterName = requestData.requestingUserName;
  const projectTitle = requestData.projectTitle;
  const requestedRole = requestData.requestedRole;
  const joinRequestId = event.data.id; // Get the ID of the joinRequest document

  // Create the notification document for the project creator
  const notification = {
    recipientId: creatorId,
    senderName: requesterName, // Name of the person requesting
    senderId: requestData.requestingUserId, // ID of the requester
    senderProfilePic: requestData.requestingUserProfilePic, // Optional pic
    type: "join_request", // Unique type for this notification
    message: `${requesterName} requested to join '${projectTitle}' as '${requestedRole}'.`,
    referenceId: joinRequestId, // Link back to the joinRequest document
    projectId: requestData.projectId, // Include projectId for context
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
  };

  try {
    await firestore.collection("notifications").add(notification);
    logger.log(`Join request notification created for user ${creatorId}.`);
  } catch (error) {
    logger.error("Error creating join request notification:", error);
  }
});
