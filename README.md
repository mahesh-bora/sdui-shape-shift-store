# Shape-Shifting Store

A demonstration of Server-Driven UI (SDUI) architecture that enables real-time app interface changes without Play Store / App Store deployments. The app's entire personality—theme, layout, and components—transforms throughout the day based on server-controlled JSON contracts.

## 🎯 What is Server-Driven UI?

Ever noticed how Instagram or Zomato's layout changes without app updates? That's SDUI. Instead of hardcoding the UI, the app acts as a "rendering engine" that asks the server: *"What should I look like right now?"*

This project demonstrates the same class of server-controlled UI techniques used by large apps such as Instagram, Amazon, and Airbnb to iterate quickly without being blocked by app store releases.

## 🛠️ Tech Stack

- **Backend**: Go server with time-based UI orchestration
- **Frontend**: Flutter with BLoC state management
- **Architecture**: Clean Architecture with separation of concerns
- **Communication**: RESTful JSON contracts

## ✨ Features

- **Time-Based UI Modes**: App transforms 8 times per day (Midnight → Morning → Flash Sale → Night Boutique)
- **Complete Theme Control**: Colors, typography, spacing, border radii—all server-driven
- **Dynamic Layouts**: Server decides component hierarchy (Column, Row, Stack)
- **Server-Driven Navigation**: Routes, deep links, and screen flows controlled via JSON
- **Animation Control**: Transition types, durations, and Lottie/Rive animations from server
- **Feature Flags**: Toggle UI elements without code deployment
- **60fps Performance**: Optimized widget rebuilds with BLoC pattern
- **Fail-Safe Architecture**: Graceful degradation for malformed JSON

## 👨‍💻: App Screenshots

<table>
  <tr>
    <th>Morning</th>
    <th>Flash Sale</th>
    <th>Evening</th>
  </tr>
  <tr>
    <td align="center">
      <img
        src="https://github.com/user-attachments/assets/e9614b11-f515-4a8c-9e5a-e614e5c0bbd2"
        width="260"
        alt="Morning Mode"
      />
    </td>
    <td align="center">
      <img
        src="https://github.com/user-attachments/assets/8957b2a8-a964-453d-8b41-ff62158b4bd2"
        width="260"
        alt="Flash Sale Mode"
      />
    </td>
    <td align="center">
      <img
        src="https://github.com/user-attachments/assets/0a88df3c-29fc-4775-8601-0c349c98662d"
        width="260"
        alt="Evening Mode"
      />
    </td>
  </tr>
</table>


## 🏗️ Architecture

```
┌─────────────┐      JSON Contract        ┌──────────────┐
│   Go Server │ ──────────────────────>   │ Flutter App  │
│             │  { mode: "flash_sale",    │   (BLoC)     │
│ Time-Based  │    theme: {...},          │              │
│ UI Logic    │    components: [...] }    │ Widget       │
└─────────────┘                           │ Builder      │
      │                                   └──────────────┘
      │                                          │
   Decides                                    Renders
   UI Mode                                    Widgets
```

### What the Server Controls

- **Themes & Styling**: Global design tokens (colors, spacing, typography)
- **Component Layout**: Dynamic hierarchies and composition
- **Navigation Flow**: Screen routes and deep linking
- **Animations**: Motion parameters and asset URLs
- **Business Logic**: Feature toggles and conditional rendering

## 📂 Project Structure

```
sdui-shape-shift-store/
└── flutter_app/          # Flutter frontend
    ├── lib/
    │   ├── presentation/
    │   │   └── blocs/    # BLoC state management
    │   ├── domain/
    │   └── data/
    └── sdui_widget_builder.dart
    sdui-server/          # Go backend
    │   ├── main.go
    │   ├── ui_configs.go     # Time-based mode logic
    │   └── produts.go
```

## 🚀 Getting Started

### Prerequisites

- Go 1.21+
- Flutter 3.24+
- Dart SDK

### Running the Go Server

```bash
# Navigate to server directory
cd sdui-server

# Install dependencies
go mod download

# Run the server
go run main.go

# Server will start on http://localhost:8080
```

### Running the Flutter App

```bash
# Navigate to Flutter directory
cd flutter_app

# Install dependencies
flutter pub get

# Update the API endpoint if needed
# const String BASE_URL = 'http://localhost:8080';

# Run the app
flutter run
```

### Quick Start (Both)

```bash
# Clone the repository
git clone https://github.com/mahesh-bora/sdui-shape-shift-store.git

# Terminal 1: Start the Go server
cd sdui-shape-shift-store/sdui-server
go run main.go

# Terminal 2: Start the Flutter app
cd sdui-shape-shift-store/flutter_app
flutter pub get
flutter run
```

## 🎨 UI Modes

The app cycles through 8 distinct modes based on time of day:

| Time | Mode | Visual Style |
|------|------|--------------|
| 12AM - 6AM | Late Night | Minimal, dark theme for midnight browsing |
| 6AM - 9AM | Morning | Bright, energetic morning deals |
| 9AM - 12PM | Day | Standard shopping experience |
| 12PM - 2PM | Flash Sale | Urgent, dense grid layout |
| 2PM - 5PM | Afternoon | Relaxed browsing mode |
| 5PM - 8PM | Evening | Warm evening collections |
| 8PM - 12AM | Night | Boutique-style, curated products |

## 🎓 What This Project Demonstrates

**Beyond Simple Content Swaps**: Full UI orchestration including:

✅ Complete visual identity transformation  
✅ Dynamic layout composition  
✅ Server-controlled navigation  
✅ Runtime animation configuration  
✅ Feature flag implementation  
✅ Production-grade state management  
✅ Graceful error handling  

## ⚠️ Scope & Limitations

This is a **proof-of-concept** demonstrating SDUI fundamentals. A production system would need:

- **Schema Versioning**: Handling contract changes across app versions
- **Analytics Integration**: Tracking layout performance and conversions
- **A/B Testing Infrastructure**: Cohort management and variant assignment
- **Offline Fallback**: Cached UI configs for no-network scenarios
- **Security**: JSON validation and sanitization
- **Error Telemetry**: Monitoring for parse failures and malformed contracts

These weren't needed for understanding core patterns but are critical for real-world deployment.

## 📚 Resources

For the detailed write-up explaining the architecture, design decisions, and learnings, check out:

- [Ghost Updates: Building Apps That Change Without Play Store/App Store Updates](https://maheshbora.hashnode.dev/ghost-updates-building-apps-that-change-without-the-play-storeapp-store-updates)

## 🤝 Contributing

This is a learning project, but contributions are welcome! Feel free to:
- Report bugs
- Suggest improvements
- Add new UI modes
- Enhance documentation

## 📄 License

MIT License - feel free to use this project for learning and experimentation.
