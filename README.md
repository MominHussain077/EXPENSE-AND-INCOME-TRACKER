# 💰 EXPENSE AND INCOME TRACKER

A beautiful and feature-rich **Expense & Income Tracker** application built with Flutter and Firebase. Track your income and expenses, view your balance, and manage your finances with ease!

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features

- 🔐 **User Authentication** - Secure sign up and sign in with Firebase Auth
- 💵 **Income Tracking** - Add, edit, and delete income entries
- 💸 **Expense Tracking** - Categorize and manage your expenses
- 📊 **Balance Overview** - Real-time balance calculation
- 🎨 **Beautiful UI** - Modern gradient design with Material 3
- ☁️ **Cloud Sync** - Data stored securely in Firebase Firestore
- 📱 **Cross-Platform** - Works on Android, iOS, Web, Windows, macOS, and Linux

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | UI Framework |
| Dart | Programming Language |
| Firebase Auth | User Authentication |
| Cloud Firestore | Database |
| Riverpod | State Management |
| intl | Date Formatting |

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── auth_screen.dart             # Authentication UI
├── firebase_options.dart        # Firebase configuration
├── models/
│   ├── expense.dart             # Expense data model
│   └── income.dart              # Income data model
├── providers/
│   └── expense_provider.dart    # Riverpod state management
├── screens/
│   ├── home_screen.dart         # Main dashboard
│   ├── expense_form_screen.dart # Add/Edit expense
│   └── income_form_screen.dart  # Add/Edit income
└── services/
    ├── expense_service.dart     # Expense CRUD operations
    └── income_service.dart      # Income CRUD operations
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.10.4)
- Dart SDK (^3.10.4)
- Firebase account
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/MominHussain077/EXPENSE-AND-INCOME-TRACKER.git
   cd EXPENSE-AND-INCOME-TRACKER
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable **Email/Password** authentication
   - Create a **Cloud Firestore** database
   - Run FlutterFire CLI to configure:
     ```bash
     flutterfire configure
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

| Package | Version | Description |
|---------|---------|-------------|
| firebase_core | ^4.3.0 | Firebase initialization |
| firebase_auth | ^6.1.3 | User authentication |
| cloud_firestore | ^6.1.1 | Cloud database |
| flutter_riverpod | ^2.3.3 | State management |
| intl | ^0.18.0 | Date formatting |
| cupertino_icons | ^1.0.8 | iOS style icons |

## 🎯 Expense Categories

- 🍕 Food
- 🚗 Transport
- 🛒 Shopping
- 🎬 Entertainment
- 💡 Bills
- 🏥 Health
- 📚 Education
- 📦 Other

## 👨‍💻 Author

**Momin Hussain**
- GitHub: [@MominHussain077](https://github.com/MominHussain077)

---

⭐ **Star this repo if you find it helpful!**
