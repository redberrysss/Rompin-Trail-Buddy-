import Foundation
import SwiftData

@Model
final class PendingUploadTask {
    var id: String
    var ownerId: String
    var participantId: String
    var activityNumber: Int
    var localFilePath: String
    var storageDestinationPath: String
    var recordType: String
    var recordPayload: String
    var retryCount: Int
    var createdAt: Date

    init(ownerId: String, participantId: String, activityNumber: Int, localFilePath: String, storageDestinationPath: String, recordType: String, recordPayload: String) {
        self.id = UUID().uuidString
        self.ownerId = ownerId
        self.participantId = participantId
        self.activityNumber = activityNumber
        self.localFilePath = localFilePath
        self.storageDestinationPath = storageDestinationPath
        self.recordType = recordType
        self.recordPayload = recordPayload
        self.retryCount = 0
        self.createdAt = Date()
    }
}

final class PendingUploadService {
    static let shared = PendingUploadService()

    private init() {}

    func saveTask(_ task: PendingUploadTask, context: ModelContext) {
        context.insert(task)
        try? context.save()
    }

    func fetchPendingTasks(context: ModelContext) -> [PendingUploadTask] {
        let descriptor = FetchDescriptor<PendingUploadTask>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func removeTask(_ task: PendingUploadTask, context: ModelContext) {
        context.delete(task)
        try? context.save()
    }

    func incrementRetry(_ task: PendingUploadTask, context: ModelContext) {
        task.retryCount += 1
        try? context.save()
    }
}
