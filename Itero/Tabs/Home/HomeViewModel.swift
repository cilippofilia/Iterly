import Observation
import SwiftData

@MainActor
@Observable
final class HomeViewModel {
    func addSampleData(modelContext: ModelContext) {
        SampleData.insertSample(in: modelContext)
    }
}
