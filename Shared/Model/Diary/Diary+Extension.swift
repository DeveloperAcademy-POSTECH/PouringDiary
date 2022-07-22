//
//  Diary+Extension.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/11.
//

import Foundation
import CoreData
import SwiftUI

extension Diary {
    struct Input {
        var memo: String
        var flavorRecords: [FlavorRecord]
    }

    struct RelationInput {
        var bean: CoffeeBean
        var recipe: Recipe
    }

    static func register(
        input: Input,
        relation: RelationInput,
        context: NSManagedObjectContext
    ) {
        let encoder = JSONEncoder()
        guard let recordData = try? encoder.encode(input.flavorRecords) else { return }
        let newDiary = Diary(context: context)
        newDiary.id = UUID()
        newDiary.created = Date()
        newDiary.memo = input.memo
        newDiary.flavorRecords = recordData
        newDiary.recipe = relation.recipe
        newDiary.coffeeBean = relation.bean
        context.saveContext()
    }

    static func save(
        objectId: NSManagedObjectID,
        input: Input,
        relation: RelationInput,
        context: NSManagedObjectContext
    ) {
        let encoder = JSONEncoder()
        guard let current = context.object(with: objectId) as? Diary else { return }
        guard let recordData = try? encoder.encode(input.flavorRecords) else { return }
        current.memo = input.memo
        current.flavorRecords = recordData
        current.recipe = relation.recipe
        current.coffeeBean = relation.bean
        context.saveContext()
    }

    static func delete(diaries: [Diary], context: NSManagedObjectContext) {
        context.delete(diaries)
    }

    static func get(by objectId: NSManagedObjectID, context: NSManagedObjectContext) -> Diary? {
        return context.get(by: objectId)
    }

    var input: Input {
        return Input(memo: memo ?? "", flavorRecords: flavorRecordArray)
    }

    var flavorRecordArray: [FlavorRecord] {
        let decoder = JSONDecoder()
        guard let recordData = flavorRecords else { return [] }
        guard let decoded = try? decoder.decode([FlavorRecord].self, from: recordData) else { return [] }
        return decoded
    }
}

// MARK: Requests
extension Diary {
    static func requestSameSourceDiary(recipe: Recipe? = nil, bean: CoffeeBean? = nil) -> NSFetchRequest<Diary> {
        let request = Diary.fetchRequest()
        if let recipe = recipe, let bean = bean {
            request.predicate = NSPredicate(
                format: "recipe == %@ AND coffeeBean == %@",
                recipe,
                bean
            )
        } else {

            request.predicate = NSPredicate(format: "id == %@", UUID().uuidString)
        }
        request.sortDescriptors = [NSSortDescriptor(SortDescriptor<Diary>(\.created, order: .reverse))]
        return request
    }
}

extension Diary: UUIDObject { }
