import * as functions from "firebase-functions/v1";
import algoliasearch from "algoliasearch";

// Initialize Algolia client
const ALGOLIA_ID = functions.config().algolia.appid;
const ALGOLIA_ADMIN_KEY = functions.config().algolia.apikey;
const client = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);
const index = client.initIndex("users");

// Firestore trigger function
export const onUserUpdated = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change) => {
    // Get the new user data from the snapshot
    const newData = change.after.data();

    // Prepare the object for Algolia
    const objectToSave = {
      objectID: change.after.id,
      fullName: newData.fullName,
      skills: newData.skills,
      genres: newData.genres,

    };

    // Sync the data to the Algolia index
    try {
      await index.saveObject(objectToSave);
      functions.logger.log("User data synced to Algolia:", change.after.id);
    } catch (error) {
      functions.logger.error("Error syncing to Algolia:", error);
    }
  });
