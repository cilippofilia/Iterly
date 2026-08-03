//
//  SelectProjectsIntent.swift
//  IterlyCore
//
//  Created by Filippo Cilia on 03/08/2026.
//

import AppIntents
import WidgetKit

/// Configuration for the large Activity widget's project list. Four fixed slots (rather than one
/// array parameter) so the Edit Widget UI can't let someone pick more than 4 in the first place.
/// Leaving every slot empty keeps the automatic behavior: the 4 most recently updated,
/// non-closed projects.
public struct SelectProjectsIntent: WidgetConfigurationIntent {
    public static let title: LocalizedStringResource = "Select Projects"
    public static let description = IntentDescription("""
        Pick up to 4 projects to pin to the large Activity widget. Leave every slot empty to \
        always show your 4 most recently updated projects instead.
        """)

    @Parameter(title: "Project 1")
    public var project1: ProjectEntity?

    @Parameter(title: "Project 2")
    public var project2: ProjectEntity?

    @Parameter(title: "Project 3")
    public var project3: ProjectEntity?

    @Parameter(title: "Project 4")
    public var project4: ProjectEntity?

    public init() {}

    public init(
        project1: ProjectEntity?,
        project2: ProjectEntity?,
        project3: ProjectEntity?,
        project4: ProjectEntity?
    ) {
        self.project1 = project1
        self.project2 = project2
        self.project3 = project3
        self.project4 = project4
    }

    /// The chosen projects in slot order, de-duplicated so picking the same project into
    /// multiple slots doesn't show it twice.
    public var selectedProjectIDs: [UUID] {
        var seen = Set<UUID>()
        return [project1, project2, project3, project4]
            .compactMap { $0?.id }
            .filter { seen.insert($0).inserted }
    }
}
