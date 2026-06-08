# UniSafe - An Anonymous Campus Incident Reporting Mobile Application

UniSafe is a mobile application developed to enhance campus safety and student well-being within Universiti Malaysia Sarawak (UNIMAS). The application provides a secure and anonymous platform for students to report campus-related incidents, seek support, and communicate with counsellors while protecting their privacy.

## Tech Stack

- **Flutter** – Cross-platform mobile application development.
- **Firebase Authentication** – Secure user authentication and authorization.
- **Cloud Firestore** – Real-time database for storing application data.
- **Firebase Cloud Storage** – Storage for report attachments and media files.
- **Firebase Cloud Messaging (FCM)** – Push notifications and alerts.
- **Dart** – Programming language used for Flutter development.
- **Visual Studio Code** – Development environment.

## Features

### 1. User Authentication & Authorization
- Secure user registration and login.
- Role-based access control for students and counsellors.
- User profile management.

### 2. Anonymous Incident Reporting
- Submit campus-related incident reports anonymously.
- Upload supporting evidence such as images.
- Track report status and responses.

### 3. Real-Time Messaging
- One-to-one communication between students and counsellors.
- Real-time message synchronization.
- Read-status updates.

### 4. Community Forum
- Create and participate in discussion threads.
- Share experiences and seek peer support.
- Community-driven engagement.

### 5. Event Management
- View campus safety and awareness events.
- Stay updated with university programmes and activities.

### 6. Hotline Support Directory
- Quick access to emergency contacts and support services.
- Centralized hotline information for students.

### 7. Chatbot Assistant
- Rule-based chatbot for answering frequently asked questions.
- Guidance on reporting procedures and campus safety resources.

### 8. Self-Check Assessment
- Mental well-being self-assessment questionnaire.
- Risk classification and assessment history tracking.

### 9. Counsellor Dashboard
- Manage incident reports.
- Monitor student cases.
- Manage events, forums, and hotline information.
- View system statistics and reports.

## System Architecture

UniSafe adopts a client-server architecture using Flutter as the frontend framework and Firebase as the backend platform.

Firebase services include:

- Authentication
- Cloud Firestore Database
- Cloud Storage
- Firebase Cloud Messaging (FCM)
- Real-time Synchronization

## Project Objectives

- Design a secure and anonymous platform for incident reporting.
- Develop an intuitive and user-friendly mobile application.
- Improve communication between students and counsellors.
- Promote early intervention for campus safety and mental well-being concerns.
- Evaluate system usability among UNIMAS students.

## Installation Guide

### Prerequisites

- Flutter SDK
- Android Studio or Visual Studio Code
- Firebase Project Configuration
- Android Emulator or Physical Device

### Clone Repository

```bash
git clone https://github.com/yourusername/unisafe.git
cd unisafe
```

### Install Dependencies

```bash
flutter pub get
```

### Configure Firebase

1. Create a Firebase project.
2. Add Android and/or iOS applications.
3. Download the Firebase configuration files:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
4. Place the files in the appropriate directories.
5. Enable Authentication, Firestore, Storage, and Cloud Messaging.

### Run the Application

```bash
flutter run
```

## Application Modules

### Student Features
- User Registration & Login
- Anonymous Incident Reporting
- Forum Participation
- Event Viewing
- Real-Time Messaging
- Chatbot Assistance
- Self-Check Assessment
- Hotline Information Access
- Profile Management

### Counsellor Features
- Dashboard Management
- Incident Report Management
- Student Communication
- Forum Management
- Event Management
- Hotline Information Management
- User Monitoring

## Testing

The application has been evaluated through:

- Functional Testing
- Integration Testing
- Usability Testing
- System Usability Scale (SUS) Evaluation

## Future Enhancements

Potential future improvements include:

- AI-powered NLP chatbot
- Advanced analytics dashboard
- Multi-university deployment support
- Emergency SOS functionality
- Enhanced notification and escalation mechanisms
- Integration with university support departments

## Contributing

1. Fork the repository.
2. Create your branch:

```bash
git checkout -b feature/YourFeature
```

3. Commit your changes:

```bash
git commit -m "Add new feature"
```

4. Push to the branch:

```bash
git push origin feature/YourFeature
```

5. Open a Pull Request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Author

**Lee Chun Pan**  
84297@siswa.unimas.my
Bachelor of Software Engineering with Honours  
Faculty of Computer Science and Information Technology (FCSIT)  
Universiti Malaysia Sarawak (UNIMAS)

---

If you encounter any issues or have suggestions for improvement, feel free to create an issue in the repository.
