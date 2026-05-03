# 💎 DEDO v3 - Liquid Glass Todo App

DEDO is a complete, production-ready Flutter task management application that strictly adheres to an elite iOS 26 Liquid Glass (glassmorphism) design language. 

## ✨ Features

- **Liquid Glass UI:** Every single UI component (modals, navbars, inputs, buttons, cards) utilizes a dynamic `BackdropFilter` to create a stunning semi-transparent frosted glass effect with layered depth.
- **Adaptive Theming:** Instant, Riverpod-managed light and dark modes that dynamically adjust glass blurs, opacity gradients, and glow intensities.
- **Task Management:** Full CRUD capabilities for tasks. Supports notes, date pickers, start/end times, category labels, and specific color tagging.
- **Background Notifications:** Uses `flutter_local_notifications` for precisely scheduled alerts (5-30 min pre-reminders, start-time alerts, and end-time alerts).
- **Categories:** Custom task grouping with editable categories and dedicated color palettes.
- **Analytics & Profile:** Includes dynamic glass-styled graphs using `fl_chart`, showcasing daily/weekly completion rates and day streaks.
- **Data Persistence:** Completely offline-first with ultra-fast edge local data storage built on **Hive**.
- **Micro-animations:** Smooth scale, fade, and slide transitions using custom animation controllers to enhance the fluid glassy aesthetic.

## 🛠 Tech Stack

- **Framework:** Flutter (latest stable)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Local Storage:** Hive
- **Notifications:** `flutter_local_notifications`
- **Analytics Charts:** `fl_chart`
- **Fonts:** Google Fonts (Outfit)

## 🏗 Architecture

The app follows a clean, modular feature-first architecture:
- `core/`: Application-wide glass theme tokens (`GlassTheme`), and foundational glass components (`GlassContainer`, `GlassTextField`, `GlassButton`).
- `features/`: Divided by domain (Home, Task, Category, Profile, Onboarding).
- `models/`: Manually configured Hive `TypeAdapter` data models for Tasks, Categories, and User Profiles (zero dependency on code-gen delays).
- `providers/`: Riverpod logical state distributors.
- `services/`: Specialized service classes for Hive database init and background notification scheduling.

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Vivek-k001/Dedo-v3.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the application:**
   ```bash
   flutter run
   ```

*Note: For the best experience with background push notifications and animations, compile and run the app directly on an Android/iOS emulator or a physical mobile device.*

## 🤝 Developed By
**VNJ Softworks**
Contact: sdedodedo80@gmail.com
