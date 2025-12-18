# 🚀 JobFinder: AI-Powered Job Search App

A modern, cross-platform mobile application built with **Flutter** that delivers a seamless job-hunting experience. This app connects to a custom FastAPI backend to provide real-time, AI-analyzed job listings.

## ✨ Key Highlights

- **Google Authentication:** Secure login flow integrated with Firebase Auth.
- **AI Job Insights:** Displays smart-extracted data (Salaries, Skills, Seniority) via OpenAI.
- **Persistent Favorites:** Save jobs to your personal profile using a custom backend.
- **Secure Networking:** Implemented **JWT** handling with **Dio Interceptors** for automatic token refreshing.

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart), Provider (State Management), Dio (Networking)
- **Backend:** [View Backend Repo](https://github.com/mmkelzeiny-dev/job-finder-backend)
- **Auth:** Firebase Google Sign-In

---

## ⚙️ Local Setup Instructions for Developers

### 1. Clone & Install

```bash
git clone https://github.com/mmkelzeiny-dev/job-finder-app.git
cd job-finder-app
flutter pub get
```

2. Firebase Configuration
   Download your google-services.json from the Firebase Console.
   Place the file in the android/app/ directory of this project.

3. API Configuration
   Update the baseUrl in your code (usually in your API service file) to point to your FastAPI server IP:

```dart
static const String baseUrl = "http://YOUR_IP_ADDRESS:8000";
```

4. Run the App

```bash
flutter run
```
