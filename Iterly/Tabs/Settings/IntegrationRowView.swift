//
//  IntegrationRowView.swift
//  Iterly
//
//  Created by Filippo Cilia on 3/31/26.
//

import SwiftUI

struct IntegrationRowView: View {
    let title: String
    let description: String?
    let url: String?
    let action: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(title)

                HStack(spacing: 0) {
                    if let description, description.isEmpty == false {
                        Text(description)
                    }

                    if let url, url.isEmpty == false {
                        Text(":")
                        Text(url)
                            .padding(.leading, 4)
                            .lineLimit(1)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: action) {
                Label("Remove", systemImage: "minus.circle.fill")
                    .foregroundStyle(.red)
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    IntegrationRowView(title: "Project name", description: "Figma", url: "https://www.figma.com/file/example", action: { print("REMOVE ROW") })
}
