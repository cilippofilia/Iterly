import Foundation
import IterlyCore

/// The raw (untrimmed) values collected by the project form, passed to
/// `ProjectViewModel` when creating or updating a project.
struct ProjectInput {
    var title: String
    var details: String
    var note: String
    var type: ProjectType
    var priority: ProjectPriority
    var status: ProjectStatus
    var isPinned: Bool
    var version: String
    var appStoreURL: String
    var usefulLinks: [ProjectLinkInput]
}
