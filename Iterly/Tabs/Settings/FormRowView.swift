//
//  FormRowView.swift
//  Iterly
//
//  Created by Filippo Cilia on 3/30/26.
//

import SwiftUI

struct FormRowView: View {
    let imageName: String
    let foregroundColor: Color
    let backgroundColor: Color
    let text: String

    @ScaledMetric(relativeTo: .body) private var side = 28.0

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .padding(4)
                .frame(width: side, height: side, alignment: .center)
                .foregroundStyle(foregroundColor)
                .background(backgroundColor.gradient)
                .clipShape(.rect(cornerRadius: AppCornerRadius.small))
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(.rect)
    }
}

#Preview {
    FormRowView(imageName: "brain", foregroundColor: .white, backgroundColor: .pink.mix(with: .white, by: 0.2), text: "Agentic model")
}
