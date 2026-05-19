# 🚨 Smart Sakhi (smart_sakhi_app)

**Smart Sakhi** ek advanced, high-fidelity aur fast-response women's safety aur cyber blackmail prevention mobile application hai jo Flutter aur Firebase ke premium stack par aadharit hai. Is app ka mukhya uddeshya mahilaon ko emergency situations aur digital threats (jaise blackmailing, stalking, aur photo misuse) se surakshit rakhna aur jald se jald police, cyber cell aur trusted contacts se contact karwana hai.

---

## 🌟 Key Features

1. **Emergency SOS Pulse Button**: Ek custom animated button jo trigger hote hi live location share, background audio recording aur emergency SMS alert direct dispatch karta hai.
2. **Cyber Complaint Vault**: Blackmail aur photo threat ke cases me screenshots, chat leaks aur media documents ko encrypt karke seedhe Cyber Crime cell ko submit karne ki suvidha.
3. **Emergency Helpline Integration**: Direct 112, 1091 (Women Helpline) aur 1930 (Cyber Crime Helpline) par call lagane ki suvidha.
4. **Interactive Dashboard & Nearby Stations**: Maps integration ke sath nearest Police stations aur hospitals ki list aur distance calculation.
5. **Shake to Trigger SOS**: Emergency situations me jab screen use karna mushkil ho, phone shake karte hi background trigger active ho jata hai.

---

## 🏗️ MVC Directory Structure

Project ko clean, scalable aur testable rakhne ke liye **Model-View-Controller (MVC)** design pattern follow kiya gaya hai:

```
lib/
├── model/                 # Data Models (User, Complaint, Contact, Location)
├── controller/            # Business Logic & ChangeNotifier State Controllers
├── view/                  # UI Screens (Splash, Auth, Home Dashboard, Cyber Reports)
├── services/              # Base services (SMS, Location, Audio Recorder)
├── widgets/               # Custom Reusable Widgets (SOS button, custom textfields)
├── utils/                 # Theme styling (Colors, Validators, Constants)
└── main.dart              # Application Entry Point
```

---

## 🛠️ Required Packages (`pubspec.yaml`)

```yaml
# State Management
provider: ^6.1.2

# Firebase & Database
firebase_core: ^3.1.0
firebase_auth: ^5.1.0
cloud_firestore: ^5.0.1
firebase_storage: ^12.0.1

# Maps & Location
google_maps_flutter: ^2.6.1
geolocator: ^12.0.0
location: ^6.0.2
geocoding: ^3.0.0

# Platform Integrations
url_launcher: ^6.3.0
telephony: ^0.2.0
flutter_sms: ^2.3.3
shake: ^2.2.0
sensors_plus: ^6.0.0

# Media
record: ^5.1.2
camera: ^0.11.0+1
image_picker: ^1.1.2
video_player: ^2.8.6
```

---

## 🚦 SOS Working Workflow

1. **Trigger**: User dashboard par deep-red glowing SOS button press karti hai ya phone ko shake karti hai.
2. **Location**: Background geolocation service turant GPS latitude aur longitude fetch karti hai.
3. **Alert Dispatch**: SMS aur internet ke zariye custom tracking link parent/trusted contacts aur nearest police control center ko jata hai.
4. **Evidence Collection**: Background audio recording automatically chalu ho jati hai taaki abuse ka clear proof record ho sake.
5. **Emergency Call**: Telephony API direct 112 / 1091 helpline trigger karti hai.

---

## 🇮🇳 India Me Similar Apps

1. **112 India (Govt of India)**: Centralized emergency alerts.
2. **National Cyber Crime Portal (cybercrime.gov.in)**: Official portal for cyber complaints.
3. **Himmat Plus (Delhi Police)**: Women safety app with active location alarms.
4. **My Safetipin**: Area-wise safety maps & safety scores.

---

## 🚀 Getting Started

1. Is project ko download/clone karein.
2. Dependencies sync karne ke liye run karein:
   ```bash
   flutter pub get
   ```
3. Firebase console par project banakar, `google-services.json` (Android) aur `GoogleService-Info.plist` (iOS) folders me place karein.
4. Run standard build:
   ```bash
   flutter run
   ```

Design kiya gaya hai **Antigravity AI (Google Deepmind Team)** dwara aapke aur poore desh ki mahilaon ki suraksha ke liye. 🛡️
