# Iterly: Lightweight project tracking for product work

## About

Iterly is a native SwiftUI project tracker for iPhone. It is built for solo builders and small product teams that want a simpler way to follow projects, tasks, releases, and day-to-day momentum without the weight of a larger PM tool.

The app centers on two main areas:

- a Home tab for pinned projects and upcoming work
- a Projects tab for editing projects, releases, tasks, subtasks, and brainstorm notes

## Features

### Home

- Dashboard for pinned projects, active projects, and upcoming tasks.
- Upcoming-task ordering based on due date and priority.
- Empty-state handling when the data store is empty.
- Toolbar action to erase the current store.

### Activity

- Activity heatmap backed by persisted project and task timestamps.
- Range filtering across recent weeks, quarters, and the last year.
- Day drill-down for project and task events.

### Projects

- Separate active and closed project sections.
- Create, edit, pin, close, and delete projects.
- Track project priority, status, notes, details, and current release metadata.
- Four-project pinning limit to keep the dashboard focused.
- Project detail view with progress and task breakdown helpers.

### Tasks

- Create and edit top-level tasks and nested subtasks.
- Track task status, priority, due date, notes, and supporting details.
- Dedicated task detail views and task action surfaces.
- Brainstorm form for drafting notes and ideas alongside project work.

### Sample Data And Previews

- In-memory preview containers for SwiftUI previews.
- Seeded sample projects, releases, tasks, and subtasks.

## Tech Stack

- SwiftUI
- SwiftData
- `@Observable` view models
- Modern `NavigationStack` and `Tab` navigation
- Preview containers backed by in-memory SwiftData stores

## Project Structure

```text
Iterly/
├── Iterly/
│   ├── Assets/
│   ├── Helpers/
│   ├── Localization/
│   ├── Tabs/
│   │   ├── Home/
│   │   │   ├── Helpers/
│   │   │   └── Sections/
│   │   └── Projects/
│   │       ├── Helpers/
│   │       └── Models/
│   ├── ContentView.swift
│   └── IterlyApp.swift
└── Iterly.xcodeproj
```

The app boots a shared SwiftData container in [`Iterly/IterlyApp.swift`](Iterly/IterlyApp.swift) and exposes two tabs from [`Iterly/ContentView.swift`](Iterly/ContentView.swift): `Home` and `Projects`.

## Data Model

- `Project` stores project metadata, pin state, timestamps, current release, and related tasks.
- `ProjectTask` stores task status, priority, due date, notes, and parent-child task relationships.
- `ProjectRelease` stores release metadata for the current version of a project.

## Requirements

- Xcode with iOS 18 SDK support
- iOS 18+

The checked-in project currently uses iOS 18 deployment settings for the app target.

## Getting Started

1. Clone the repository:

```bash
git clone <your-fork-or-repo-url>
cd Iterly
```

2. Open the project in Xcode:

```bash
open Iterly.xcodeproj
```

3. Select the `Iterly` scheme and an iPhone simulator or device.

4. Build and run the app.

## Development Notes

- Shared UI helpers and progress/task utilities live in `Iterly/Helpers`.
- Home-specific view logic lives in `Iterly/Tabs/Home`.
- Project, release, and task models live in `Iterly/Tabs/Projects/Models`.
- Forms and detail screens for project editing live in `Iterly/Tabs/Projects/Helpers`.
- Preview and demo data are defined in `Iterly/Helpers/SampleData.swift`.

## Testing

There is currently no dedicated test target checked into this repository.

## Author

Filippo Cilia
