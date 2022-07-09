//
//  NSManagedObjectContext+Extensions.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/06/22.
//

import CoreData

protocol UUIDObject: NSManagedObject {
    var id: UUID? { get }
}

extension NSManagedObjectContext {
    func saveContext() {
        do {
            try save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    /**
     * Object를 삭제하기 위한 함수입니다. Discussion 항목 필독.
     * - [⚠️ 중요 ⚠️]이 함수는 NSManagedObject의 extension에서만 사용해야 합니다. View에서는 각 엔티티에서 선언되어 있는 삭제 함수를 사용해서 삭제를 구현해주세요
     */
    func delete<T: UUIDObject>(_ elements: [T]) {
        guard let entityName = T.entity().name else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "id IN %@", elements.map { $0.id?.uuidString ?? "" })
        do {
            let results = (try fetch(request) as? [T]) ?? []
            results.forEach { delete($0) }
        } catch {
            print("Failed removing provided objects")
            return
        }
        saveContext()
    }

    func get<T: NSManagedObject>(by objectId: NSManagedObjectID) -> T? {
        do {
            guard let result = try self.existingObject(with: objectId) as? T else { return nil }
            return result
        } catch {
            return nil
        }
    }
}
