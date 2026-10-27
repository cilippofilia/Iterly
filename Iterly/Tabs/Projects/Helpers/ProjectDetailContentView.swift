//
//  ProjectDetailContentView.swift
//  Iterly
//

import SwiftData
import SwiftUI
import IterlyCore

/// The live content of a project's detail screen; only shown for a stored project.
struct ProjectDetailContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @State private var viewModel = ProjectViewModel()
    @State private var showPinLimitAlert: Bool = false
    @State private var projectToEdit: Project?
    @State private var showAddTaskSheet: Bool = false
    @State private var showBrainstormSheet: Bool = false
    @State private var externalLinkErrorMessage: String?
    @State private var errorMessage: String?

    @Bindable var project: Project
    var onDelete: () -> Void = {}

    var body: some View {
        let sections = TaskSectionsBuilder.sections(for: project.topLevelTasks)
        let externalDestinations = ExternalDestination.destinations(for: project.currentRelease)

        ScrollView {
            VStack(alignment: .leading) {
                if let details = project.details, !details.isEmpty {
                    Text(details)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }

                ProjectInfoBoxView(project: project)

                HStack {
                    PrimaryCapsuleActionButton(
                        title: "Brainstorm",
                        systemImage: "brain",
                        showsIndicator: project.note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
                        action: { showBrainstormSheet = true }
                    )

                    if externalDestinations.isEmpty == false {
                        Menu {
                            ForEach(externalDestinations) { destination in
                                Button(destination.title, systemImage: destination.systemImage) {
                                    openExternalDestination(destination)
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
            .readableContentWidth()
        }
        .navigationTitle(project.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(project.isPinned ? "Unpin" : "Pin", systemImage: "pin", action: togglePin)
                    .symbolVariant(project.isPinned ? .fill : .none)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", systemImage: "pencil.line") {
                    projectToEdit = project
                }
            }
        }
        .sheet(item: $projectToEdit) { project in
            NavigationStack {
                ProjectFormView(project: project, onDelete: onDelete)
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
        .alert("Something Went Wrong", item: $errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: {
            Text($0)
        }
        .alert("Can't Pin Project", isPresented: $showPinLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Only 4 projects can be pinned at the same time.")
        }
        .alert("Can't Open Link", isPresented: Binding(
            get: { externalLinkErrorMessage != nil },
            set: { newValue in
                if newValue == false {
                    externalLinkErrorMessage = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                externalLinkErrorMessage = nil
            }
        } message: {
            Text(externalLinkErrorMessage ?? "Something went wrong.")
        }
    }

    private func togglePin() {
        do {
            if try viewModel.togglePin(project: project, modelContext: modelContext) == .limitReached {
                showPinLimitAlert = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func openExternalDestination(_ destination: ExternalDestination) {
        guard let resolvedURL = destination.resolvedURL else {
            externalLinkErrorMessage = "The link for \(destination.title) is invalid. Use a full URL like https://example.com."
            return
        }

        openURL(resolvedURL) { accepted in
            if accepted == false {
                externalLinkErrorMessage = "Unable to open \(destination.displayURL). Check that the link is valid."
            }
        }
    }
}
