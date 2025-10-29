Auteurly 🎬
Auteurly is a professional networking platform designed to connect the fragmented community of film professionals in Rwanda's nascent film industry, "Hillywood." It provides a centralized, verifiable, and searchable registry to replace informal, word-of-mouth hiring with a transparent, merit-based system.

The platform aims to enhance the visibility of local talent, foster collaboration, and attract international productions by providing the foundational infrastructure for a more formal and equitable creative ecosystem.

✨ Features
Rich Professional Profiles
Project Gallery: Upload multiple videos, images, or PDFs, complete with descriptions, to showcase a full body of work.

Showreel Upload: Upload a primary showreel video file directly, not just a URL link.

Verifiable Credits: Build trust by having your work history verified by project creators.

Project & Credit System
Project Creation: Add projects with posters, descriptions, status (e.g., In Production, Completed), and crew.

Peer Credit Verification: Add crew members to a project, who are then notified to accept their credit.

Project Join Requests: Allow users to find projects and formally request to join in a specific role, sending a notification to the project creator for approval or denial.

Real-time & Interactive
Direct Messaging: Built-in private chat for professional communication.

Push Notifications: Receive alerts for new messages, credit verifications, and project join requests even when the app is closed (powered by FCM & Cloud Functions).

Live Presence: See who is currently "online" or "offline" with a real-time status indicator (powered by Firebase Realtime Database).

Discovery & UI
Advanced Search & Filtering: A powerful search engine (powered by Algolia) for producers to find talent based on role, skills, availability, and more.

Dynamic Card Colors: Project cards in the feed dynamically adapt their background color to match the project's poster image.

Custom Theming: App-wide dark theme with custom fonts (Monoton for headlines, Montserrat for body text).

Secure & User-Friendly
Secure Authentication: Secure sign-up/log-in with Email & Password or Google.

User-Friendly Error Handling: Custom, dismissible error messages on login/register pages (e.g., "Passwords do not match," "User not found").

📱 UI Mockups
This section showcases the visual design and user experience of the Auteurly application. https://www.figma.com/design/JwrBQuJBnsmzNojcn71QHZ/Auteurly?node-id=0-1&t=q53wMLrTa4JoVCOb-1

Github Link
https://github.com/Eyiniola/autueurly.git

🛠️ Tech Stack
Front-end: Flutter (Cross-platform for iOS, Android & Web)

Back-end: Firebase (Backend-as-a-Service)

Authentication: Firebase Authentication

Database: Cloud Firestore

Real-time Database: Firebase Realtime Database (for presence)

File Storage: Cloud Storage for Firebase

Serverless Logic: Cloud Functions for Firebase (TypeScript, 2nd Gen)

Search: Algolia (Search-as-a-Service)

Design: Figma

🚀 Getting Started
Follow these instructions to get a copy of the project up and running on your local machine for development and testing.

Prerequisites
Flutter SDK installed.

Firebase CLI installed (npm install -g firebase-tools).

Node.js installed (for Cloud Functions).

A Firebase project with the Blaze (pay-as-you-go) plan enabled (required for 2nd Gen Functions and outbound networking).

Installation & Setup
Clone the repository:

Bash

git clone https://github.com/Eyiniola/autueurly.git
cd auteurly
Configure Firebase: Run the FlutterFire configuration tool to link your Firebase project. It will automatically generate your firebase_options.dart file and place your native config files (google-services.json etc.) in the correct folders.

Bash

flutterfire configure
Set Up Environment Variables (for Flutter App): Create a .env file in the root of the project. Add your public-safe Algolia keys to this file. This file should be in your .gitignore.

ALGOLIA_APP_ID="YOUR_ALGOLIA_APP_ID"
ALGOLIA_SEARCH_ONLY_API_KEY="YOUR_SEARCH_ONLY_API_KEY"
Install Dependencies:

Bash

flutter pub get
Run the App:

Bash

flutter run
☁️ Backend (Cloud Functions) Setup
The server-side logic (TypeScript, 2nd Gen) is located in the functions directory.

Navigate to the functions directory:

Bash

cd functions
Install npm dependencies:

Bash

npm install
Set Up Secure Secrets (2nd Gen Functions): Cloud Functions (2nd Gen) use Google Secret Manager for secure keys, not functions:config(). The code is already set up to use parameters defined in index.ts (e.g., defineString("ALGOLIA_APIKEY")).

The Firebase CLI will prompt you to enter these values securely on your first deploy.

Deploy Functions: From your project's root directory (not the functions directory), run the deploy command:

Bash

firebase deploy --only functions
On the first deploy, the CLI will guide you to enable the necessary APIs (e.g., Cloud Run, Eventarc, Secret Manager).

It will then prompt you to enter values for the secrets defined in your code (ALGOLIA_APPID and ALGOLIA_APIKEY). Paste your Algolia Admin API Key when prompted.
