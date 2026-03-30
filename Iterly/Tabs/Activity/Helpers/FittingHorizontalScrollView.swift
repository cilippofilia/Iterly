//
//  FittingHorizontalScrollView.swift
//  Iterly
//
//  Created by Filippo Cilia on 30/03/2026.
//

import SwiftUI

struct FittingHorizontalScrollView<Content: View>: View {
    let minimumContentWidth: CGFloat
    let content: (CGFloat) -> Content

    init(
        minimumContentWidth: CGFloat,
        @ViewBuilder content: @escaping (CGFloat) -> Content
    ) {
        self.minimumContentWidth = minimumContentWidth
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let contentWidth = max(geometry.size.width, minimumContentWidth)

            ScrollView(.horizontal) {
                content(contentWidth)
                    .frame(width: contentWidth, alignment: .leading)
            }
            .defaultScrollAnchor(.trailing)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            .scrollIndicators(.hidden)
        }
    }
}
