//
//  BillboardConfiguration+CrossPromo.swift
//  Iterly
//

import Billboard
import Foundation

extension BillboardConfiguration {
    /// Points at a personal cross-promo feed (github.com/cilippofilia/cross-promo-ads) instead
    /// of Billboard's default shared community feed, so only Filippo Cilia's own apps show up.
    /// "6760037639" is this app's own Apple ID (ASC app resource id, same number as the App
    /// Store URL) — excluded so Billboard never advertises Iterly to its own users.
    static let crossPromo = BillboardConfiguration(
        adsJSONURL: URL(string: "https://raw.githubusercontent.com/cilippofilia/cross-promo-ads/main/ads.json"),
        excludedIDs: ["6760037639"]
    )
}
