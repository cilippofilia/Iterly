# Iterly Roadmap

Iterly is a lightweight, local-first project tracker for solo builders: projects, tasks and subtasks, releases with useful links, and an activity heatmap — all SwiftUI + SwiftData with no backend. This roadmap moves it from "solid personal tool" toward a polished, shippable App Store product: fix the known rough edges first, land the confirmed feature requests next, then grow into sync, widgets, and platform breadth.

Sizes: **S** = an hour or two · **M** = a day-ish · **L** = multi-day.

---

## 1. Now — bugs & polish (next release)

### 1.1 Fix task sorting — **S/M**
Tasks currently have **no sorting at all**: `TaskSectionsBuilder.sections(for:)` (`Iterly/Helpers/TaskSectionsBuilder.swift`) and `Project.topLevelTasks` (`Iterly/Tabs/Projects/Models/Project.swift`) only filter, so lists render in whatever order SwiftData returns relationship arrays — which is effectively arbitrary and shifts between launches. That's the "broken" feel.

**Decision (confirmed):** sort by **priority → due date → creation date**:
1. `TaskPriority.sortRank` ascending (high first; already defined in `Iterly/Tabs/Projects/Models/Priority-Emus.swift`)
2. earliest `dueDate` first, tasks with no due date last
3. `creationDate` as the stable tiebreaker

- Extract one shared comparator (e.g. `ProjectTask.displayOrder` sort or a `static func sorted(_:)`) and apply it in `TaskSectionsBuilder`, `topLevelTasks`, and the subtask sections (`TaskSubtaskSectionsView`) so every list in the app agrees.
- Align `HomeViewModel.upcomingTasks(from:)` with the same comparator (it currently sorts due-date-first and excludes tasks without due dates — fine for "Upcoming", but it should reuse the shared logic where possible).
- Add unit tests for the comparator (see §6).

### 1.2 Hide closed projects on the Home screen — **S**
Both `@Query` predicates in `Iterly/Tabs/Home/HomeView.swift` filter only on `isPinned`, so closed projects still show up in Pinned and Projects sections on Home. Add `status != .closed` to both predicates (use the raw-value comparison if `#Predicate` can't compare the enum directly — the model stores it via a raw value). The Projects tab already handles this correctly via `ProjectsViewModel.splitProjects()`; Home should match. Also decide whether a *pinned* project that gets closed should be auto-unpinned (recommended: yes, on status change to `.closed`).

### 1.3 Fix Activity Overview header layout (Home + Activity) — **S**
In `Iterly/Tabs/Activity/Views/ActivityOverviewSectionView.swift` the header `HStack(alignment: .firstTextBaseline)` fights the legend layout:
- In the **Home** branch the inner `VStack` has no `alignment: .leading`, so "Activity Overview" and the legend center-align instead of leading-align.
- In the **Activity** branch the legend is baseline-aligned with the title *and* pushed trailing with `.frame(maxWidth: .infinity, alignment: .trailing)`, which misaligns/crowds it against the edge.

Fix: give the Home `VStack` `alignment: .leading`; for the Activity branch use a plain `HStack` with a `Spacer()` (or `.center` alignment) between title and legend rather than baseline + infinite-width frame. Also fix the `#Preview("Home Style")` which passes `isHomeView: false` — it previews the wrong layout, which is how this regression slipped through.

---

## 2. Next — requested features

### 2.1 Image & video attachments on tasks and subtasks — **L**
For referencing bugs visually (screenshots, screen recordings).

**Decision (confirmed):** photos **and** videos, picked from the photo library via `PhotosPicker`.

- New `TaskAttachment` SwiftData model: `id`, `kind` (image/video), `@Attribute(.externalStorage) var data: Data?`, optional pre-rendered thumbnail data, `creationDate`, optional inverse relationship to `ProjectTask` (subtasks get this for free since they're also `ProjectTask`). Add to the schema in `IterlyApp.swift`.
- UI: attachment section in `TaskFormView` / `TaskDetailView` with a thumbnail strip; tap to open a full-screen viewer (zoomable images, `AVKit.VideoPlayer` for video); swipe/`Button` to delete.
- Guardrails: generate thumbnails off the main actor; consider a per-video size cap or warning since everything lives in the SwiftData store (external storage keeps blobs out of the DB file, but device space still matters).
- Keep CloudKit in mind (§5.1): all properties optional/defaulted, relationship optional — the model sketch above already complies.

### 2.2 Productivity tips — **M**
**Decision (confirmed):** a rotating "Tip of the day" card on **Home**, dismissible, with a browse-all list.

- Static tip catalog bundled in the app (a `ProductivityTip` struct + array, or a JSON resource): short, app-aware tips ("Pin up to 4 projects to keep them on Home", "Set due dates so tasks appear in Upcoming", "Log activity daily to build your streak"…).
- `TipCardView` on Home (likely in `HomeAvailableView` near the top): rotates by day-of-year, "dismiss for today" persisted via `@AppStorage`.
- "See all" pushes a simple list screen of every tip. Re-enable surface in Settings if the user dismisses tips permanently.

### 2.3 TestFlight link type — **S** — ✅ done 2026-07-01
Add `.testflight` to `ProjectLinkKind` (`Iterly/Tabs/Projects/Models/ProjectLink.swift`) with a label ("TestFlight") and SF Symbol (shipped with `fanblades`, matching TestFlight's propeller logo). It flows automatically into the link picker in `ProjectFormView`, the "Navigate to…" menu in `ProjectDetailView`, and Integrations settings, since those all iterate the enum. Also shipped: `testflight.apple.com` URLs typed into a link draft switch the kind to TestFlight automatically (`ProjectLinkKind.detected(fromURL:)`; custom-labeled links are left alone).

---

## 3. Near-term enhancements (suggested, roughly ranked)

1. **Search — M.** A searchable Projects tab (`.searchable`, filtering with `localizedStandardContains`) across project titles, task titles, and notes. The app gets hard to navigate past ~10 projects.
2. **Due-date notifications — M.** Local notifications for tasks with due dates (morning-of, plus overdue nudge), with a Settings toggle. `TaskOverdueCalculator` already defines overdue semantics.
3. **Quick actions on rows — S/M.** Swipe actions on task rows (mark done, change status, delete) and context menus on project cells. Right now status changes require drilling into detail views.
4. **User-selectable sort + manual reorder — M.** A sort picker (priority / due date / created / manual) persisted per user, and a `sortOrder: Int` field on `ProjectTask` to support drag-to-reorder in manual mode. Builds on the §1.1 comparator.
5. **Release history & changelog — M.** Projects only track `currentRelease`; keep an array of past releases with dates and notes so the Activity story ("what shipped when") gets richer.
6. **Tags/labels for tasks — M.** Lightweight cross-project labels ("bug", "ASO", "design") with filtering. Pairs well with search.
7. **Brainstorm → task promotion — S.** `BrainstormFormView` exists; add a one-tap "convert to task" so ideas don't die in notes.
8. **Recurring tasks — M/L.** Repeat rules (daily/weekly/monthly) for maintenance chores like "check crash reports".
9. **Empty states & onboarding — S/M.** First-run experience explaining the Home/Projects/Activity flow; richer empty states with calls to action instead of blank sections.
10. **Activity event detail polish — S.** Deep-link from a heatmap day's events to the actual task/project.

---

## 4. Longer-term / bigger bets

- **iCloud sync (CloudKit + SwiftData) — L.** The biggest user-facing bet: data currently dies with the device. Requires a model audit (no `@Attribute(.unique)`, every property optional or defaulted, all relationships optional — current models are close), a CloudKit container/entitlement, and migration testing. Do this **before** the user base grows; it also unlocks a future iPad/Mac story.
- **Home screen widgets (WidgetKit) — L.** "Upcoming tasks" and "activity streak" widgets; the heatmap makes a great medium widget. Needs an App Group to share the SwiftData store.
- **App Intents + Spotlight — M/L.** "Add task to ⟨project⟩" via Siri/Shortcuts, projects and tasks indexed for Spotlight. Also the foundation for interactive widgets and Apple Intelligence integration.
- **iPad & macOS — L.** Adopt `NavigationSplitView`, multi-column layouts. The codebase is cleanly SwiftUI so this is mostly layout work.
- **Data export / backup — M.** JSON export & import from Settings. Important as long as there's no sync; cheap insurance against data loss.
- **Localization — M.** `LocalizedText.swift` exists but the app is English-only; adopt String Catalogs and ship 2–3 languages.
- **Accessibility audit — M.** VoiceOver labels for the heatmap grid and legend, Dynamic Type verification, color-contrast check on status colors.
- **App Store launch checklist — M.** ASO metadata, screenshots, privacy nutrition label (easy: no tracking, local-only), TestFlight beta round.

---

## 5. Engineering health

- **Unit tests (Swift Testing) — M.** Start with pure logic: task comparator (§1.1), `TaskSectionsBuilder`, `ProjectsViewModel.splitProjects`, `HomeViewModel.upcomingTasks`, `TaskOverdueCalculator`, App Store ID extraction in `ProjectRelease`. None of it needs a UI.
- **Fix `Priority-Emus.swift` filename typo — S.** Rename to `Priority-Enums.swift`.
- **SwiftLint — S.** Add it and clear warnings before each commit, per project convention.
- **Shared formatting/comparators — S.** As sorting and date logic consolidates, keep it in `Helpers/` with tests rather than duplicated across view models.

---

## Suggested sequencing

| Release | Contents |
|---|---|
| v-next (bugfix) | §1.1 sorting, §1.2 closed projects, §1.3 overview layout, §2.3 TestFlight links |
| v+1 | §2.1 attachments, §2.2 tips, swipe actions, search |
| v+2 | Notifications, manual reorder, release history, export |
| Beyond | CloudKit sync → widgets → App Intents → iPad/macOS |

The bugfix release is intentionally small and safe; TestFlight links ride along because it's a one-enum change. Attachments is the headline feature for v+1. CloudKit is sequenced before widgets/intents because both benefit from the model audit it forces.
