# Smart QR-Based Attendance Management App

A production-ready Flutter mobile application that enables employees to mark their daily attendance by scanning dynamically generated, time-limited QR codes. Built with the BLoC pattern, SQLite local caching, Dio REST API integration, and GPS geofencing validation.

---

## 🌟 Core Requirements & Features

### 1. Splash Screen (`SplashScreenView.dart`)
- **Branded Logo Animation**: Animated logo scaling and fading transition.
- **Firebase Initialization**: Safely initialized in `main.dart`.
- **Session Check**: Verifies stored login token in `FlutterSecureStorage`.
- **Role-Based Navigation**: Directs employees to Employee Dashboard and admins to Generate QR Page.

### 2. Login Page (`loginPageView.dart`)
- **Credentials Validation**: Validates employee email and password.
- **Forgot Password**: Password reset request capability.
- **Quick Demo Accounts**: One-tap quick auto-fill for testing (`alice@company.com` & `admin@company.com`).
- **BLoC State Management**: Governed by `LoginBloc`.

### 3. Employee Dashboard (`dashboardView.dart`)
- **Employee Identification**: Displays name, employee ID, and department with dynamic greetings.
- **Live Attendance Status**: Real-time status badge (*Not Checked In*, *Checked In*, *Shift Completed*).
- **Check-In / Check-Out Actions**: Interactive tiles with timestamps and duplicate prevention.
- **Attendance Summary**: Visual counters for Present, Late, and Absent days, plus Leave Balance and Overtime Hours.
- **Scan QR Action**: Quick shortcut to launch camera scanner.

### 4. Smart QR Scanner (`scannerPageView.dart`)
- **Camera Scanner**: High-performance camera feed powered by `mobile_scanner`.
- **GPS Location Validation**: Enforces geofencing validation with office coordinates using `geolocator`.
- **SHA-256 HMAC Verification**: Cryptographically validates scanned QR payload to eliminate tampering.
- **5-Minute Expiration Enforcement**: Disallows scanning expired QR codes.
- **Single-Use Anti-Replay**: SQLite records prevent reusing the same QR session.
- **REST API Verification**: Integrates backend verification using Dio.
- **Simulator / Demo Quick Scan**: Dedicated button in AppBar for simulator testing without physical camera hardware.

### 5. Attendance History (`attendanceHistoryView.dart`)
- **Chronological Records**: Daily records with date, status, check-in, and check-out timestamps.
- **Date Range Filter**: Filter records by custom start and end dates.
- **Status Badges**: Distinct visual styling for Present, Late, and Absent.

### 6. Profile Page (`profileView.dart`)
- **Employee Details**: Displays employee ID, department, email, phone number, and join date.
- **Logout Action**: Secure sign-out that clears session tokens and returns to login.

### 7. Generate QR Page (`generateQrView.dart`)
- **Dynamic Secure QR**: Generates dynamic QR sessions with UUID and SHA-256 HMAC integrity signatures.
- **Real-Time Countdown**: Live countdown timer displaying remaining valid seconds (5-minute countdown).
- **Auto Expiration**: Automatically marks QR as expired and prompts regeneration.
- **Instant Regeneration**: Replaces expired session with a single tap.

### 8. Employee Management (`employeeManagementView.dart`)
- **Employee Directory**: Comprehensive roster of company employees.
- **Real-Time Search**: Instant filtering by employee name, ID, or department.
- **Employee Details Modal**: Bottom-sheet inspection of complete profile.

### 9. Attendance Management & Reports (`attendanceManagementView.dart`)
- **Organization-Wide Log**: Lists all employee attendance entries.
- **Multi-Filter**: Filter logs by specific employee and date.
- **Attendance Statistics & Reports**: Bottom-sheet report calculating overall attendance rate, on-time arrivals, late arrivals, and export capability.

---

## 🏗️ Architecture & Technology Stack

```
lib/
├── core/
│   └── constant.dart                  # Office GPS coordinates, colors, dummy data, base URL
├── models/
│   ├── attendanceModel.dart           # Attendance model matching API schema
│   ├── employeeModel.dart             # Employee profile model
│   └── qrSessionModel.dart            # QR session model with expiry calculations
├── services/
│   ├── apiService.dart                # Dio client connecting to dummy user attendance endpoint
│   ├── auth_service.dart              # FlutterSecureStorage authentication
│   ├── local_database_service.dart    # SQLite database for records & QR sessions
│   ├── location_service.dart          # Geolocator GPS & geofencing validation
│   └── qr_service.dart                # Cryptographic SHA-256 HMAC signed QR encoding/decoding
├── bloc/
│   ├── login/                         # LoginBloc, LoginEvent, LoginState
│   ├── dashboard/                     # DashboardBloc, DashboardEvent, DashboardState
│   ├── scannerPage/                   # ScannerPageBloc, ScannerPageEvent, ScannerPageState
│   ├── attendance/
│   │   ├── attendanceHistory/         # AttendanceHistoryBloc, Event, State
│   │   └── attendanceManagement/      # AttendanceManagementBloc, Event, State
│   ├── generateQR/                    # GenerateQrBloc, GenerateQrEvent, GenerateQrState
│   ├── employeeManagement/            # EmployeeManagementBloc, Event, State
│   └── profile/                       # ProfileBloc, ProfileEvent, ProfileState
└── view/
    ├── splash/SplashScreenView.dart
    ├── login/loginPageView.dart
    ├── dashboard/dashboardView.dart
    ├── scannerPage/scannerPageView.dart
    ├── attendance/attendanceHistoryView.dart
    ├── attendance/attendanceManagementView.dart
    ├── generateQr/generateQrView.dart
    ├── employeeManagementView/employeeManagementView.dart
    └── profile/profileView.dart
```

---

## 👥 Demo Credentials

| Role | Email | Password | Initial Landing Page |
|---|---|---|---|
| **Employee** | `alice@company.com` | `password123` | Employee Dashboard (`DashboardView`) |
| **Employee** | `bob@company.com` | `password123` | Employee Dashboard (`DashboardView`) |
| **Employee** | `carol@company.com` | `password123` | Employee Dashboard (`DashboardView`) |
| **Admin** | `admin@company.com` | `admin123` | Admin QR Generator (`GenerateQrView`) |

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK 3.24+ installed
- Android SDK / iOS Xcode

### 2. Run Commands
```bash
# Get dependencies
flutter pub get

# Static analysis
flutter analyze

# Unit tests
flutter test

# Run application
flutter run
```
