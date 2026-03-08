//
//  BrainstormFormView.swift
//  Iterly
//
//  Created by Filippo Cilia on 08/03/2026.
//

import SwiftUI

struct BrainstormFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        Form {
            Section("A place to note your ideas and potential features.") {
                TextField(
                    "Start brainstorming...",
                    text: $text,
                    axis: .vertical
                )
                .lineLimit(12...)
            }
        }
        .navigationTitle("Brainstorm")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            isFieldFocused = true
        }
    }
}

#Preview {
    BrainstormFormView(text: .constant("Test"))
}
