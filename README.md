# Iterly: Keep product work visible

## About

**Iterly** is a native project tracker for iPhone built with SwiftUI and SwiftData. It is designed for small product teams and solo builders who want a lightweight way to follow projects, releases, and tasks without the overhead of a larger project management tool.

The app keeps the current state of work visible through pinned projects, upcoming tasks, release metadata, and status-based project grouping. It also includes built-in sample data so the interface can be explored immediately in previews and in the running app.

---

## Features

### Home
- Pinned projects surfaced at the top of the app for fast access.
- Upcoming tasks sorted by due date and priority.
- Project summaries that help you scan current work at a glance.
- Empty-state handling when no projects or tasks exist yet.
- Toolbar actions to insert sample data or erase the current store.

### Projects
- Separate active and closed project sections.
- Create, edit, pin, close, and delete projects.
- Support for priority, status, notes, details, and release metadata.
- A four-project pinning limit to keep the dashboard focused.
- Project detail screens with progress, task breakdowns, and supporting actions.

### Tasks
- Create and edit top-level tasks and nested subtasks.
- Track task status, priority, due date, notes, and details.
- Task lists grouped into clearer sections for navigation.
- Brainstorm flows for quickly drafting notes and ideas while working.
- Overdue and progress helpers used across the interface.

### Sample Data And Previews
- In-memory preview containers for SwiftUI previews.
- Seeded demo projects, tasks, subtasks, and releases.
- Reusable sample-data helpers for development and UI iteration.

---

## Tech Stack

### Core Technologies
- **Swift 6.2+**
- **SwiftUI**
- **SwiftData**
- **iOS 26.0+**

### Architecture And Patterns
- **Feature-first structure** with Home and Projects tabs.
- **`@Observable` view models** for UI-focused logic.
- **SwiftData `@Model` types** for persistence.
- **`NavigationStack` and `Tab` APIs** for modern navigation.
- **Preview-first development** with seeded in-memory model containers.

---

## Project Structure

```text
Iterly/
├── Iterly/
│   ├── Assets/                     # App assets and icon sources
│   ├── Helpers/                    # Shared UI components and utilities
│   │   ├── Localization/
│   │   └── SampleData.swift
│   ├── Localization/               # String resources
│   ├── Tabs/
│   │   ├── Home/                   # Dashboard, pinned projects, upcoming tasks
│   │   │   ├── Sections/
│   │   │   └── HomeViewModel.swift
│   │   └── Projects/               # Projects list, forms, details, task flows
│   │       ├── Helpers/
│   │       ├── Models/
│   │       └── ProjectsViewModel.swift
│   ├── ContentView.swift           # Tab navigation
│   └── IterlyApp.swift             # App entry point and SwiftData container
│
├── Iterly.xcodeproj
└── README.md
```

### Data Model

- `Project` stores title, notes, status, priority, timestamps, pinning state, tasks, and an optional current release.
- `ProjectTask` stores task metadata including due date, priority, status, and parent/child relationships for subtasks.
- `ProjectRelease` stores version, build, and app URL information for the current release of a project.

---

## Requirements

- **Xcode** with the iOS 26 SDK
- **iOS** 26.0 or later
- **Swift** 6.2 or later

---

## Getting Started

### Run The App

1. Open `Iterly.xcodeproj` in Xcode.
2. Select the `Iterly` scheme.
3. Choose an iOS 26 simulator or device.
4. Build and run the app.

### Explore With Sample Data

1. Launch the app.
2. Use the Home toolbar to insert sample content.
3. Use the erase action when you want to reset the current store.

SwiftUI previews are also seeded through `Iterly/Helpers/SampleData.swift`.

---

## Development Notes

- The app creates a shared SwiftData container in `IterlyApp.swift`.
- Home-specific logic lives in `HomeViewModel`.
- Project-list logic lives in `ProjectsViewModel`.
- Shared task rendering and status helpers live under `Iterly/Helpers`.

---

## Author

**Filippo Cilia**
