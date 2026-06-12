<div align="center">
  <img src="https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/catalog-widget-placeholder.png" alt="Logo" width="100" height="100" />

  # 📚 Journal Trend Analyzer

  <p align="center">
    A smart Flutter mobile application designed to explore, analyze, and visualize academic publication trends using the OpenAlex API.
    <br />
    <br />
    <a href="#-features"><strong>Explore the features »</strong></a>
    <br />
  </p>
</div>

<!-- ABOUT THE PROJECT -->
## 🌟 About The Project

**Journal Trend Analyzer** acts as a pocket research assistant for students, researchers, and academics. By simply entering a topic, the app aggregates data from millions of publications to give you insights into peak research years, most influential authors, and top journals in that specific field.

This project was built as **Lab 2** for the Mobile Programming course (**PRM393**).

### 🛠 Built With

* [![Flutter][Flutter.dev]][Flutter-url]
* [![Dart][Dart.dev]][Dart-url]
* [![OpenAlex][OpenAlex-badge]][OpenAlex-url]

<!-- FEATURES -->
## ✨ Features

* **🔍 Smart Search**: Infinite scrolling through publications matching any topic.
* **📈 Trend Visualization**: Interactive bar charts to track publication volume over the years.
* **📊 Analytics Dashboard**: 2x3 statistics grid including Average Citations, Top Author, Top Journal, and more.
* **📄 Abstract Reconstructor**: Automatically decodes OpenAlex inverted indices into readable abstracts.
* **🔗 Direct DOI Links**: Open publication DOIs directly in your device's browser.
* **⚡ State Management**: Robust state handling using `Provider` with concurrent API requests for maximum speed.

<!-- GETTING STARTED -->
## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

* Flutter SDK (Version 3.19+ recommended)
* Android Studio / VS Code
* An Android Emulator or physical device

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/ngdcuog/PRM393_Lab2_SE181836.git
   ```
2. Navigate to the project directory
   ```sh
   cd journal_trend_analyzer
   ```
3. Install Flutter packages
   ```sh
   flutter pub get
   ```
4. Run the app
   ```sh
   flutter run
   ```

<!-- FOLDER STRUCTURE -->
## 📁 Architecture

The app follows a clear feature-layered architecture to separate UI from business logic and data:

```text
lib/
├── core/            # Utils (abstract parser), Constants, Exceptions
├── models/          # Data classes (Publication, AuthorStat, JournalStat, TrendPoint)
├── providers/       # State management (ChangeNotifier)
├── services/        # HTTP API wrappers (OpenAlex integration)
├── screens/         # UI Screens (Search, Detail, Trend, Dashboard)
└── widgets/         # Reusable UI components
```

<!-- ACKNOWLEDGMENTS -->
## 🎓 Acknowledgments
* Course: PRM393 - Mobile Programming
* Instructor: FPT University
* Open Data: [OpenAlex API](https://openalex.org/)

<div align="center">
  <i>Developed by CuongND (SE181836)</i>
</div>

<!-- MARKDOWN LINKS & IMAGES -->
[Flutter.dev]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[Flutter-url]: https://flutter.dev/
[Dart.dev]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[Dart-url]: https://dart.dev/
[OpenAlex-badge]: https://img.shields.io/badge/OpenAlex-API-FF6B6B?style=for-the-badge
[OpenAlex-url]: https://openalex.org/
