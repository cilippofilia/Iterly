//
//  SeeMoreCellView.swift
//  Iterly
//
//  Created by Filippo Cilia on 07/03/2026.
//

import SwiftUI

struct SeeAllCellView: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                action()
            }) {
                Text("See all projects...")
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

#Preview {
    SeeAllCellView(action: { })
}
