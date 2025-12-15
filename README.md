# DeskLink 📱💻
> **Control your PC from your Phone via WiFi.**

**DeskLink** is a powerful, open-source tool that turns your Android phone into a seamless remote control for your Windows PC. Whether you want to control Netflix from your bed, manage presentations, or use your phone as a trackpad/keyboard, DeskLink makes it instant and easy.

![DeskLink Banner](https://www.freepik.com/icon/responsive_9594715#fromView=search&page=1&position=61&uuid=af09e91f-958b-4f57-866f-01b1895df375))

---

## ✨ Key Features

* **🖱️ Zero-Latency Trackpad:** Smooth mouse movement with Left & Right click support.
* **⌨️ Real-Time Keyboard:** Type on your phone, see it appear instantly on your PC (Emoji supported! 😀).
* **📋 Clipboard Sync:** Copy text on PC → Paste on Phone (and vice versa).
* **🎛️ Media Controls:** Volume Up/Down, Mute, Play/Pause.
* **🚀 One-Tap Shortcuts:** Open YouTube, Netflix, Calculator, Notepad, or Lock Screen instantly.
* **📊 System Monitor:** View your PC's real-time CPU & RAM usage on your phone.
* **🔒 Secure & Local:** Runs entirely on your local WiFi. No data leaves your room.

---
## 🏗️ System Architecture

```mermaid
%%{init: {'theme': 'base'}}%%
graph LR
    %% --- Definitions and Styling ---
    classDef frontend fill:#e3f2fd,stroke:#1e88e5,stroke-width:2px,color:#0d47a1;
    classDef backend fill:#f3e5f5,stroke:#8e24aa,stroke-width:2px,color:#4a148c;
    classDef infra fill:#fff3e0,stroke:#fb8c00,stroke-width:2px,stroke-dasharray: 5 5;
    classDef osLayer fill:#eceff1,stroke:#b0bec5,stroke-width:1px;

    %% --- Subgraphs ---
    subgraph Mobile["📱 Android Phone (Frontend)"]
        Flutter[Flutter App]:::frontend
        Trackpad[Trackpad & Keyboard UI]:::frontend
        Shortcuts[Shortcut Buttons]:::frontend
        StatsUI[System Stats View]:::frontend
    end

    subgraph Network["📡 Local WiFi Network"]
        Router((WiFi Router)):::infra
    end

    subgraph Computer["💻 Windows PC (Backend)"]
        GoServer[("Go Server (main.go)")]:::backend
        WSHandler[WebSocket Handler]:::backend
        SysControl["System Controller (control_windows.go)"]:::backend
        ClipboardWatcher[Clipboard Watcher]:::backend
    end

    subgraph WindowsOS["🪟 Windows OS Internals"]
        User32["user32.dll / WinAPI"]:::osLayer
        Hardware[Keyboard/Mouse Drivers]:::osLayer
        OSData["CPU/RAM/Clipboard Memory"]:::osLayer
    end

    %% --- Main Connections (Thick Arrows) ---
    Flutter <==>|Bidirectional WebSocket JSON| Router
    Router <==>|Port 8080| GoServer

    %% --- Internal Flow on PC ---
    GoServer --> WSHandler
    WSHandler -->|Commands: Mouse, Key, Type| SysControl
    SysControl -->|Simulate Input| User32
    User32 -->|Press Keys/Move Cursor| Hardware

    ClipboardWatcher -.->|Read New Text| OSData
    OSData -.->|Read Usage Stats| SysControl
    
    ClipboardWatcher -->|Send Updates| WSHandler
    SysControl -->|Send Stats| WSHandler

    %% --- Apply Subgraph Styles ---
    style Mobile fill:#f1f8ff,stroke:#1e88e5,stroke-width:1px
    style Computer fill:#fafafa,stroke:#8e24aa,stroke-width:1px
    style WindowsOS fill:#eceff1,stroke:none
    style Network fill:#fffbf5,stroke:none
```

## 🛠️ Technology Stack

* **Frontend (Mobile App):** [Flutter](https://flutter.dev/) (Dart) - Beautiful, cross-platform UI.
* **Backend (PC Server):** [Go](https://go.dev/) (Golang) - High-performance, low-level system control.
* **Communication:** WebSockets (Real-time, bidirectional data sync).
* **System API:** Windows `user32.dll` for native hardware input simulation.

---

## 🚀 Getting Started

### Prerequisites
1.  A **Windows PC** (Windows 10/11).
2.  An **Android Phone**.
3.  Both devices must be connected to the **Same WiFi Network**.

### 📥 Installation

#### 1. The PC App (Server)
1.  Download the latest `desklink.exe` from the [Releases](#) page.
2.  Double-click `desklink.exe` to run it.
3.  **Important:** If Windows Firewall asks, click **"Allow Access"** (Check both Private & Public networks).
4.  A black terminal window will open. Minimize it (Do not close it).

#### 2. The Android App (Client)
1.  Download and install the `app-release.apk` on your phone.
2.  Open the app.

---

## 🎮 How to Use

1.  **Find PC IP Address:**
    * On your PC, open Command Prompt (`cmd`) and type `ipconfig`.
    * Look for the **IPv4 Address** (e.g., `192.168.1.5`).
2.  **Connect:**
    * Enter this IP in the DeskLink mobile app and tap **Connect**.
3.  **Enjoy:**
    * **Remote Tab:** Use shortcuts like Calc, YouTube, Volume.
    * **Trackpad Tab:** Move cursor, tap to click, hold for right-click. Type in the text box for keyboard input.
    * **Stats Tab:** Monitor your PC's health.

---

## 🧑‍💻 Developer Setup (Build from Source)

If you want to modify the code or contribute, follow these steps.

### Backend (Go)
```bash
cd backend
# Install dependencies
go mod tidy
# Run normally
go run cmd/server/main.go
# OR Build .exe
go build -o desklink.exe cmd/server/main.go

```

### Frontend (Flutter)
```bash
cd frontend
# Install dependencies
flutter pub get
# Run on emulator/device
flutter run
# Build APK
flutter build apk --release
```

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.


Made with ❤️ by [Kunal]

