# Integrity Tools

A comprehensive toolkit for pipeline inspection professionals.

## Features

- **Calculators**: Various calculators for pipeline inspection
- **Reports**: Generate and manage inspection reports
- **To-Do List**: Track tasks and assignments
- **Knowledge Base**: Access technical documentation and guidelines
- **Profile Management**: Manage user profile and preferences
- **Certifications**: Track and manage certifications
- **Inventory**: Manage equipment and supplies
- **Company Directory**: Access company contact information

## Project Structure

```
lib/
│   ├── calculators/
│   │   ├── abs_es_calculator.dart
│   │   ├── pit_depth_calculator.dart
│   │   ├── time_clock_calculator.dart
│   │   └── soc_eoc_calculator.dart
│   ├── models/
│   │   ├── report.dart
│   │   ├── todo_item.dart
│   │   └── user_profile.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── tools_screen.dart
│   │   ├── reports_screen.dart
│   │   ├── todo_screen.dart
│   │   ├── knowledge_base_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── certifications_screen.dart
│   │   ├── inventory_screen.dart
│   │   └── company_directory_screen.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── report_service.dart
│   │   └── profile_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── widgets/
│   │   ├── app_drawer.dart
│   │   ├── bottom_nav_bar.dart
│   │   └── daily_stats_card.dart
│   └── main.dart
```

## Getting Started

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


