Auteurly 🎬
Auteurly is a professional networking platform designed to connect the fragmented community of film professionals in Rwanda's nascent film industry, "Hillywood." It provides a centralized, verifiable, and searchable registry to replace informal, word-of-mouth hiring with a transparent, merit-based system. The platform aims to enhance the visibility of local talent, foster collaboration, and attract international productions by providing the foundational infrastructure for a more formal and equitable creative ecosystem.

✨ Features
Verifiable Professional Profiles: Media-rich portfolios for filmmakers to showcase their skills, genre specializations, and work history.

Credit Verification System: A trust-building feature allowing peers to confirm work history.

Advanced Search & Filtering: A powerful search engine (powered by Algolia) for producers to find talent based on role, skills, availability, and more.

Direct Messaging: A built-in, private chat system to facilitate professional communication.

Google & Email Authentication: Secure and easy ways for users to sign up and log in.

📱 UI Mockups
This section showcases the visual design and user experience of the Auteurly application.
https://www.figma.com/design/JwrBQuJBnsmzNojcn71QHZ/Auteurly?node-id=0-1&t=q53wMLrTa4JoVCOb-1



🛠️ Tech Stack
Front-end: Flutter (Cross-platform for iOS, Android & Web)

Back-end: Firebase (Backend-as-a-Service)

Authentication: Firebase Authentication

Database: Cloud Firestore

File Storage: Cloud Storage for Firebase

Serverless Logic: Cloud Functions for Firebase (TypeScript)

Search: Algolia (Search-as-a-Service)

Design: Figma

🚀 Getting Started
Follow these instructions to get a copy of the project up and running on your local machine for development and testing.

Prerequisites
Flutter SDK installed.

Firebase CLI installed (dart pub global activate firebase_cli).

Node.js installed (for Cloud Functions).

Installation & Setup
Clone the repository:

Bash

git clone https://github.com/your-username/auteurly.git
cd auteurly
Configure Firebase:

Run the FlutterFire configuration tool to link your Firebase project. It will automatically generate your firebase_options.dart file and place your native config files (google-services.json etc.) in the correct folders.

Bash

flutterfire configure
Set Up Environment Variables:

Create a .env file in the root of the project.

Add your public-safe Algolia keys to this file. This file should be in your .gitignore.

ALGOLIA_APP_ID="YOUR_ALGOLIA_APP_ID"
ALGOLIA_SEARCH_ONLY_API_KEY="YOUR_SEARCH_ONLY_API_KEY"
Install Dependencies:

Bash

flutter pub get
Run the App:

Bash

flutter run
☁️ Backend (Cloud Functions) Setup
The server-side logic for syncing data to Algolia is located in the functions directory.

Navigate to the functions directory:

Bash

cd functions
Install npm dependencies:

Bash

npm install
Set Secure Config:

Add your secret Algolia Admin API key to the Firebase environment configuration.

Bash

firebase functions:config:set algolia.api_key="YOUR_ALGOLIA_ADMIN_KEY"
Deploy Functions:

From the project's root directory, deploy your functions.

Bash

firebase deploy --only functions
