# Workout Calendar

A SwiftUI calendar app for displaying workouts, built with MVVM + Coordinator architecture.

## 📋 Requirements

- **Xcode**: 15.0 or later
- **iOS**: 17.0+
- **Swift**: 5.9+
- **macOS**: 13.0+ (Ventura)

## 🚀 Run the App

1. **Open the project**:
   ```bash
   open WorkoutCalendar.xcodeproj
   ```

2. **Add data files** (if not added yet):
   - In Xcode, drag JSON files from the `Data/` folder into Project Navigator
   - Make sure the target is **WorkoutCalendar**
   - Check **Build Phases -> Copy Bundle Resources** (there should be 3 JSON files)

3. **Choose a simulator**:
   - Any iPhone with iOS 17.0+
   - Recommended: iPhone 15 Pro

4. **Run the project**:
   ```
   ⌘ + R  (Run)
   ⌘ + U  (Run Tests)
   ```

5. **View workouts**:
   - Switch to November 2025 (◀ button)
   - Select November 21-25 (marked with blue dots)
   - Tap a workout to open details

## 🏗 Architecture

The project follows the **MVVM + Coordinator** pattern with clear separation of concerns. **Models** contain data structures and formatting business logic, **Views** focus only on UI rendering, **ViewModels** manage state and presentation logic, and the **Coordinator** centralizes screen navigation. **Services** isolate data access behind protocols for flexibility and testability.

All asynchronous operations use modern `async/await`, state is managed via Combine (`@Published`, `ObservableObject`), and navigation is type-safe through `enum NavigationDestination` for compile-time safety. The project follows a protocol-oriented approach to support mock-based testing and easy implementation swapping.

### Project Structure

```
WorkoutCalendar/
├── Coordinators/       # Navigation management
├── Models/             # Data models and extensions
├── Services/           # Data layer (JSON)
├── ViewModels/         # Presentation logic
└── Views/              # SwiftUI components
```

## 🧪 Test Coverage

### CalendarViewModel (14 tests)
- ✅ Month navigation (forward/backward, multiple transitions)
- ✅ Date selection and checks (current day, selected day)
- ✅ Event filtering by day
- ✅ Calendar grid generation (day count, first day offset)
- ✅ Date formatting (month/year in Russian locale)
- ✅ Event presence checks for calendar days
- ✅ Data loading (success/error paths)

### EventDetailsViewModel (11 tests)
- ✅ Initialization and metadata loading
- ✅ Distance formatting (km/m, zero/invalid values)
- ✅ Duration formatting (hours/minutes, edge cases)
- ✅ Temperature and humidity formatting
- ✅ Error handling and missing data behavior
- ✅ Computed properties for UI (title, dateTime, description)

### Workout Models (13 tests)
- ✅ Date parsing (valid/invalid formats)
- ✅ JSON decoding (WorkoutListResponse, MetadataResponse)
- ✅ Model-level data formatting
- ✅ Edge cases (zero values, invalid data)

**Total**: 30+ unit tests covering core logic.

## 📱 Core Features

- 📅 Monthly calendar with navigation
- 🔵 Visual indicators (current day, days with events)
- 📋 Event list for selected day
- 📊 Detailed workout information
- 📈 Heart-rate chart based on workout data
- 🌓 Light and dark mode support
- 📱 Adaptive layout (iPhone SE to 15 Pro Max)

## 🎨 Highlights

- **Localization**: Dates and workout names are shown in Russian
- **Type Safety**: Type-safe navigation through Coordinator
- **Reactivity**: Combine-based automatic UI updates
- **Concurrency**: Modern async/await instead of callbacks
- **Testability**: Protocol-oriented design with mocks
- **UI/UX**: Activity color coding, animations, loading states

## 📚 Additional Documentation

Detailed documentation is available in the project root:
- `../QUICK_START.md` - quick start guide
- `../PROJECT_SUMMARY.md` - project overview
- `../IMPLEMENTATION_SUMMARY.md` - implementation details
- `../XCODE_SETUP.md` - project setup

---

**Author**: Ivan Tishchenko  
**Date**: December 2025  
**Version**: 1.0
