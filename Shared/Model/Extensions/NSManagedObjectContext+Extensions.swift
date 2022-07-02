//
//  NSManagedObjectContext+Extensions.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/06/22.
//

import CoreData

protocol UUIDObject {
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

    func delete<T: UUIDObject>(_ elements: [T], entityName: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "id IN %@", elements.map { $0.id?.uuidString ?? "" })
        do {
            let results = (try fetch(request) as? [Tag]) ?? []
            results.forEach { delete($0) }
        } catch {
            print("Failed removing provided objects")
            return
        }
        saveContext()
    }
}
