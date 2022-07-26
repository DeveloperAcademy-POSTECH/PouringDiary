//
//  Persistence.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared: PersistenceController = {
        let result = PersistenceController()
        return result
    }()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "PouringDiary")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Unresolved error with loading persistentStoreDescriptions")
        }

        // MARK: Public Database
        let publicStoreUrl = description.url!
            .deletingLastPathComponent()
            .appendingPathComponent("PouringDiary-public.sqlite")
        let identifier = description.cloudKitContainerOptions!.containerIdentifier

        let publicDescription = NSPersistentStoreDescription(url: publicStoreUrl)
        publicDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        publicDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let publicOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifier)
        publicOptions.databaseScope = .public
        publicDescription.cloudKitContainerOptions = publicOptions
        publicDescription.configuration = "Public"

        // MARK: Private Database
        let privateStoreUrl = description.url!
            .deletingLastPathComponent()
            .appendingPathComponent("PouringDiary-private.sqlite")
        let privateIdentifier = description.cloudKitContainerOptions!.containerIdentifier

        let privateDescription = NSPersistentStoreDescription(url: privateStoreUrl)
        privateDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        privateDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let privateOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: privateIdentifier)
        privateOptions.databaseScope = .private
        privateDescription.cloudKitContainerOptions = privateOptions
        privateDescription.configuration = "Private"

        container.persistentStoreDescriptions = [
            publicDescription,
            privateDescription
        ]

        if inMemory {
            _ = container.persistentStoreDescriptions
                .enumerated()
                .map {
                    $1.url = URL(fileURLWithPath: "/dev/null\($0)")
                }

            _ = Tag.presets.map { Tag.register(input: $0, context: container.viewContext) }
            
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        container.loadPersistentStores(completionHandler: {(_, error) in
            if let error = error as NSError? {
                // TODO: CoreData 초기화 실패 시 에러 핸들링. 배포 직전에 처리할 것. 개발 도중에는 fatalError를 위해서 남겨둠
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
