//
//  ProjectRowView.swift
//  Iterly
//
//  Created by Filippo Cilia on 06/03/2026.
//

import SwiftUI

struct ProjectRowView: View {
    let title: String
    let statusTitle: String
    let statusColor: Color
    let currentRelease: ProjectRelease?
    
    let tasks: [ProjectTask]

    let blockedAmount: CGFloat
    let inProgressAmount: CGFloat
    let doneAmount: CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Text(title)
                    .bold()
                    .lineLimit(1)
                if let releaseText = releaseText(for: currentRelease) {
                    Text(releaseText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(statusTitle)
                    .badgeStyle(backgroundColor: statusColor)
            }

            Text(String.localizedStringWithFormat(NSLocalizedString("tasks_count", comment: "Tasks count"), tasks.count))
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: inProgressAmount + blockedAmount + doneAmount)
                .tint(tasks.first(where: { $0.status == .done })?.status.backgroundColor)
                .overlay {
                    ProgressView(value: inProgressAmount + blockedAmount)
                        .tint(tasks.first(where: { $0.status == .inProgress })?.status.backgroundColor)
                }
                .overlay {
                    ProgressView(value: blockedAmount)
                        .tint(tasks.first(where: { $0.status == .blocked })?.status.backgroundColor)
                }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func releaseText(for release: ProjectRelease?) -> String? {
        guard let release else { return nil }
        if release.version.isEmpty, release.build.isEmpty { return nil }

        if release.version.isEmpty {
            return "Build \(release.build)"
        }
        if release.build.isEmpty {
            return "v\(release.version)"
        }
        return "v\(release.version) (\(release.build))"
    }
}

#Preview {
    let data = SampleData.makeProjects()[0]
    ProjectRowView(
        title: data.title,
        statusTitle: data.status.title,
        statusColor: data.status.backgroundColor,
        currentRelease: data.currentRelease,
        tasks: data.topLevelTasks,
        blockedAmount: 0.1,
        inProgressAmount: 0.3,
        doneAmount: 0.4
    )
}
