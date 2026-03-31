//
//  ProjectDetailView.swift
//  Iterly
//
//  Created by Filippo Cilia on 02/03/2026.
//

import SwiftData
import SwiftUI

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @State private var viewModel = ProjectViewModel()
    @State private var showPinLimitAlert: Bool = false
    @State private var projectToEdit: Project?
    @State private var showAddTaskSheet: Bool = false
    @State private var showBrainstormSheet: Bool = false

    @Bindable var project: Project

    private var externalDestinations: [ExternalDestination] {
        var destinations: [ExternalDestination] = []

        if let appStoreURL = project.currentRelease?.appStoreURL.trimmingCharacters(in: .whitespacesAndNewlines),
           appStoreURL.isEmpty == false,
           let destination = URL(string: appStoreURL) {
            destinations.append(
                ExternalDestination(
                    title: "App Store",
                    systemImage: "apple.logo",
                    url: destination
                )
            )
        }

        for link in project.currentRelease?.usefulLinks ?? [] {
            let trimmedURL = link.url.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedURL.isEmpty == false,
                  let destination = URL(string: trimmedURL) else { continue }

            destinations.append(
                ExternalDestination(
                    title: link.label,
                    systemImage: link.kind.systemImage,
                    url: destination
                )
            )
        }

        return destinations
    }

    var body: some View {
        let sections = TaskSectionsBuilder.sections(for: project.topLevelTasks)

        ScrollView {
            VStack(alignment: .leading) {
                if let details = project.details, !details.isEmpty {
                    Text(details)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }

                ProjectInfoBoxView(
                    project: project
                )

                HStack {
                    PrimaryCapsuleActionButton(
                        title: "Brainstorm",
                        systemImage: "brain",
                        action: { showBrainstormSheet = true }
                    )

                    if externalDestinations.isEmpty == false {
                        Menu {
                            ForEach(externalDestinations) { destination in
                                Button(destination.title, systemImage: destination.systemImage) {
                                    openURL(destination.url)
                                }
                            }
                        } label: {
                            Label("Navigate to...", systemImage: "arrow.up.right.square")
                                .secondaryCapsuleButtonStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }

                ProjectTaskSectionsView(
                    sections: sections,
                    onAddTask: {
                        showAddTaskSheet = true
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .bottom])
        }
        .navigationTitle(project.title)
        .contentMargins(.bottom, 70, for: .scrollContent)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    if viewModel.togglePin(project: project, modelContext: modelContext) == false {
                        showPinLimitAlert = true
                    }
                }) {
                    Image(systemName: "pin")
                        .rotationEffect(Angle(degrees: 45))
                        .symbolVariant(project.isPinned ? .fill : .none)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit", systemImage: "pencil.line") {
                    projectToEdit = project
                }
            }
        }
        .sheet(item: $projectToEdit) { project in
            NavigationStack {
                ProjectFormView(project: project)
            }
        }
        .sheet(isPresented: $showAddTaskSheet) {
            NavigationStack {
                TaskFormView(project: project)
            }
        }
        .sheet(isPresented: $showBrainstormSheet) {
            NavigationStack {
                BrainstormFormView(text: Binding(
                    get: { project.note ?? "" },
                    set: { project.note = $0.isEmpty ? nil : $0 }
                ))
            }
            .presentationDetents([.medium])
        }
        .alert("Can't Pin Project", isPresented: $showPinLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Only 4 projects can be pinned at the same time.")
        }
    }
}

private struct ExternalDestination: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let url: URL
}

#Preview("Light") {
    NavigationStack {
        ProjectDetailView(project: SampleData.makeProjects()[0])
    }
    .modelContainer(SampleData.makePreviewContainer())
}
