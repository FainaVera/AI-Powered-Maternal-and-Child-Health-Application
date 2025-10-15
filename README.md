## Overview
This AI-powered maternal and child health application built using Dart, JavaScript, MongoDB, and the Groq API, provides a smart, accessible way for healthcare Anganwadi workers and parents to track maternal and child health metrics, receive AI-generated nutritional insights, and evaluate child growth based on WHO standards.
> **Status:** Ongoing (Improvements to design, features, performance)

---

## Features
- **Patient Tracking** – Maintain and manage patient profiles with health records.
- **Appointment Tracking** – Schedule, update, and monitor medical appointments.
- **WHO-Based Child Growth Evaluation** – Analyze growth metrics against WHO child development standards.
- **AI-Powered Nutrition Tips** – Generate personalized dietary and nutrition advice based on the WHO assessment using Groq API.
- **Multi-Language Support** – Built-in support for multiple languages. (Currently includes South Indian languages only, others can be added)
- **MongoDB Data Storage** – Cloud-based data storage for mother and child information.

---

## How to Run

### 1. Prerequisites
- Android Studio  (can be skipped if using device API to test)
- Flutter SDK
- A MongoDB connection
- Groq API key from http://console.groq.com/keys

### 2. Clone the Repository
```bash
git clone https://github.com/FainaVera/AI-Powered-Maternal-and-Child-Health-Application.git
cd AI-Powered-Maternal-and-Child-Health-Application
```
### 3. Install dependencies
```bash
flutter pub get
```
### 4. Configure environment variables
- Add MongoDB connection string and Groq API key to a .env file
- (Or embed it in the code)

### 5. Run the application
```bash
flutter run
```

---

## Usage

1. **Register/Login**: Create an account or log in to access features
2. **Add Patients**: Register pregnant lady or child records
3. **Appointments**: Track next appointment
4. **Monitor Growth**: Track child growth through WHO-based evaluations
5. **AI Tips**: Receive personalized nutrition and care recommendations for each child given by AI
6. **Language Support**: Select preferred language from dropdown
