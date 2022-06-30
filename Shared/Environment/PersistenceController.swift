//
//  Persistence.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import CoreData

struct PersistenceController {
    static let shared: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        generateTagPreset(context: result.container.viewContext)
        return result
    }()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        generateTagPreset(context: result.container.viewContext)
        return result
    }()

    let container: NSPersistentCloudKitContainer

    static func generateTagPreset(context: NSManagedObjectContext) {
        for tagInput in Tag.presets {
            Tag.register(input: tagInput, context: context)
        }
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "PouringDiary")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // TODO: CoreData 초기화 실패 시 에러 핸들링. 배포 직전에 처리할 것. 개발 도중에는 fatalError를 위해서 남겨둠
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or
                 * data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
