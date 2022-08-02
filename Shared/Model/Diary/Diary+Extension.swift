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

    static func searchByText(query: String) -> NSPredicate {
        return NSPredicate(
            format: "coffeeBean.name CONTAINS[cd] %@ OR recipe.title CONTAINS[cd] %@",
            query,
            query
        )
    }

    static func searchByTag(tag: Tag?) -> NSPredicate? {
        if let tag = tag {
            let format = """
    coffeeBean.tags CONTAINS %@ || recipe.equipmentTags CONTAINS %@ || recipe.recipeTags CONTAINS %@
    """
            return NSPredicate(
                format: format,
                tag,
                tag,
                tag
            )
        }
        return nil
    }
}

extension Diary: UUIDObject { }

extension Diary {
    var extractionSum: Double {
        return flavorRecordArray
            .map { $0.extraction }
            .reduce(0) { $0 + $1 }
    }

    var strengthSum: Double {
        return flavorRecordArray
            .map { $0.strength }
            .reduce(0) { $0 + $1 }
    }
}

extension Diary.Input {
    var extractionSum: Double {
        return flavorRecords
            .map { $0.extraction }
            .reduce(0) { $0 + $1 }
    }

    var strengthSum: Double {
        return flavorRecords
            .map { $0.strength }
            .reduce(0) { $0 + $1 }
    }
}

#if DEBUG
extension Diary {
    static var presets: [Diary.Input] {
        return [
            .init(memo: "그라인더 15클릭으로 진행\n추출 완료까지 2분 12초", flavorRecords: [
                FlavorRecord(label: "텁텁한", strength: 0.4, extraction: 0.6),
                FlavorRecord(label: "드라이한", strength: 0.2, extraction: 0.8)
            ])
        ]
    }
}
#endif
