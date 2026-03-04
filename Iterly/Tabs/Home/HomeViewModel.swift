import Foundation
import SwiftData

@MainActor
@Observable
final class HomeViewModel {
    func createProject(modelContext: ModelContext) {
        let project = Project(title: "New Project")
        modelContext.insert(project)

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to create project: \(error)")
        }
    }

    func addSampleData(modelContext: ModelContext) {
        SampleData.insertSample(in: modelContext)
    }

    func eraseAllData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: Project.self)
            try modelContext.delete(
                model: ProjectTask.self,
                where: #Predicate { $0.project == nil }
            )

            try modelContext.save()
        } catch {
            assertionFailure("Failed to erase data: \(error)")
        }
    }
}
