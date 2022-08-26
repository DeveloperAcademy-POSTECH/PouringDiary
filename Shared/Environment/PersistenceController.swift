//
//  Persistence.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import CoreData
import CloudKit

struct PersistenceController {
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = inMemory ?
        NSPersistentContainer(name: "PouringDiary")
        : NSPersistentCloudKitContainer(name: "PouringDiary")

        if inMemory {
            setTestPersistentController()
        } else {
            setCloudKitPersistentController()
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: {(_, error) in
            if let error = error as NSError? {
                // TODO: CoreData 초기화 실패 시 에러 핸들링. 배포 직전에 처리할 것. 개발 도중에는 fatalError를 위해서 남겨둠
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    private func setTestPersistentController() {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description
            .setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        description.configuration = "Test"

        container.persistentStoreDescriptions = [
            description
        ]
    }

    private func setCloudKitPersistentController() {

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
        publicDescription
            .setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

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
        privateDescription
            .setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let privateOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: privateIdentifier)
        privateOptions.databaseScope = .private
        privateDescription.cloudKitContainerOptions = privateOptions
        privateDescription.configuration = "Private"

        container.persistentStoreDescriptions = [
            publicDescription,
            privateDescription
        ]
    }
}

#if DEBUG
// Extension for Preset Generation
extension PersistenceController {
    func preparePresets() async {
        do {
            let tags = try await Tag.presets
                .asyncMap { try await Tag.register(input: $0, context: container.viewContext) }
            let beans = try await CoffeeBean.presets
                .asyncMap { beanInfo in
                    try await CoffeeBean.register(
                        input: beanInfo.0,
                        tags: beanInfo.1.map { tags[$0] },
                        context: container.viewContext
                    )
                }
            let recipes = try await Recipe.presets
                .asyncMap { recipeInfo in
                    try await Recipe.register(
                        input: recipeInfo.0,
                        relation: .init(
                            tags: recipeInfo.2.map { tags[$0] } ,
                            equipments: recipeInfo.1.map { tags[$0] }
                        ),
                        context: container.viewContext
                    )
                }
            _ = try await Diary.presets
                .asyncMap { diaryInfo in
                    try await Diary.register(
                        input: diaryInfo.diary,
                        relation: .init(
                            bean: beans[diaryInfo.bean],
                            recipe: recipes[diaryInfo.recipe]
                        ),
                        context: container.viewContext
                    )
                }
        } catch {
            // Inmemory 레코드 생성에 실패 -> 테스트 불가이기 때문에 fatalError를 호출합니다
            fatalError(error.localizedDescription)
        }
    }
}
#endif
