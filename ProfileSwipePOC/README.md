
# Profile Swipe POC 🎴

A proof-of-concept iOS app built with **SwiftUI**, showcasing swipeable profile cards (like Tinder) with a profile detail screen.

---

This project demonstrates modern iOS best practices:  
- 🏛 **MVVM architecture** for clean separation of concerns  
- ⚡️ **Swift Concurrency (`async/await`)** for data loading  
- 📂 **Local JSON file** as mock data source  
- 👆 **Swipe gestures** for interactions  
- 🎨 **Dynamic badge overlays** (LIKE / NOPE / SUPER LIKE) 

## ✨ Features
- Swipe **left**, **right**, or **up** on cards:
  - ✅ Right → "Like"  
  - ❌ Left → "Nope"  
  - ⭐️ Up → "Super Like"  
- Overlays that fade in dynamically while swiping  
- MVVM-driven card data loaded from `profiles.json`  
- 👆 **Tap a card** to view detailed profile info  
- 📱 Smooth **animations & gestures**  
- 📂 **Mock data** used for simplicity (easily replaceable with API/JSON)  
- 🌓 Supports **Dark Mode** (out of the box with SwiftUI)

---

## 🛠 Tech Stack
- **Language:** Swift 5.9+  
- **Frameworks:** SwiftUI  
- **Architecture:** MVVM (scalable & clean)  
- **Deployment Target:** iOS 17+

---

## 📸 Screenshots

| Swipe Screen | Profile Detail |
|--------------|----------------|
| ![Swipe Screen](screenshots/swipe.png) | ![Detail Screen](screenshots/detail.png) |

(Add your screenshots into a `screenshots/` folder inside repo and update the paths above)

---

## 📹 Demo
(Insert screen recording GIF here, e.g. `demo.gif` in repo)

---

## 🚀 Getting Started

### 1. Clone Repo
```bash
git clone https://github.com/your-username/ProfileSwipePOC.git
