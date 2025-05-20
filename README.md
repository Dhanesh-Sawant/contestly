# Contestly
[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/Dhanesh-Sawant/contestly)

Contestly is your ultimate companion for staying on top of competitive programming contests and tracking your progress across major platforms like LeetCode, Codeforces, and CodeChef.

## 📋 Table of Contents

- [About Contestly](#about-contestly)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Set up environment variables](#set-up-environment-variables)
  - [Set up Firebase](#set-up-firebase)
  - [Run the application](#run-the-application)
- [Contributing](#contributing)
- [License](#license)
- [Feedback and Support](#feedback-and-support)

## 🔍 About Contestly

Contestly is a mobile application designed for competitive programmers who want to stay updated on coding contests from platforms like LeetCode, Codeforces, AtCoder, CodeChef, and more. By leveraging a seamless integration with the [clist.by API](https://clist.by/), it ensures all contest data is updated and stored in Supabase, offering a scalable and efficient backend.

With Contestly, you can:
*   Get detailed user stats across platforms.
*   Set personalized reminders for contests.
*   Organize and track your competitive programming schedule.

## ✨ Key Features

*   **Comprehensive Contest Listings:** Displays ongoing, upcoming, and today's contests from a variety of competitive programming platforms including Codeforces, CodeChef, LeetCode, AtCoder, TopCoder, SPOJ, HackerRank, HackerEarth, and GeeksforGeeks. Contests are categorized for easy navigation.
*   **User Authentication:** Secure sign-up and login using email/password or Google Sign-In, powered by Supabase Auth.
*   **Personalized Statistics:** Track your rank, leaderboard position, solved problems, and other stats across LeetCode, Codeforces, and CodeChef.
*   **Platform Filtering:** Customize your contest feed by selecting your preferred coding platforms.
*   **Versatile Reminder System:**
    *   **In-app Alarms:** Set customizable alarms using custom audio files selected by the user.
    *   **Push Notifications:** Schedule notifications for upcoming contests.
    *   **Google Calendar Integration:** Add contest events directly to your Google Calendar for better planning.
*   **User Feedback:** Integrated feedback form to collect user suggestions and app reviews.

## 🛠️ Tech Stack

*   **Frontend:** Flutter
*   **Backend Services:** AWS Lambda (for backend API requests, e.g., to `clist.by`)
*   **Database & Auth:** Supabase (PostgreSQL, Authentication, Realtime, Storage)
*   **APIs Integrated:**
    *   [clist.by API](https://clist.by/): For contest data aggregation.
    *   Individual Platform APIs: For user statistics from LeetCode, Codeforces, CodeChef.
    *   Google Calendar API: For adding contest reminders to user calendars.
*   **Notifications:** Flutter Local Notifications, Alarm Manager
*   **Analytics & Monitoring:** Firebase Crashlytics, Firebase Performance
*   **Advertisements:** Google Mobile Ads

## 🏗️ Architecture Overview

Contestly fetches comprehensive contest data from various platforms using the [clist.by API](https://clist.by/). This data can be periodically retrieved (potentially via a backend service like AWS Lambda) and stored in a Supabase PostgreSQL database. The Flutter application then interacts with Supabase to display contest information, manage user profiles, authentication, and preferences. User-specific statistics are fetched directly from platform APIs like Codeforces, LeetCode, and CodeChef.

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK: Ensure Flutter is installed. Refer to the [official Flutter documentation](https://flutter.dev/docs/get-started/install).
*   A Supabase account: For setting up the backend database and authentication. Get started at [supabase.com](https://supabase.com/).
*   API keys/credentials for:
    *   `clist.by` (if used for fetching data)
    *   Google Cloud Platform (for Google Sign-In, Google Calendar API).
    *   Firebase project setup (for Crashlytics, Performance, and other Firebase services).

### Installation
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Dhanesh-Sawant/contestly.git
    cd contestly
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

### Set up environment variables
Create a `.env` file in the root of the project and add your Supabase URL, Supabase anon key, Google Server Client ID, and any other required API keys.
Example `.env` file:
```env
supabaseUrl=YOUR_SUPABASE_URL
anonKey=YOUR_SUPABASE_ANON_KEY
serverClientId=YOUR_GOOGLE_SERVER_CLIENT_ID_FOR_SIGN_IN
# Add other API keys if necessary
```

### Set up Firebase
Ensure you have a Firebase project set up and the `lib/firebase_options.dart` file is correctly configured for your Android (and iOS if applicable) app. This is typically done using the FlutterFire CLI.

### Run the application
```bash
flutter run
```

## 🤝 Contributing

We welcome contributions to Contestly! If you'd like to contribute, please follow these steps:

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix:
    ```bash
    git checkout -b feature/your-feature-name
    ```
3.  Make your changes and commit them:
    ```bash
    git commit -m "feat: Describe your feature or fix"
    ```
4.  Push your changes to your forked repository:
    ```bash
    git push origin feature/your-feature-name
    ```
5.  Open a Pull Request against the `main` branch of the original repository.

Please ensure your code adheres to the project's coding standards (linting rules are defined in `analysis_options.yaml`).

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

## 💬 Feedback and Support

If you encounter any issues or have suggestions for improvement, please open an issue on the GitHub repository.