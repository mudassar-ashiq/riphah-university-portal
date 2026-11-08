# Riphah University Portal

A Flutter student portal app for Riphah International University, Sahiwal
Campus, in a glassmorphism (frosted glass) style. It opens with a login /
sign up screen, then shows the student dashboard with courses, timetable,
results, fees, notices, library, faculty and events.

Courses, teachers and the weekly timetable are the real FA24-BSSE-A data (official timetable, Oct 2026). Results, fees and similar figures are sample data for demonstration.

## Run it

```
flutter pub get
flutter run -d chrome
```

Demo login: any valid email and any password of 6 or more characters.

## Project structure

```
university_portal/
|-- assets/
|   `-- images/
|       `-- riphah_building.jpg   Real photo of the Sahiwal Campus building
|-- lib/
|   |-- main.dart                 App entry, dark theme, starts at login
|   |-- data/
|   |   `-- portal_data.dart      Student, courses, results, fees, notices...
|   |-- screens/
|   |   |-- auth_screen.dart      Glass login / sign up screen
|   |   |-- main_shell.dart       5-tab shell with glass bottom nav bar
|   |   |-- dashboard_screen.dart Home: photo header, CGPA, quick access
|   |   |-- courses_screen.dart   Enrolled courses and attendance
|   |   |-- timetable_screen.dart Weekly Mon-Fri timetable
|   |   |-- results_screen.dart   GPA / CGPA, result card, history
|   |   |-- more_screen.dart      Links to detail pages + log out
|   |   `-- detail_screens.dart   Fees, Notices, Library, Faculty,
|   |                             Events and Profile pages
|   `-- widgets/
|       |-- glass_card.dart       Frosted glass card (backdrop blur)
|       |-- glow_background.dart  Animated cyan / violet glow backdrop
|       `-- section_widgets.dart  Shared titles and the demo-data note
|-- test/
|   `-- widget_test.dart          GPA maths + login / tab flow tests
|-- pubspec.yaml
`-- web/  android/  ios/          Platform folders (generated)
```

## Notes

- GPA and CGPA are calculated in code from marks and credit hours.
- The building photo is bundled as an asset, so it works offline.
