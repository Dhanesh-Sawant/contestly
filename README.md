# Contestly

Your ultimate companion for staying on top of competitive programming contests and tracking your progress across major platforms like LeetCode, Codeforces, and CodeChef.

![Contestly Logo](https://your-image-link.com/logo.png)

## 📋 Table of Contents

- [About Contestly](#about-contestly)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [API and Integrations](#api-and-integrations)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## 🔍 About Contestly

**Contestly** is designed for competitive programmers who want to stay updated on coding contests from platforms like LeetCode, Codeforces, AtCoder, CodeChef, and more. By leveraging a seamless integration with the [clist.by API](https://clist.by/), it ensures all contest data is updated and stored in **Supabase**, offering a scalable and efficient backend. 

With Contestly, you can:
* Get detailed user stats across platforms
* Set personalized reminders for contests
* Organize and track your competitive programming schedule

## ✨ Key Features

### Contest Management
* Displays **ongoing**, **upcoming**, and **today's contests** from various platforms
* Categorizes contests for easy viewing

### User Authentication
* Secure login with **email/password** and **Google sign-in** using Supabase Auth
* Persistent user profiles with saved preferences

### Personalized Stats
* Fetches your **rank**, **leaderboard position**, **solved problems**, and more from:
  * **LeetCode**
  * **Codeforces**
  * **CodeChef**

### Reminder System
* Set reminders in three forms:
  1. **In-app alarm**: Rings a custom audio file selected by the user
  2. **Push notifications**: Notifications can be scheduled
  3. **Google Calendar**: Add contests to your calendar for better planning

### Feedback System
* Built-in feedback form to collect user suggestions and app reviews

## 🛠️ Tech Stack

* **Frontend**: Flutter (for mobile app development)
* **Backend**: AWS Lambda for API requests
* **Database**: Supabase (for scalable data storage and authentication)
* **APIs**:
  * [clist.by API](https://clist.by/)
  * Google Calendar API
* **Authentication**: Supabase Auth (email/password and Google login)

## 🚀 Getting Started

### Prerequisites
* Node.js (for backend testing)
* Flutter SDK (for frontend development)
* Supabase account (for database and authentication)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/contestly.git
   ```

2. Navigate to the project directory:
   ```bash
   cd contestly
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Set up your `.env` file with the following keys:
   * Supabase credentials
   * clist.by API token
   * Google Calendar API token

5. Run the app:
   ```bash
   flutter run
   ```

## 🔗 API and Integrations

### clist.by API
* Provides contest data from various platforms
* Usage in Contestly: Fetched via AWS Lambda to handle rate limits and stored in Supabase

### Google Calendar API
* Allows users to add contest reminders directly to their Google Calendar

### Supabase
* Handles authentication, database storage, and user profiles

## 📸 Screenshots

### Home Screen
[Your screenshot here]

### User Stats
[Your screenshot here]

### Contest Details
[Your screenshot here]

## 🤝 Contributing

We welcome contributions to Contestly! 🎉

Steps to Contribute:
1. Fork the repository
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your message here"
   ```
4. Push to your branch:
   ```bash
   git push origin feature/your-feature-name
   ```
5. Open a Pull Request and describe your changes

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

## 💬 Feedback and Support

If you encounter any issues or have suggestions, feel free to open an issue on GitHub or contact us at support@contestly.com.

⭐ Don't forget to star this repository if you find it helpful!
