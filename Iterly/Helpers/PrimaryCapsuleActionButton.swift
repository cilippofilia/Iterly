//
//  PrimaryCapsuleActionButton.swift
//  Iterly
//
//  Created by Filippo Cilia on 10/03/2026.
//

import SwiftUI

struct PrimaryCapsuleActionButton: View {
    let title: String
    let systemImage: String
    /// Shows a dot badge, e.g. when the button opens content that isn't empty.
    var showsIndicator: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                HStack(spacing: 4) {
                    if showsIndicator {
                        Image(systemName: "circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .accessibilityHidden(true)
                    }
                    Image(systemName: systemImage)
                }
            }
            .primaryCapsuleButtonStyle()
        }
        .accessibilityValue(showsIndicator ? Text("Has notes") : Text(""))
    }
}
