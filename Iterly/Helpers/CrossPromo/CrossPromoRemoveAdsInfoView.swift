//
//  CrossPromoRemoveAdsInfoView.swift
//  Iterly
//

import SwiftUI

/// Billboard's interstitial always offers a "Remove Ads" button that opens a paywall. Iterly has
/// no ads-removal purchase — these are house ads for Filippo Cilia's own apps rather than
/// third-party monetization — so this explains that instead of presenting a paywall.
struct CrossPromoRemoveAdsInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)

                Text("Iterly Is Free")
                    .font(.title2)
                    .bold()

                Text("These occasional promos are for my other apps — there's no purchase to remove them. Thanks for using Iterly!")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CrossPromoRemoveAdsInfoView()
}
