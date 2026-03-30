//
//  ActivityLegendView.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import SwiftUI

struct ActivityLegendView: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("Less")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(0 ..< 5, id: \.self) { level in
                Rectangle()
                    .fill(color(for: level).gradient)
                    .frame(width: 14, height: 14)
                    .clipShape(.rect(cornerRadius: AppCornerRadius.tiny))
            }

            Text("More")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Activity legend from less to more")
    }

    private func color(for level: Int) -> Color {
        switch level {
        case 0: Color.secondary.opacity(0.2)
        case 1: Color.green.opacity(0.4)
        case 2: Color.green.opacity(0.6)
        case 3: Color.green.opacity(0.8)
        default: Color.green
        }
    }
}

#Preview {
    ActivityLegendView()
}
