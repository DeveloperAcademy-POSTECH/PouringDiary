//
//  NSManagedObjectContext+Extensions.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/06/22.
//

import CoreData

extension NSManagedObjectContext {
    func saveContext() {
        do {
            try save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    func delete(_ tags: [Tag]) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        request.predicate = NSPredicate(format: "id IN %@", tags.map { $0.id.uuidString })
        do {
            let results = (try fetch(request) as? [Tag]) ?? []
            results.forEach { delete($0) }
        } catch {
            print("Failed removing provided objects")
            return
        }
        saveContext()
    }

    func delete(_ beans: [CoffeeBean]) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoffeeBean")
        request.predicate = NSPredicate(format: "id IN %@", beans.map { $0.id!.uuidString })
        do {
            let results = (try fetch(request) as? [Tag]) ?? []
            results.forEach { delete($0) }
        } catch {
            print("Failed removing provided objects")
            return
        }
    }
}
