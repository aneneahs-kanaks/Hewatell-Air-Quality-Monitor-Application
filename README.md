# 🌱 Hewatell

**Hewatell** is a Flutter-based environmental monitoring application designed to allow users to register monitoring devices and view environmental data collected from those devices.

The application provides a simple dashboard for viewing current sensor readings and requesting previously recorded environmental data.

## ✨ Features

* 🔐 **User Sign-In Interface** *(authentication flow in progress)*
* 📱 **Device Registration**
* 📋 **Registered Device Selection**
* 📊 **Current Environmental Data**
* 📅 **Historical/Previous Data** with a date/time range request
* 📈 **Interactive Charts** for CO₂, Nitrogen, VOC, Dust and Ethylene
* 📍 **Device Location Management** (logs are tagged with their location)
* ☁️ **Firebase Firestore Integration**

## 🏗️ How It Works

```text
Environmental Sensors
        ↓
      ESP32
        ↓
    Firebase
        ↓
   Hewatell App
        ↓
 Environmental Dashboard
```

The ESP32-based monitoring device collects environmental measurements and sends the data to Firebase. The Hewatell Flutter application retrieves the data and presents it to the user through the dashboard.

## 🖥️ Application Structure

### 1. Sign In

Provides the user interface for signing into the application.

### 2. Device Registration

Users can register monitoring devices by providing:

* Device ID
* Device location

Registered devices are stored in Firebase Firestore.

### 3. Device Selection

Users can select one of their registered devices from a dropdown menu or add a new device.

### 4. Dashboard

**Current Data**

Displays the latest available environmental measurements from the selected device.

**Previous Data (Historical Analytics)**

Allows the user to select a date/time range and tap **Request Data**. The app then shows:

* A parameter selector (CO₂, Nitrogen, VOC, Dust, Ethylene)
* A line chart of the chosen parameter over time
* A count of captured data points
* A log list showing the location, time and readings for each point

## 🛠️ Technologies Used

| Technology      | Purpose                               |
| --------------- | ------------------------------------- |
| Flutter         | Mobile application development        |
| Dart            | Application programming language      |
| Firebase        | Backend services                      |
| Cloud Firestore | Device and environmental data storage |
| ESP32           | Environmental monitoring controller   |
| Sensors         | Environmental data collection         |

## 📂 Firestore Structure

```text
devices
 ├── deviceId
 └── location

environmentData
 ├── deviceId
 ├── sensor readings
 └── createdAt
```

The `createdAt` field is used to identify and retrieve the latest environmental measurements.

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Firebase project
* Android device or emulator

### Clone the Repository

```bash
git clone https://github.com/aneneahs-kanaks/EcoSense.git
cd EcoSense
flutter pub get
```

### Firebase Configuration

Create a Firebase project and connect it to the Flutter application. Configure Firebase for the required platforms and make sure the appropriate Firebase configuration files are included in the project.

Then run:

```bash
flutter run
```

## 📱 Current Project Status

Hewatell is currently under development.

The main Flutter interface, device registration flow, Firestore integration, device selection, and the historical analytics dashboard are being developed and tested incrementally.

Some parts of the system, including the physical sensor hardware and complete authentication flow, are still being integrated.

## 🔮 Future Improvements

* Real-time sensor data updates
* Complete Firebase Authentication
* More environmental sensors
* Device management
* Notifications and alerts
* Improved dashboard analytics
* Integration with the complete ESP32 monitoring system

## 👩🏽‍💻 Author

**Annastacia Ndunge**

Electrical & Electronic Engineering Student, DeKUT

* GitHub: [@aneneahs-kanaks](https://github.com/aneneahs-kanaks)

---

⭐ **Hewatell is being developed as a practical environmental monitoring system combining embedded systems, cloud services, and mobile application development.**
