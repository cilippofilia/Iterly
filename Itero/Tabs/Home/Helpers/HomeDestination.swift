//
//  ProjectsSection.swift
//  Itero
//
//  Created by Filippo Cilia on 25/02/2026.
//

import Foundation

enum HomeDestination: Hashable {
    case project(id: UUID)
    case task(id: UUID)
}
