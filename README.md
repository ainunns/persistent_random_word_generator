# Random Word Generator App

| Name                     | NRP        | Class                              |
| ------------------------ | ---------- | ---------------------------------- |
| Ainun Nadhifah Syamsiyah | 5025221053 | Pemrograman Perangkat Bergerak (C) |

## Overview

This is a Flutter application that generates random word pairs, allows users to favorite them and provides a simple, interactive user interface with multiple widgets and state management.

You can view the application demo [here](https://youtu.be/O4P4JNaF_Nc)

## Features

- Generate random word pairs
- Favorite and unfavorite word pairs
- View favorite word pairs in a grid
- Responsive design (supports mobile and desktop layouts)
- Animated transitions and interactions

## Widgets Used

The app demonstrates the use of at least 5 different widgets:

1. `BottomNavigationBar` / `NavigationRail` (adaptive navigation)
2. `Card` (for displaying word pairs)
3. `AnimatedList` (for displaying word history)
4. `GridView` (for displaying favorites)
5. `ElevatedButton` and `IconButton` (for interactions)
6. Custom widgets: `BigCard`, `GeneratorPage`, `FavoritesPage`

## State Management

The app uses `Provider` for state management with `ChangeNotifierProvider`, implementing a centralized `MyAppState` class that manages:

- Current word pair
- Favorite word pairs
- Word pair history

## CRUD Operations

The app demonstrates CRUD (Create, Read, Update, Delete) functionality:

- **Create**: Generate new random word pairs
- **Read**: Display word pairs and favorites
- **Update**: Toggle favorite status of word pairs
- **Delete**: Remove word pairs from favorites

## Project Structure

```
lib/
├── providers/
│   └── app_state.dart      # State management logic
├── screens/
│   ├── favorites_page.dart # Favorites management page
│   ├── generator_page.dart # Word pair generation page
│   └── home_page.dart      # Main page with navigation
├── widgets/
│   ├── big_card.dart       # Custom widget for displaying word pairs
│   └── history_list_view.dart # Animated list of previous word pairs
└── main.dart               # Entry point of the application
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository

```bash
git clone https://github.com/ainunns/random_word_generator.git
cd random_word_generator
```

2. Install dependencies

```bash
flutter pub get
```

3. Run the app

```bash
flutter run
```

## Dependencies

- `english_words`: For generating random word pairs
- `provider`: For state management
- `flutter/material.dart`: Core Flutter material design widgets

## Customization

- Modify color scheme in `MyApp` widget
- Adjust layout in `MyHomePage`
- Customize word generation logic in `MyAppState`

## Responsive Design

The app adapts to different screen sizes:

- Mobile: Bottom navigation bar
- Tablet/Desktop: Navigation rail
- Adjusts layout and widget sizes dynamically

## Reference

- Learn Flutter: https://flutter.dev/learn
- Building your first Flutter app: https://codelabs.developers.google.com/codelabs/flutter-codelab-first
