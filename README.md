# Hedieaty - Gift List Management App

## Overview
Hedieaty is a mobile application designed to streamline the process of creating, managing, and sharing wish lists for special occasions. Built with Flutter, this app enables users to create and manage gift lists, share them with friends and family, and coordinate gift-giving through a pledge system.

## Features
- **User-friendly Interface**: Easy-to-navigate design with multiple pages for managing events and gifts
- **Gift List Management**: Create, edit, and delete gift lists for various occasions
- **Real-time Updates**: Synchronization across devices using Firebase Realtime Database
- **Friend System**: Connect with friends and view their gift lists
- **Pledge System**: Friends can pledge to purchase gifts from your lists
- **Notification System**: Get notified when friends pledge gifts or make updates

## Requirements
- Flutter
- Android Studio
- Firebase account
- SQLite
- Internet connection for real-time features

## Installation
1. Clone the repository
```bash
git clone https://github.com/AbdoSalah22/hedieaty-app-public.git
cd hedieaty
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a new Firebase project
- Add your `google-services.json` to the Android app
- Add your `GoogleService-Info.plist` to the iOS app
- Update Firebase configuration in the project

4. Run the app
```bash
flutter run
```

## Testing
The project includes comprehensive testing scenario that covers the entire application while screen recording and pulling the video from emulator to developer machine.

### Running Test Script
```bash
./run_test.ps1  # For Windows
```


## Database Schema
### Local Storage (SQLite)
- Users ( id, username, profilePictureURL, isSynced )
- Events ( id, name, description, location, date, status, isSynced, *userId* )


## Firebase Cloudstore Hierarchy
```txt
Users (Collection)
└── UserID (Document)
    └── My Pledged Gifts (Sub-Collection)
        └── Events (Sub-Collection)
            └── EventID (Document)
                └── Gifts (Sub-Collection)
                    └── GiftID (Document)
```


## Notifications
The project includes Firebase Cloud Messaging service which delivers real-time notifications to users.
