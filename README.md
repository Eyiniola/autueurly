# 🎬 Auteurly

**Auteurly** is a professional networking platform designed to connect the fragmented community of film professionals in Rwanda's nascent film industry, *Hillywood*.  
It provides a **centralized, verifiable, and searchable registry** to replace informal, word-of-mouth hiring with a **transparent, merit-based system**.

The platform aims to **enhance the visibility** of local talent, **foster collaboration**, and **attract international productions** by building the foundational infrastructure for a more formal and equitable creative ecosystem.

---

## 🎥 App Demo & Download

Watch the Auteurly app in action and explore the working build below:

- 📺 [Watch App Demo Video](https://drive.google.com/file/d/1ad_30MENzFwPczZq89VyWKGkYGmxULx9/view?usp=sharing)  
- 📦 [Download Working Application (APK)](https://drive.google.com/file/d/1hKp1iPQkEWtSWkuQOTRqsorsvo1VKHus/view?usp=sharing)

---

## ✨ Features

### 🧑‍🎨 Rich Professional Profiles
- **Project Gallery:** Upload multiple videos, images, or PDFs with descriptions to showcase your full body of work.  
- **Showreel Upload:** Upload a primary showreel video directly (not just a URL link).  
- **Verifiable Credits:** Build trust by having your work history verified by project creators.

### 🎬 Project & Credit System
- **Project Creation:** Add projects with posters, descriptions, status (*In Production*, *Completed*), and crew lists.  
- **Peer Credit Verification:** Add crew members who get notified to verify their credits.  
- **Project Join Requests:** Users can request to join projects in specific roles, with notifications sent to creators for approval or denial.

### 💬 Real-time & Interactive
- **Direct Messaging:** Built-in chat for professional communication.  
- **Push Notifications:** Receive alerts for new messages, credit verifications, and project join requests — even when the app is closed (via FCM & Cloud Functions).  
- **Live Presence:** Real-time online/offline status powered by Firebase Realtime Database.

### 🔍 Discovery & UI
- **Advanced Search & Filtering:** Powerful search engine (powered by Algolia) for finding talent by role, skills, and availability.  
- **Dynamic Card Colors:** Project cards adapt their background color to match the poster image.  
- **Custom Theming:** Global dark theme with *Monoton* (headlines) and *Montserrat* (body text).

### 🔒 Secure & User-Friendly
- **Secure Authentication:** Email & Password or Google login.  
- **Friendly Error Handling:** Dismissible messages like *“Passwords do not match”* or *“User not found.”*

---

## 🛠️ Tech Stack

| Layer | Technology |
|--------|-------------|
| **Front-end** | Flutter (Cross-platform for iOS, Android & Web) |
| **Back-end** | Firebase (Backend-as-a-Service) |
| **Authentication** | Firebase Authentication |
| **Database** | Cloud Firestore |
| **Real-time Database** | Firebase Realtime Database (for presence) |
| **File Storage** | Cloud Storage for Firebase |
| **Serverless Logic** | Cloud Functions for Firebase (TypeScript, 2nd Gen) |
| **Search** | Algolia (Search-as-a-Service) |
| **Design** | Figma |

---

## 🚀 Installation & Setup (Step-by-Step)

Follow these instructions to get a copy of the project running locally.

### ✅ Prerequisites
- Flutter SDK installed  
- Firebase CLI → `npm install -g firebase-tools`  
- Node.js installed (for Cloud Functions)  
- Firebase project with the **Blaze (Pay-as-you-go)** plan enabled (for 2nd Gen Functions)

---

### ⚙️ Step 1: Clone the Repository
```bash
git clone https://github.com/Eyiniola/autueurly.git
cd auteurly
⚙️ Step 2: Configure Firebase for Flutter
Run the FlutterFire configuration tool. This generates firebase_options.dart and native config files.

bash
Copy code
flutterfire configure
⚙️ Step 3: Set Up Flutter Environment Variables
Create a .env file in your project root (auteurly/):
(Ensure it’s listed in .gitignore)

env
Copy code
ALGOLIA_APP_ID="YOUR_ALGOLIA_APP_ID"
ALGOLIA_SEARCH_ONLY_API_KEY="YOUR_SEARCH_ONLY_API_KEY"
⚙️ Step 4: Install Flutter Dependencies
bash
Copy code
flutter pub get
⚙️ Step 5: Set Up Backend Functions
Navigate to the backend functions directory and install dependencies:

bash
Copy code
cd functions
npm install
cd ..
⚙️ Step 6: Deploy Functions & Set Secrets
Deploy the backend to Firebase (from the root directory):

bash
Copy code
firebase deploy --only functions
On first deploy, you will:

Enable APIs (Cloud Run, Eventarc, Secret Manager) — choose Yes for all.

Enter secret values (ALGOLIA_APIKEY, ALGOLIA_APPID) securely when prompted.

Paste your Algolia Admin API Key when requested.

⚙️ Step 7: Run the App
Once setup is complete:

bash
Copy code
flutter run
📁 Project Structure
bash
Copy code
auteurly/
│
├── functions/              # Backend (Cloud Functions)
│   ├── src/
│   │   ├── index.ts        # Main Cloud Functions (Triggers, Push Notifications, Algolia Sync)
│   ├── package.json        # NPM dependencies
│   └── .eslintrc.js        # Linter rules
│
├── lib/                    # Flutter App Code
│   ├── core/
│   │   ├── models/         # Dart models (UserModel, ProjectModel, CreditModel)
│   │   ├── services/       # Firestore, Auth, and Storage Services
│   │   └── widgets/        # Shared UI components
│   │
│   ├── features/           # Feature-based architecture
│   │   ├── auth/           # Login, Register, AuthWrapper
│   │   ├── components/     # ProjectCard, ProfessionalCard
│   │   ├── home/           # Home Page, TabBar, Feed
│   │   ├── notifications/  # InboxScreen, NotificationTile
│   │   ├── profile/        # User Profile screens
│   │   └── projects/       # Project Details, Edit Project
│   │
│   └── main.dart           # App entry point & theme
│
├── android/                # Native Android configuration
│   └── src/main/AndroidManifest.xml
│
├── ios/                    # Native iOS configuration
│
└── pubspec.yaml            # Flutter dependencies
## 🎨 UI Mockups
Explore the full design prototype for **Auteurly** on Figma:  
🔗 [View Figma Design](https://www.figma.com/design/JwrBQuJBnsmzNojcn71QHZ/Auteurly?node-id=105-8&t=SlsnkLCutTCfSlbZ-1)




🧑‍💻 Author
Eyiniola Fagbemi
📍 Kigali, Rwanda


📜 License
© 2025 Eyiniola Fagbemi — All Rights Reserved.
