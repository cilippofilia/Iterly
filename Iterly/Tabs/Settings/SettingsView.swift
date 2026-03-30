//
//  SettingsView.swift
//  Iterly
//
//  Created by Filippo Cilia on 3/30/26.
//

import SwiftUI
import SwiftData

@MainActor
struct SettingsView: View {
    static let settingsTag: String? = "Settings"

    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Show completed tasks", isOn: $viewModel.showCompletedTasks)
                    Toggle("Highlight overdue tasks", isOn: $viewModel.highlightOverdueTasks)
                    Toggle("Compact project cards", isOn: $viewModel.compactProjectCards)
                } header: {
                    Text("Preferences - not yet implemented")
                }

                Section {
                    NavigationLink {
                        ContentUnavailableView(
                            "No integrations yet",
                            systemImage: "link",
                            description: Text("Connected services and sync options can be added here later.")
                        )
                    } label: {
                        FormRowView(
                            imageName: "link",
                            foregroundColor: .white,
                            backgroundColor: .blue,
                            text: "Integrations"
                        )
                    }

                    NavigationLink {
                        ContentUnavailableView(
                            "No exports yet",
                            systemImage: "square.and.arrow.up",
                            description: Text("Export and backup options can be added here later.")
                        )
                    } label: {
                        FormRowView(
                            imageName: "square.and.arrow.down",
                            foregroundColor: .white,
                            backgroundColor: .secondary,
                            text: "Export Data"
                        )
                    }
                } header: {
                    Text("Data - not yet implemented")
                }

                Section("Data Management") {
                    Button {
                        viewModel.addSampleData(modelContext: modelContext)
                    } label: {
                        FormRowView(
                            imageName: "wand.and.sparkles",
                            foregroundColor: .white,
                            backgroundColor: .indigo.mix(with: .purple, by: 0.5),
                            text: "Add Sample Data"
                        )
                    }
                    .buttonStyle(.plain)

                    Button(role: .destructive) {
                        viewModel.promptEraseAllData()
                    } label: {
                        FormRowView(
                            imageName: "trash",
                            foregroundColor: .white,
                            backgroundColor: .red,
                            text: "Erase All Data"
                        )
                    }
                    .buttonStyle(.plain)
                }

                Section {
                    Button {
                        if let appStoreReviewURL = viewModel.appStoreReviewURL {
                            openURL(appStoreReviewURL)
                        }
                    } label: {
                        FormRowView(
                            imageName: "star.fill",
                            foregroundColor: .yellow,
                            backgroundColor: .secondary,
                            text: "Rate the app"
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.showContactOptions = true
                    } label: {
                        FormRowView(
                            imageName: "envelope",
                            foregroundColor: .white,
                            backgroundColor: .blue.mix(with: .white, by: 0.1),
                            text: "Contact the developer"
                        )
                    }
                    .buttonStyle(.plain)
                    .tint(.red)
                    .confirmationDialog(
                        "Select an option",
                        isPresented: $viewModel.showContactOptions,
                        titleVisibility: .visible
                    ) {
                        ForEach(SettingsViewModel.ContactOption.allCases) { option in
                            Button(option.title) {
                                if let mailURL = viewModel.mailURL(for: option) {
                                    openURL(mailURL)
                                }
                            }
                        }
                    }

                    if let appShareURL = viewModel.appShareURL {
                        ShareLink(item: appShareURL) {
                            FormRowView(
                                imageName: "square.and.arrow.up",
                                foregroundColor: .white,
                                backgroundColor: .secondary,
                                text: "Share the app"
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        ShareLink(item: viewModel.appShareItem) {
                            FormRowView(
                                imageName: "square.and.arrow.up",
                                foregroundColor: .white,
                                backgroundColor: .secondary,
                                text: "Share the app"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Contacts")
                } footer: {
                    Text("App Version: \(viewModel.currentVersion)")
                        .font(.footnote)
                }
            }
            .navigationTitle("Settings")
            .alert(item: $viewModel.activeAlert) { alertKind in
                switch alertKind {
                case .sampleDataAdded:
                    Alert(
                        title: Text(alertKind.title),
                        message: Text(alertKind.message),
                        dismissButton: .cancel(Text("OK")) {
                            viewModel.activeAlert = nil
                        }
                    )
                case .eraseAllDataConfirmation:
                    Alert(
                        title: Text(alertKind.title),
                        message: Text(alertKind.message),
                        primaryButton: .destructive(Text("Erase")) {
                            viewModel.eraseAllData(modelContext: modelContext)
                        },
                        secondaryButton: .cancel {
                            viewModel.activeAlert = nil
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
