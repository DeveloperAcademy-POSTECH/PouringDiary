//
//  Persistence.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // SwiftUI Preview 화면을 위한 데이터 생성
        for index in 0..<10 {
            let newItem = Tag(context: viewContext)
            guard let tagColor = Tag.Color(rawValue: index % Tag.Color.allCases.count) else { continue }
            newItem.color = Int16(tagColor.rawValue)
            newItem.content = "Tag_\(index)"
            newItem.created = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // TODO: CoreData 초기화 실패 시 에러 핸들링. 배포 직전에 처리할 것. 개발 도중에는 fatalError를 위해서 남겨둠
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

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
