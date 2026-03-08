//
//  HomeView.swift
//  Iterly
//
//  Created by Filippo Cilia on 25/02/2026.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    static let homeTag: String? = "Home"

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProjectViewModel()
    @State private var showEraseDataAlert: Bool = false
    @State private var showAddDataAlert: Bool = false

    @Query(
        filter: #Predicate<Project> { $0.isPinned == true },
        sort: \Project.creationDate,
        order: .reverse
    )
    private var pinnedProjects: [Project]

    @Query(
        filter: #Predicate<Project> { $0.isPinned == false },
        sort: \Project.creationDate,
        order: .reverse
    )
    private var projects: [Project]
    
    @Query(sort: \ProjectTask.dueDate, order: .reverse)
    private var tasks: [ProjectTask]

    var body: some View {
        NavigationStack {
            Group {
                if pinnedProjects.isEmpty, projects.isEmpty, tasks.isEmpty {
                    UnavailableProjectsView()
                } else {
                    availableView
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ereaseAllDataButton
                    addSampleDataButton
                }
            }
            .alert("Erase All Data?", isPresented: $showEraseDataAlert) {
                Button("Erase Data", role: .destructive) {
                    viewModel.eraseAllData(modelContext: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove all projects, tasks, and releases.")
            }
            .alert("Add Sample Data?", isPresented: $showAddDataAlert) {
                Button("Add Data") {
                    viewModel.addSampleData(modelContext: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Sample data will be added to your current projects.")
            }
        }
    }
}

extension HomeView {
    private var totalProjectsCount: Int {
        pinnedProjects.count + projects.count
    }
    private var showMore: Bool {
        return totalProjectsCount > 5
    }

    private var availableView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                let upcomingTasks = tasks
                    .filter { $0.project.status != .closed }
                    .filter { $0.status != .done }
                    .filter { $0.parentTask == nil }
                    .sorted { lhs, rhs in
                        if lhs.dueDate != rhs.dueDate {
                            return lhs.dueDate < rhs.dueDate
                        }
                        return lhs.priority.sortRank < rhs.priority.sortRank
                    }

                PinnedProjectsSection(projects: pinnedProjects)
                    .padding(.bottom)

                ProjectsSection(
                    projects: Array(projects.prefix(5)),
                    allProjectsCount: totalProjectsCount,
                    showMore: showMore
                )
                .padding(.bottom)

                TasksSection(tasks: Array(upcomingTasks.prefix(10)))
                    .padding(.bottom)
            }
        }
        .navigationDestination(for: Project.self) { project in
            ProjectDetailView(project: project)
        }
        .navigationDestination(for: UUID.self) { taskId in
            if let task = tasks.first(where: { $0.id == taskId }) {
                TaskDetailView(task: task)
            }
        }
        .contentMargins(.bottom, 70, for: .scrollContent)
    }

    var addSampleDataButton: some View {
        Button(
            "Add Data",
            systemImage: "sparkles",
            action: {
                showAddDataAlert = true
            }
        )
    }
    var ereaseAllDataButton: some View {
        Button(
            "Erase Data",
            systemImage: "trash",
            role: .destructive,
            action: {
                showEraseDataAlert = true
            }
        )
    }
}

#Preview {
    HomeView()
        .modelContainer(SampleData.makePreviewContainer())
}
