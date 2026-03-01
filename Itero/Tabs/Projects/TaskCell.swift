//
//  TaskCell.swift
//  Itero
//
//  Created by Filippo Cilia on 01/03/2026.
//

import SwiftUI

struct TaskCell: View {
    let title: String
    
    var body: some View {
        Text(title)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.gradient.opacity(0.2))
            .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    TaskCell(title: "Update localization")
}
