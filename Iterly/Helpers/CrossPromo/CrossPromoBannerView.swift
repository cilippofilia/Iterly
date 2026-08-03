//
//  CrossPromoBannerView.swift
//  Iterly
//

import Billboard
import SwiftUI

/// A persistent ambient banner ad for Filippo Cilia's other apps, refreshed each time this view
/// appears. Used at the bottom of both the Dashboard and Settings tabs.
struct CrossPromoBannerView: View {
    @State private var ad: BillboardAd?

    var body: some View {
        Group {
            if let ad {
                BillboardBannerView(advert: ad, config: .crossPromo, hideDismissButtonAndTimer: true)
                    .padding()
            }
        }
        .task {
            await refreshAd()
        }
    }

    private func refreshAd() async {
        guard let url = BillboardConfiguration.crossPromo.adsJSONURL else { return }
        ad = try? await BillboardViewModel.fetchRandomAd(
            from: url,
            excludedIDs: BillboardConfiguration.crossPromo.excludedIDs
        )
    }
}

#Preview {
    CrossPromoBannerView()
}
