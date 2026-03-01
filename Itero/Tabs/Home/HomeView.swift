//
//  HomeView.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import CoreSpotlight
import SwiftUI

struct HomeView: View {
    static let homeTag: String? = "Home"

    private let projectRows = [
        GridItem(.fixed(100))
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    // pinned section
                    HStack {
                        Image(systemName: "pin.fill")
                            .imageScale(.small)
                            .rotationEffect(Angle(degrees: 45))
                        Text("Pinned")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(0...2, id: \.self) { _ in
                            PinnedProjectCell()
                                .background(Color.green.opacity(0.3))
                                .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)

                    // projects
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(0...5, id: \.self) { i in
                                PinnedProjectCell()
                                    .background(Color.yellow.opacity(0.3))
                                    .clipShape(.rect(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.hidden)

                    // tasks
                    VStack(alignment: .leading) {
                        Text("Up next:")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        ForEach(0...5, id: \.self) { i in
                            Text("Task \(i)")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.orange.opacity(0.3))
                                .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
            .toolbar {
                Button(
                    "Add Data",
                    systemImage: "plus",
                    action: {
                        print("Adding data...")
                    }
                )
            }
//            .navigationDestination(item: $viewModel.selectedTask) { task in
//                EditTaskView(task: task)
//            }
            .contentMargins(.bottom, 70, for: .scrollContent)
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightTask)
        }
    }

    private func loadSpotlightTask(_ userActivity: NSUserActivity) {
        guard let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }
//        viewModel.selectTask(with: uniqueIdentifier)
    }
}

// PinnedProjectCell.swift
struct PinnedProjectCell: View {
    var body: some View {
        HStack {
            Image(systemName: "circle")
                .imageScale(.large)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading) {
                Text("project.title")
                    .bold()
                    .lineLimit(1)
                Text("4 tasks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 70)
    }
}

#Preview {
    HomeView()
}
