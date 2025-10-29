# 🎬 Auteurly

**Auteurly** is a professional networking platform designed to connect the fragmented community of film professionals in Rwanda's emerging film industry, *Hillywood*.  
It provides a **centralized, verifiable, and searchable registry** that replaces informal, word-of-mouth hiring with a transparent, merit-based system.

The platform aims to **enhance the visibility** of local talent, **foster collaboration**, and **attract international productions** by offering the foundational infrastructure for a more formal and equitable creative ecosystem.

---

## ✨ Features

### 🧑‍🎨 Rich Professional Profiles
- **Project Gallery:** Upload multiple videos, images, or PDFs (with descriptions) to showcase your complete body of work.  
- **Showreel Upload:** Upload a primary showreel video file directly (not just a URL).  
- **Verifiable Credits:** Build trust through verified work history confirmed by project creators.

### 🎥 Project & Credit System
- **Project Creation:** Add projects with posters, descriptions, and status (e.g., *In Production*, *Completed*), including crew details.  
- **Peer Credit Verification:** Add crew members who receive notifications to verify their credits.  
- **Project Join Requests:** Allow users to request to join projects in specific roles, notifying creators for approval or denial.

### 💬 Real-time & Interactive
- **Direct Messaging:** Built-in private chat for professional communication.  
- **Push Notifications:** Alerts for new messages, credit verifications, and project join requests — even when the app is closed (via FCM & Cloud Functions).  
- **Live Presence:** Real-time online/offline status (powered by Firebase Realtime Database).

### 🔍 Discovery & UI
- **Advanced Search & Filtering:** Search engine powered by **Algolia** to find talent by role, skills, availability, etc.  
- **Dynamic Card Colors:** Project feed cards adapt background colors based on poster images.  
- **Custom Theming:** Dark theme with *Monoton* headlines and *Montserrat* body text.

### 🔒 Secure & User-Friendly
- **Secure Authentication:** Sign up or log in with Email/Password or Google.  
- **Error Handling:** Custom, dismissible error messages (e.g., *Passwords do not match*, *User not found*).

---

## 📱 UI Mockups
Explore the visual design and user experience on Figma:  
🔗 [Figma Design](https://www.figma.com/design/JwrBQuJBnsmzNojcn71QHZ/Auteurly?node-id=0-1&t=q53wMLrTa4JoVCOb-1)

---

## 🧩 GitHub Repository
🔗 [Auteurly GitHub](https://github.com/Eyiniola/autueurly.git)

---

## 🛠️ Tech Stack

| Layer | Technology |
|--------|-------------|
| **Front-end** | Flutter (iOS, Android & Web) |
| **Back-end** | Firebase (Backend-as-a-Service) |
| **Authentication** | Firebase Authentication |
| **Database** | Cloud Firestore |
| **Real-time Presence** | Firebase Realtime Database |
| **File Storage** | Cloud Storage for Firebase |
| **Serverless Logic** | Cloud Functions for Firebase (TypeScript, 2nd Gen) |
| **Search Engine** | Algolia |
| **Design** | Figma |

---

## 🚀 Getting Started

Follow these instructions to set up the project locally for development and testing.

### ✅ Prerequisites
- Flutter SDK installed  
- Firebase CLI installed → `npm install -g firebase-tools`  
- Node.js installed (for Cloud Functions)  
- Firebase project with the **Blaze (pay-as-you-go)** plan enabled (required for 2nd Gen Functions)

---

### ⚙️ Installation & Setup

#### 1. Clone the Repository
```bash
git clone https://github.com/Eyiniola/autueurly.git
cd auteurly
