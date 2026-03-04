//
//  ProjectCell.swift
//  Iterly
//
//  Created by Filippo Cilia on 01/03/2026.
//

import SwiftUI

struct ProjectCell: View {
    let title: String
    let tasksCount: Int
    let progressValue: Double
    let progressColor: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(String.localizedStringWithFormat(NSLocalizedString("tasks_count", comment: "Tasks count"), tasksCount))
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: progressValue)
                .tint(progressColor)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
    }
}

#Preview {
    ProjectCell(title: "Drinko", tasksCount: 4, progressValue: 5.5, progressColor: .red)
}
