# SwiftUI Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the bugs, deprecated API, accessibility gaps and adaptive-layout (iPad / iPhone Duo Tier 1) problems found in the 2026-10-19 SwiftUI Pro + iPhone Duo audit.

**Architecture:** Work happens on `feature/audit-fixes`, branched from `feature/ipados-macos-support` (unmerged), in the worktree `/Users/filippocilia/Desktop/Projects/iOS/Iterly-audit`. Reuse that branch's helpers in `Iterly/Helpers/View+Platform.swift` (`readableContentWidth()`, `platformFullScreenCover`, `platformTopBarTrailing`, etc.). Testable logic moves into small types with Swift Testing tests; view changes are verified by building for iOS and macOS.

**Tech Stack:** Swift, SwiftUI, SwiftData, WidgetKit, Swift Testing. Xcode 27.1 (`/Applications/Xcode beta 27.1.app`).

**Spec:** The audit report given in the conversation on 2026-10-19 (findings quoted per task below).

## Global Constraints

- Deployment target stays **iOS 18** for app and widget. Do not change it. iOS 26/27-only API needs `if #available(iOS 27, *)` (or 26) with the old behaviour as fallback.
- Default actor isolation is `MainActor`; `SWIFT_VERSION` stays `5.0` (do not change it in this plan).
- The app must keep building for **macOS** (this branch adds it). iOS-only modifiers go through `View+Platform.swift` wrappers or `#if os(iOS)`.
- Follow `~/.claude/CLAUDE.md`: `foregroundStyle`, `clipShape(.rect(cornerRadius:))`, `Button("Title", systemImage:, action:)`, two-param or zero-param `onChange`, no GCD, no `AnyView`, one type per file, `.localizedStandardContains` for user text filtering, no hard-coded font sizes.
- No new third-party dependencies. Do not touch `PrivateAds` usage beyond what a task states.
- Unit tests use Swift Testing (`import Testing`, `@Test`, `#expect`) in `IterlyTests/`, `@MainActor struct …Tests`, in-memory `ModelContainer` like `IterlyTests/DashboardViewModelTests.swift`.
- New files under `Iterly/` and `IterlyTests/` are picked up automatically (synchronized folders); no pbxproj edits for Swift files.
- Commit after each task with a message ending `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never commit `Iterly.storekit`.

**Verification commands (used by every task):**

```bash
# iOS build + tests
cd /Users/filippocilia/Desktop/Projects/iOS/Iterly-audit && xcodebuild test -scheme Iterly -destination 'platform=iOS Simulator,name=iPhone 18 Pro' -derivedDataPath /tmp/iterly-audit-dd 2>&1 | grep -E "error:|✘|failed|\*\* TEST" | tail -20
# macOS build
cd /Users/filippocilia/Desktop/Projects/iOS/Iterly-audit && xcodebuild build -scheme Iterly -destination 'platform=macOS' -derivedDataPath /tmp/iterly-audit-dd 2>&1 | grep -E "error:|\*\* BUILD" | tail -10
```

Expected: `** TEST SUCCEEDED **` and `** BUILD SUCCEEDED **`, no `error:` lines.

## Review Focus

1. Deleting the project currently shown in the Projects split-view detail column → detail clears to the empty state; no crash from a deleted model. (Task 6 test + manual.)
2. A widget tap (`iterly://activity`) arriving while another tab is selected, and an unknown URL (`iterly://nope`, `https://…`) → first switches to Activity, second is ignored. (Task 1 tests.)
3. Pinning a 5th project vs. a SwiftData save failure → different messages ("Only 4 projects…" vs. the error text). (Task 4 tests.)
4. Saving a task fails → the form stays open with the user's input intact and shows the error. (Task 4.)
5. Resizing a window compact → regular → compact (iPad split view, Duo fold) → the selected project and tab survive. (Task 6 manual check; state lives above the layout.)

---

### Task 1: Tab routing, widget deep link, App Store URL

Audit findings: placeholder App Store ID breaks Rate/Share; `iterly://activity` has no handler; `@AppStorage("selectedView")` couples windows and is written from three places; unused settings properties.

**Files:**
- Create: `Iterly/Navigation/AppTab.swift`
- Create: `Iterly/Navigation/TabSelection.swift`
- Create: `IterlyTests/AppTabTests.swift`
- Modify: `Iterly/ContentView.swift`
- Modify: `Iterly/Tabs/Dashboard/DashboardAvailableView.swift`, `Iterly/Tabs/Dashboard/Sections/ProjectsSection.swift` (replace `@AppStorage("selectedView")` writes)
- Modify: `Iterly/Tabs/Dashboard/DashboardView.swift`, `Iterly/Tabs/Projects/ProjectsView.swift`, `Iterly/Tabs/Activity/ActivityView.swift`, `Iterly/Tabs/Settings/SettingsView.swift` (delete the `static let …Tag` constants)
- Modify: `Iterly/Tabs/Settings/SettingsViewModel.swift`
- Modify: `Iterly/Info.plist` (add `CFBundleURLTypes`)

**Interfaces:**
- Produces: `enum AppTab: String, Hashable, CaseIterable { case dashboard, projects, activity, settings }` with `init?(deepLink url: URL)`.
- Produces: `@Observable final class TabSelection { var selected: AppTab; init(selected: AppTab = .dashboard) }`, injected with `.environment(tabSelection)`; views read `@Environment(TabSelection.self)` and set `selected`.

- [ ] **Step 1: Write failing tests** in `IterlyTests/AppTabTests.swift`:
  - `@Test func activityDeepLinkMapsToActivityTab()` → `#expect(AppTab(deepLink: URL(string: "iterly://activity")!) == .activity)`
  - `@Test(arguments: ["iterly://dashboard", "iterly://projects", "iterly://settings"]) func everyTabHasADeepLink(_ raw: String)` → non-nil, `rawValue == URL(string: raw)!.host()`
  - `@Test(arguments: ["iterly://nope", "https://activity", "iterly:"]) func unknownLinksAreIgnored(_ raw: String)` → `nil`
  - `@Test func shareURLUsesRealAppID()` → `#expect(SettingsViewModel().appShareURL?.absoluteString == "https://apps.apple.com/app/id6760037639")` and `appStoreReviewURL?.absoluteString == "https://apps.apple.com/app/id6760037639?action=write-review"`
- [ ] **Step 2: Run iOS tests** — expect compile failure (`AppTab` undefined).
- [ ] **Step 3: Implement `AppTab`** (scheme must equal `"iterly"`, case-insensitive; host must equal a raw value) and **`TabSelection`** (`@MainActor @Observable`, one file each).
- [ ] **Step 4: Fix `SettingsViewModel`**: `appShareURLString = "https://apps.apple.com/app/id6760037639"`; delete `showCompletedTasks`, `highlightOverdueTasks`, `compactProjectCards`, their keys, and the `userDefaults` stored property plus the `init(userDefaults:)` parameter if nothing else uses them.
- [ ] **Step 5: Wire `ContentView`**:
  - `@SceneStorage("selectedTab") private var storedTab: AppTab = .dashboard` and `@State private var tabSelection = TabSelection()`.
  - `TabView(selection: $tabSelection.selected)` (via `@Bindable`), `Tab(…, value: AppTab.dashboard)` etc.
  - `.environment(tabSelection)`; `.onAppear { tabSelection.selected = storedTab }`; `.onChange(of: tabSelection.selected) { _, new in storedTab = new }`.
  - `.onOpenURL { url in if let tab = AppTab(deepLink: url) { tabSelection.selected = tab } }`.
  - `DashboardAvailableView` and `ProjectsSection` use `@Environment(TabSelection.self)` and set `.activity` / `.projects`. Add `.environment(TabSelection())` to every `#Preview` that renders these views.
- [ ] **Step 6: Register the URL scheme** in `Iterly/Info.plist`: `CFBundleURLTypes` → one dict with `CFBundleURLName` = `cilia.filippo.Iterly`, `CFBundleURLSchemes` = `["iterly"]`.
- [ ] **Step 7: Run iOS tests + macOS build** — expect all green.
- [ ] **Step 8: Commit** `fix: route widget deep link, scene-scoped tab selection, real App Store ID`.

---

### Task 2: Replace deprecated alert APIs in Settings

Audit findings: legacy `Alert` struct in `SettingsView` and `IntegrationsSettingsView`; `Binding(get:set:)` for error alerts; stray `.tint(.red)`.

**Files:**
- Modify: `Iterly/Tabs/Settings/SettingsView.swift`
- Modify: `Iterly/Tabs/Settings/IntegrationsSettingsView.swift`

**Interfaces:** none new. `SettingsViewModel.activeAlert: AlertKind?` and `IntegrationsSettingsViewModel.pendingAction: PendingAction?` / `activeErrorMessage: String?` keep their names.

- [ ] **Step 1: `SettingsView`** — replace `.alert(item:) { Alert(…) }` with a single `alert(_:item:)` whose title comes from the item: `.alert(viewModel.activeAlert?.title ?? "", item: $viewModel.activeAlert) { kind in … } message: { kind in Text(kind.message) }`. Actions by `kind`: `.sampleDataAdded` → none (system OK button); `.eraseAllDataConfirmation` → `Button("Erase", role: .destructive) { viewModel.eraseAllData(modelContext: modelContext) }` + `Button("Cancel", role: .cancel) {}`.
  - Remove `.tint(.red)` from the Contact button.
- [ ] **Step 2: `IntegrationsSettingsView`** — same pattern for `pendingAction` (`Button("Remove", role: .destructive)` + cancel); replace the `isShowingErrorAlert` computed `Binding` with `.alert("Integration Error", item: $viewModel.activeErrorMessage) { _ in } message: { Text($0) }`.
- [ ] **Step 3: Build iOS + macOS** — expect green. If `alert(_:item:)` with a non-`Identifiable` `String` fails to resolve, stop and report (it requires Xcode 27; do not add an `Identifiable` wrapper silently).
- [ ] **Step 4: Commit** `refactor: modern alert(_:item:) in settings screens`.

---

### Task 3: One navigation style per stack

Audit findings: `TaskRowView` and `TaskListSectionView` use `NavigationLink { destination }` inside stacks that register `navigationDestination(for: Project.self)`; `TaskActionsView` pushes `NavigationLink(value: project)` from a destination-pushed view; `TaskDetailView` sheet renders empty for subtasks; `TaskDetailView.swift` holds two types.

**Files:**
- Create: `Iterly/Navigation/TaskListRoute.swift`
- Create: `Iterly/Navigation/View+AppNavigationDestinations.swift`
- Create: `Iterly/Navigation/TaskListRouteView.swift`
- Create: `Iterly/Tabs/Projects/Helpers/TaskDetailContentView.swift` (moved out of `TaskDetailView.swift`)
- Modify: `Iterly/Tabs/Projects/Helpers/TaskRowView.swift`, `Iterly/Helpers/TaskListSectionView.swift`, `Iterly/Tabs/Projects/Helpers/TaskDetailView.swift`
- Modify: `Iterly/Tabs/Dashboard/DashboardAvailableView.swift`, `Iterly/Tabs/Projects/ProjectsView.swift` (replace their `navigationDestination(for: Project.self)` with the shared modifier)
- Test: `IterlyTests/TaskListRouteTests.swift`

**Interfaces:**
- Produces: `struct TaskListRoute: Hashable { let title: String; let taskIDs: [UUID]; let isToned: Bool }` plus `init(title: String, tasks: [ProjectTask], isToned: Bool)`. `TaskListRouteView(route:)` resolves the IDs against a `@Query` of tasks, so the route stays a plain value.
- Produces: `extension View { func appNavigationDestinations(onProjectDelete: @escaping () -> Void = {}) -> some View }` registering destinations for `Project.self` (→ `ProjectDetailView(project:onDelete:)`), `ProjectTask.self` (→ `TaskDetailView(task:)`) and `TaskListRoute.self` (→ `TaskListRouteView(route:)`). Apply it exactly once per `NavigationStack` root.

- [ ] **Step 1: Write failing tests** `TaskListRouteTests`:
  - `routeCapturesTaskIDsInOrder` — given three tasks, `route.taskIDs == tasks.map(\.id)`.
  - `routesWithSameTasksAreEqual` / `routesWithDifferentTonesDiffer` — `==` / `!=` on `isToned`.
- [ ] **Step 2: Run** — fails to compile.
- [ ] **Step 3: Implement** `TaskListRoute`, `TaskListRouteView` (filters `@Query` tasks to `route.taskIDs` order-preserving, renders existing `TaskListView(title:tasks:isToned:)`), and `appNavigationDestinations`.
- [ ] **Step 4: Convert links**: `TaskRowView` → `NavigationLink(value: task)`; `TaskListSectionView` → `NavigationLink(value: TaskListRoute(title:tasks:isToned:))`. Replace the Project destinations in `DashboardAvailableView` and `ProjectsView` with `.appNavigationDestinations(…)` (Projects passes its existing path-reset closure). `SettingsView` keeps its own `NavigationLink { }` (no value destinations in that stack) — leave it.
- [ ] **Step 5: `TaskDetailView`**: move `TaskDetailContentView` to its own file (drop `private`). Remove the `if task.parentTask == nil` wrapper inside the add-subtask sheet; the add-subtask button already only exists when `task.parentTask == nil` via `TaskSubtaskSectionsView`.
- [ ] **Step 6: Run iOS tests + macOS build** — green.
- [ ] **Step 7: Commit** `fix: value-based navigation for tasks and task lists`.

---

### Task 4: Surface save errors and save inline edits

Audit findings: `assertionFailure`-only error handling in `ProjectViewModel`, `TaskFormView`, `TaskAttachmentsSectionView`; `togglePin` reports any error as "pin limit"; inline status/priority/due-date edits never call `saveAndReloadActivityWidget()` so the widget goes stale; `TaskFormView` initializes `@State` twice; duplicated status-change logic in four views.

**Files:**
- Create: `Iterly/Tabs/Projects/Models/ProjectTask+Editing.swift`
- Create: `Iterly/Tabs/Projects/Models/Project+Editing.swift`
- Create: `Iterly/Tabs/Projects/Models/PinToggleResult.swift`
- Create: `IterlyTests/ProjectViewModelTests.swift`, `IterlyTests/TaskEditingTests.swift`
- Modify: `Iterly/Tabs/Dashboard/ProjectViewModel.swift`, `Iterly/Tabs/Projects/ProjectsView.swift`, `Iterly/Tabs/Projects/Helpers/ProjectDetailView.swift`, `Iterly/Tabs/Projects/Helpers/ProjectFormViewModel.swift`, `Iterly/Tabs/Settings/SettingsViewModel.swift`, `Iterly/Tabs/Projects/Helpers/TaskFormView.swift`, `Iterly/Tabs/Projects/Helpers/TaskAttachmentsSectionView.swift`, `Iterly/Tabs/Projects/Helpers/TaskRowView.swift`, `Iterly/Tabs/Projects/Helpers/TaskInfoBoxView.swift`, `Iterly/Tabs/Projects/Helpers/ProjectInfoBoxView.swift`

**Interfaces:**
- Produces: `enum PinToggleResult: Equatable { case toggled, limitReached }`.
- Produces on `ProjectViewModel`: `func togglePin(project: Project, modelContext: ModelContext) throws -> PinToggleResult`, `func deleteProject(_:modelContext:) throws`, `func eraseAllData(modelContext:) throws`, `saveAppStoreSyncError` unchanged.
- Produces: `extension ProjectTask { @discardableResult func updateStatus(_ status: TaskStatus) -> Bool; func updatePriority(_ priority: TaskPriority); func updateDueDate(_ date: Date) }` — each assigns, calls `touch()` on the task and `project?.touch()`; `updateStatus` returns whether the value changed and does nothing when equal.
- Produces: `extension Project { @discardableResult func updateStatus(_ status: ProjectStatus) -> Bool; func updatePriority(_ priority: ProjectPriority) }` — same contract with `touch()`.
- Produces: `extension ModelContext { func saveLoggingFailure(_ action: String) }` in `Iterly/Helpers/ModelContext+WidgetReload.swift` — calls `saveAndReloadActivityWidget()` and logs failures with `os.Logger(subsystem: "cilia.filippo.Iterly", category: "Persistence")` `.error`. Used only for inline edits where autosave will retry; user-initiated save/delete paths must show an alert instead.

- [ ] **Step 1: Write failing tests**:
  - `ProjectViewModelTests.pinningFifthProjectReportsLimit` — 4 pinned + 1 unpinned in an in-memory container (schema `Project, ProjectTask, TaskAttachment, ProjectRelease, ProjectLink`); `try viewModel.togglePin(project: fifth, …) == .limitReached` and `fifth.isPinned == false`.
  - `ProjectViewModelTests.unpinningAlwaysSucceeds` — `== .toggled`, `isPinned == false`.
  - `TaskEditingTests.updateStatusReportsChangeAndTouches` — returns `true`, `task.lastUpdated` advanced, `project.lastUpdated` advanced.
  - `TaskEditingTests.updateStatusToSameValueIsNoOp` — returns `false`, `lastUpdated` unchanged.
  - `TaskEditingTests.projectUpdateStatusReportsChange` — same for `Project`.
- [ ] **Step 2: Run** — fails to compile.
- [ ] **Step 3: Implement** the interfaces above. Callers:
  - `ProjectsView`, `ProjectDetailView`: `do { if try togglePin(…) == .limitReached { showPinLimitAlert = true } } catch { errorMessage = error.localizedDescription }`, shown via `.alert("Something Went Wrong", item: $errorMessage) { _ in } message: { Text($0) }`. Same for delete in `ProjectsView`.
  - `ProjectFormViewModel.deleteProject(modelContext:) -> Bool` sets `syncErrorMessage` on failure; `ProjectFormView` only dismisses / calls `onDelete` when it returns `true`.
  - `SettingsViewModel.eraseAllData` catches and sets a new `var errorMessage: String?` (keep `AlertKind` unchanged), shown with `.alert("Couldn't Erase Data", item: $viewModel.errorMessage) { _ in } message: { Text($0) }` in `SettingsView`.
  - `TaskRowView`, `TaskInfoBoxView`, `ProjectInfoBoxView`: setters call `updateStatus`/`updatePriority`/`updateDueDate`, bump `crossPromoSignal` only when `updateStatus` returns `true`, then `modelContext.saveLoggingFailure("…")`. Keep the `Binding(get:set:)` shape (its setter side effects are intentional).
- [ ] **Step 4: `TaskFormView`**: declare every `@State` without an initial value (`@State private var title: String` …) and keep the `init` assignments; add `@State private var errorMessage: String?`; `saveTask`/`updateTask`/`deleteTask` use `do/catch`, set `errorMessage` and **do not dismiss** on failure; alert as above. Use `updateStatus` for the status-change bump.
- [ ] **Step 5: `TaskAttachmentsSectionView`**: replace both `assertionFailure` sites with `@State private var errorMessage: String?` + alert; count items whose `loadTransferable` fails and include them in the existing skipped message (`"Skipped: \(n)"` stays for oversized videos; add a separate alert line `"\(failed) items couldn't be imported."` when `failed > 0`).
- [ ] **Step 6: Run iOS tests + macOS build** — green.
- [ ] **Step 7: Commit** `fix: surface save errors and persist inline edits`.

---

### Task 5: Stable identities, cheaper bodies, localization

Audit findings: `ExternalDestination` gets a fresh `UUID` every body pass; O(n) reload-token strings in `ActivityView` / `DashboardAvailableView`; `@Environment(\.self)` in `BadgeStyleModifier`; unused state in `DashboardView`; per-cell `DateFormatter`; hard-coded English Monday-first weekday labels; `dateFormat = "MMM"`; hand-built plurals; `Text("…" + "…")`; `NSLocalizedString`; `filter().count`.

**Files:**
- Create: `Iterly/Tabs/Projects/Models/ExternalDestination.swift` (moved from `ProjectDetailView.swift`)
- Create: `Iterly/Tabs/Activity/ActivityReloadKey.swift`
- Create: `Iterly/Tabs/Activity/Views/WeekdaySymbols.swift`
- Create: `IterlyTests/ExternalDestinationTests.swift`, `IterlyTests/ActivityReloadKeyTests.swift`, `IterlyTests/WeekdaySymbolsTests.swift`
- Modify: `ProjectDetailView.swift`, `ActivityView.swift`, `DashboardAvailableView.swift`, `DashboardView.swift`, `Iterly/Helpers/View+BadgeStyle.swift`, `ActivityHeatmapGridView.swift`, `ActivityOverviewViewModel.swift`, `ActivityDayDetailSectionView.swift`, `ActivitySummarySectionView.swift`, `WidgetTutorialView.swift`, `Iterly/Helpers/Localization/LocalizedText.swift`, `Iterly/Tabs/Projects/ProjectCell.swift`

**Interfaces:**
- Produces: `struct ExternalDestination: Identifiable, Hashable { let title: String; let systemImage: String; let rawURL: String; var id: String { "\(title)|\(rawURL)" }; var displayURL: String; var resolvedURL: URL? }` and `static func destinations(for release: ProjectRelease?) -> [ExternalDestination]` (App Store first, then useful links in order, skipping blank URLs — same rules as today's computed property).
- Produces: `enum ActivityReloadKey { static func make(range: ActivityRange, projects: [Project], tasks: [ProjectTask]) -> Int }` using `Hasher` over `range.rawValue`, each project's `id` + `lastUpdated`, each task's `id` + `creationDate` + `lastUpdated`.
- Produces: `enum WeekdaySymbols { static func ordered(for calendar: Calendar) -> [String] }` returning `calendar.shortStandaloneWeekdaySymbols` rotated so index 0 is `calendar.firstWeekday`.

- [ ] **Step 1: Write failing tests**:
  - `ExternalDestinationTests.idIsStableAcrossBuilds` — two calls to `destinations(for:)` on the same release give equal `id` arrays.
  - `ExternalDestinationTests.appStoreComesFirstAndBlankLinksAreSkipped`.
  - `ActivityReloadKeyTests.changesWhenTaskIsTouched` — key differs after `task.touch()`; `sameInputsGiveSameKey`.
  - `WeekdaySymbolsTests.mondayFirstCalendarStartsWithMonday` (`Calendar(identifier: .gregorian)`, `firstWeekday = 2`, `locale = Locale(identifier: "en_GB")` → first element `"Mon"`), `sundayFirstCalendarStartsWithSunday` (`firstWeekday = 1`, `en_US` → `"Sun"`), `alwaysSevenSymbols`.
- [ ] **Step 2: Run** — fails to compile.
- [ ] **Step 3: Implement** the three types; `ProjectDetailView` calls `ExternalDestination.destinations(for: project.currentRelease)` once at the top of `body`.
- [ ] **Step 4: Replace the reload tokens** in `ActivityView` and `DashboardAvailableView` with `ActivityReloadKey.make(…)` in `.onChange(of:initial:)`.
- [ ] **Step 5: Small fixes**:
  - `DashboardView`: delete unused `modelContext`, `viewModel`, `showEraseDataAlert`.
  - `BadgeStyleModifier`: drop `@Environment(\.self)`; resolve with `EnvironmentValues()` configured with the read `colorScheme` (`var env = EnvironmentValues(); env.colorScheme = colorScheme`).
  - `ActivityHeatmapGridView`: weekday labels from `WeekdaySymbols.ordered(for:)` with `@Environment(\.calendar)`; accessibility label uses `day.date.formatted(date: .abbreviated, time: .omitted)` and `"^[\(day.count) activity](inflect: true)"`-style text (build the label as `Text`/`LocalizedStringResource`, not `String` concatenation).
  - `ActivityOverviewViewModel.makeMonthLabels`: `formatter.setLocalizedDateFormatFromTemplate("MMM")`.
  - `ActivityDayDetailSectionView` lines with "total / project / task" and `ActivitySummarySectionView` "active day(s)": use `^[\(n) project](inflect: true)` automatic grammar agreement.
  - `WidgetTutorialView` header text: one string literal, no `+`.
  - `LocalizedText`: `String(localized: "No due date", comment: …)`; format functions use `String(localized:)` with the existing `.stringsdict` keys (`String.localizedStringWithFormat(String(localized: "tasks_count"), count)`). Keep the `.stringsdict` file.
  - `ProjectCell.availableTasksCount`: `tasks.count { … }`.
- [ ] **Step 6: Run iOS tests + macOS build** — green.
- [ ] **Step 7: Commit** `perf: stable identities, hashed reload keys, locale-aware labels`.

---

### Task 6: Projects split view, adaptive grids, fold-safe insets

Audit findings (Duo Tier 1): Projects is list→detail in a single stack; fixed 2-column grids; legend centered in an overlay (sits on Duo's fold) with a guessed `contentMargins(.bottom, 50)`; fixed bottom gaps (`contentMargins(.bottom, 70)` ×2, `padding(.bottom, 24)`, `safeAreaPadding(.bottom, 60)`, `padding(.top, -8)`); non-semantic toolbar placement for "Add Project".

**Files:**
- Modify: `Iterly/Tabs/Projects/ProjectsView.swift` (the `appNavigationDestinations` call from Task 3 moves onto the detail column's `NavigationStack`)
- Create: `Iterly/Tabs/Projects/ProjectsListView.swift` (the list extracted from `ProjectsView`)
- Create: `Iterly/Tabs/Projects/ProjectSelection.swift`
- Create: `IterlyTests/ProjectSelectionTests.swift`
- Modify: `Iterly/Tabs/Dashboard/Sections/ProjectsSection.swift`, `Iterly/Tabs/Dashboard/Sections/PinnedProjectsSection.swift`, `DashboardAvailableView.swift`, `ProjectDetailView.swift`, `ActivityView.swift`, `WidgetTutorialView.swift`

**Interfaces:**
- Consumes: `appNavigationDestinations(onProjectDelete:)` (Task 3), `ProjectViewModel.togglePin/deleteProject` throwing API (Task 4).
- Produces: `enum ProjectSelection { static func validated(_ selected: Project?, in projects: [Project]) -> Project? }` — returns `selected` only if a project with the same `id` is still in `projects` (otherwise `nil`).

- [ ] **Step 1: Write failing tests** `ProjectSelectionTests`: `keepsSelectionThatStillExists`, `clearsSelectionAfterDeletion` (project removed from array → `nil`), `nilStaysNil`.
- [ ] **Step 2: Run** — fails to compile.
- [ ] **Step 3: Implement `ProjectSelection`**, then restructure `ProjectsView`:
  - `@State private var selectedProject: Project?`; `NavigationSplitView { ProjectsListView(projects:selection:…) } detail: { NavigationStack(path: $path) { if let selectedProject { ProjectDetailView(project: selectedProject, onDelete: clearSelection) } else { ContentUnavailableView("Select a Project", systemImage: "folder") }.appNavigationDestinations(onProjectDelete: clearSelection) } }`.
  - `ProjectsListView` uses `List(selection: $selection)` with `NavigationLink(value: project)` rows (existing `ProjectRowLinkView`), keeps sections, swipe actions, alerts and the add sheet.
  - `.onChange(of: projects) { _, new in selectedProject = ProjectSelection.validated(selectedProject, in: new) }`.
  - On compact width the split view collapses to a stack automatically; do not branch on size class.
  - "Add Project" toolbar item placement: `.primaryAction`.
- [ ] **Step 4: Legend + banner**: remove `.overlay(alignment: .bottom)` and `.contentMargins(.bottom, 50, …)`; put `ProjectsLegendView` (when non-empty) and `CrossPromoBannerView` together in the list column's `.safeAreaInset(edge: .bottom) { VStack { … } }`; drop `.padding(.top, -8)`.
- [ ] **Step 5: Fixed gaps**: delete `contentMargins(.bottom, 70, …)` in `DashboardAvailableView` and `ProjectDetailView`, `.padding(.bottom, 24)` in `ActivityView`, `.safeAreaPadding(.bottom, 60)` in `WidgetTutorialView`.
- [ ] **Step 6: Adaptive grids**: `ProjectsSection` and `PinnedProjectsSection` columns → `[GridItem(.adaptive(minimum: 160))]` (make it a `private let`).
- [ ] **Step 7: Run iOS tests + macOS build** — green. Then launch on `iPad Air 13-inch (M4)` simulator and confirm list|detail side by side, deleting the shown project clears the detail.
- [ ] **Step 8: Commit** `feat: adaptive Projects split view and fold-safe bottom insets`.

---

### Task 7: Readable widths, heatmap cap, paywall fallback, tab sidebar

Audit findings (Duo Tier 1): detail screens stretch edge to edge; heatmap cell size has no maximum; paywall has no scroll fallback for Duo's short outer display; tabs don't become a sidebar on wide iPhone (Duo inner display).

**Files:**
- Create: `Iterly/Tabs/Activity/Views/HeatmapLayoutMetrics.swift` (moved out of `ActivityHeatmapGridView.swift`, made internal)
- Create: `IterlyTests/HeatmapLayoutMetricsTests.swift`
- Modify: `ActivityHeatmapGridView.swift`, `ProjectDetailView.swift`, `Iterly/Tabs/Projects/Helpers/TaskDetailContentView.swift`, `Iterly/Helpers/CrossPromo/CrossPromoRemoveAdsInfoView.swift`, `Iterly/ContentView.swift`, `Iterly/Helpers/View+Platform.swift`

**Interfaces:**
- Produces: `struct HeatmapLayoutMetrics { let availableWidth: CGFloat; let weekCount: Int; let spacing: CGFloat; let minimumCellSize: CGFloat; let maximumCellSize: CGFloat; var cellSize: CGFloat; var cornerRadius: CGFloat; func xOffset(forWeekIndex:) -> CGFloat }`. `cellSize` = `min(max(fitted, minimumCellSize), maximumCellSize)`. The grid passes `maximumCellSize: 28`.
- Produces: `extension View { func adaptiveTabBarPlacement() -> some View }` in `View+Platform.swift`: on iOS with `#available(iOS 27, *)` applies `.defaultTabBarPlacement(.sidebar)`; otherwise returns `self`.

- [ ] **Step 1: Write failing tests** `HeatmapLayoutMetricsTests`: `wideContainerIsCappedAtMaximum` (width 1000, 14 weeks, spacing 4, min 14, max 28 → `cellSize == 28`), `narrowContainerUsesMinimum` (width 100 → 14), `fittedSizeInBetween` (width 400, 14 weeks, spacing 4 → `floor((400 - 52) / 14) == 24`).
- [ ] **Step 2: Run** — fails (no `maximumCellSize`).
- [ ] **Step 3: Implement** the metrics move + cap. With a capped cell size the grid can be narrower than its container: keep it leading-aligned inside the scroll view (no change needed beyond the cap).
- [ ] **Step 4: Readable width**: apply `.readableContentWidth()` to the `VStack` inside `ProjectDetailView`'s and `TaskDetailContentView`'s `ScrollView` (same placement as `DashboardAvailableView`).
- [ ] **Step 5: Paywall**: wrap the non-purchased `VStack` in `ScrollView` (remove the `Spacer()`), keep the `.safeAreaInset(edge: .bottom)` legal footer on the `ScrollView`.
- [ ] **Step 6: Tabs**: `ContentView` applies `.adaptiveTabBarPlacement()` after `.tabViewStyle(.sidebarAdaptable)`.
- [ ] **Step 7: Run iOS tests + macOS build** — green.
- [ ] **Step 8: Commit** `feat: readable widths, capped heatmap cells, scrollable paywall`.

---

### Task 8: Accessibility and HIG controls

Audit findings: icon-only pin toolbar button and minus button lack labels; swipe-only pin/delete with a label that always says "Pin"; checkbox, info and remove buttons under 44pt; double-tap zoom unreachable for VoiceOver; viewer "Done" uses `.topBarLeading`; fixed 28pt/76pt frames don't scale; forced white labels on `.borderedProminent` toolbar buttons.

**Files:**
- Modify: `ProjectDetailView.swift`, `ProjectFormView.swift`, `Iterly/Tabs/Projects/ProjectRowLinkView.swift`, `TaskRowView.swift`, `ActivitySummarySectionView.swift`, `Iterly/Tabs/Settings/IntegrationRowView.swift`, `TaskAttachmentViewerView.swift`, `Iterly/Tabs/Settings/FormRowView.swift`, `TaskAttachmentThumbnailView.swift`, `TaskFormView.swift`, `BrainstormFormView.swift`

**Interfaces:** none new.

- [ ] **Step 1: Labels**:
  - Pin toolbar button: `Button(project.isPinned ? "Unpin" : "Pin", systemImage: "pin", action: togglePin)` with `.symbolVariant(project.isPinned ? .fill : .none)`; extract `togglePin()` to a method. Placement `.primaryAction` for pin and edit.
  - `ProjectFormView` remove-link button: `Button("Remove Link", systemImage: "minus.circle.fill", role: .destructive) { … }.labelStyle(.iconOnly)`.
  - `ProjectRowLinkView`: `Button(project.isPinned ? "Unpin" : "Pin", systemImage: "pin", action: onTogglePin)` and `Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)` in swipes; add a `.contextMenu` with the same two buttons.
- [ ] **Step 2: Tap targets** — add `.frame(minWidth: 44, minHeight: 44).contentShape(.rect)` to: the `TaskRowView` completion button, the `ActivitySummarySectionView` info button, the `IntegrationRowView` remove button.
- [ ] **Step 3: Viewer**: Done → `.cancellationAction`; image gets `.accessibilityAction(named: "Reset Zoom") { resetZoom() }` sharing a `resetZoom()` method with the double-tap.
- [ ] **Step 4: Scaling**: `FormRowView` icon side and `TaskAttachmentThumbnailView` side use `@ScaledMetric(relativeTo: .body) private var side = 28.0` / `76.0`; `FormRowView` `.contentShape(.rect)`.
- [ ] **Step 5: Toolbar buttons**: `ProjectFormView` and `TaskFormView` Save → `Button("Save") { … }.disabled(…)` (no `.borderedProminent`, no white foreground); `BrainstormFormView` Done → `Button("Done", action: dismiss.callAsFunction)` (or a `close()` method).
- [ ] **Step 6: Run iOS tests + macOS build** — green.
- [ ] **Step 7: Commit** `fix: accessible labels, 44pt targets, scalable icons`.

---

### Task 9: SwiftLint errors

Audit finding: 4 SwiftLint errors (parameter count in `ProjectViewModel.createProject/updateProject`; body length and line length in `SampleData`).

**Files:**
- Create: `Iterly/Tabs/Projects/Models/ProjectInput.swift`
- Modify: `Iterly/Tabs/Dashboard/ProjectViewModel.swift`, `Iterly/Tabs/Projects/Helpers/ProjectFormViewModel.swift`, `Iterly/Helpers/SampleData.swift`
- Test: `IterlyTests/ProjectViewModelTests.swift` (from Task 4)

**Interfaces:**
- Produces: `struct ProjectInput { var title: String; var details: String; var note: String; var type: ProjectType; var priority: ProjectPriority; var status: ProjectStatus; var isPinned: Bool; var version: String; var appStoreURL: String; var usefulLinks: [ProjectLinkInput] }`.
- Changes: `createProject(_ input: ProjectInput, modelContext: ModelContext) async throws`, `updateProject(_ project: Project, with input: ProjectInput, modelContext: ModelContext) async throws`. `ProjectFormViewModel` builds a `ProjectInput` from its fields (`var input: ProjectInput { … }`).

- [ ] **Step 1: Write failing test** `ProjectViewModelTests.createProjectTrimsAndStoresInput` — `createProject(ProjectInput(title: "  Iterly  ", details: "", …, appStoreURL: ""), …)` then fetch: one project, `title == "Iterly"`, `details == nil`.
- [ ] **Step 2: Run** — fails to compile.
- [ ] **Step 3: Implement** `ProjectInput` and the new signatures; update `ProjectFormViewModel`.
- [ ] **Step 4: `SampleData`**: split the 168-line function into per-project private helpers and wrap the 251-char line; behaviour unchanged.
- [ ] **Step 5: Verify**: `cd /Users/filippocilia/Desktop/Projects/iOS/Iterly-audit && swiftlint lint --quiet | grep -c error:` → `0`; iOS tests + macOS build green.
- [ ] **Step 6: Commit** `refactor: ProjectInput value and SampleData split for SwiftLint`.

---

## Out of scope (reported, not changed)

- `SWIFT_VERSION = 5.0` → Swift 6 strict concurrency migration (CLAUDE.md wants Swift 6; needs its own plan).
- Deployment target iOS 18 vs CLAUDE.md's iOS 26.
- Tier 2/3 iPhone Duo work (ArrangementView, reserved regions, hinge, scene accessories) — nothing in Iterly depends on the fold, and none of it can be verified without the Duo simulator.
- Manual checks only the user can run: iPhone Duo simulator folds/rotations, macOS widget refresh.
