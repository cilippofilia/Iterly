//
//  ProjectsLegendView.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI
import IterlyCore

struct ProjectsLegendView: View {
    let orderedStatuses: [TaskStatus]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(orderedStatuses, id: \.self) { status in
                Circle()
                    .fill(status.backgroundColor)
                    .frame(width: 6, height: 6)
                Text(status.title)
                    .font(.caption2)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
        .padding(.bottom, 8)
    }
}
