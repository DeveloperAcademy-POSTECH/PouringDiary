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
    ) async throws -> Diary {
        let newDiary = Diary(context: context)
        do {
            let encoder = JSONEncoder()
            let recordData = try encoder.encode(input.flavorRecords)

            newDiary.id = UUID()
            newDiary.created = Date()
            newDiary.memo = input.memo
            newDiary.flavorRecords = recordData
            newDiary.recipe = relation.recipe
            newDiary.coffeeBean = relation.bean
            try context.save()
        } catch {
            throw error
        }
        return newDiary
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

    static func searchByTag(tags: [Tag]) -> NSPredicate? {
        if !tags.isEmpty {
            let predicates: [NSPredicate] = tags.map { tag in
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
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
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
    // DiaryInput / 원두 인덱스 / 레시피 인덱스 순
    typealias PresetInput = (diary: Diary.Input, bean: Int, recipe: Int)
    static var presets: [PresetInput] {
        return [
            (
                .init(memo: "그라인더 15클릭으로 진행\n추출 완료까지 2분 12초", flavorRecords: [
                    FlavorRecord(label: "flavor-record-sparse", strength: -0.7, extraction: -0.3),
                    FlavorRecord(label: "flavor-record-watery", strength: -0.5, extraction: -0.5)
                ]),
                0,
                1
            ),
            (
                .init(memo: "그라인더 13클릭으로 진행\n추출 완료까지 2분 30초", flavorRecords: [
                    FlavorRecord(label: "flavor-record-powdary", strength: -0.1, extraction: 0.9)
                ]),
                0,
                1
            ),
            (
                .init(memo: "그라인더 11클릭으로 진행\n추출 완료까지 2분\n제일 잘 내려진 것 같다", flavorRecords: [
                    FlavorRecord(label: "텁텁한", strength: 0.4, extraction: 0.6),
                    FlavorRecord(label: "드라이한", strength: 0.2, extraction: 0.8)
                ]),
                1,
                0
            ),
            (
                .init(memo: "이 원두로 첫 추출\n 유튜브로 봤던 레시피 도전\n그라인더 15클릭으로 추출 진행 \n 1차에 20g 더 부어버림 ㅠ_ㅠ", flavorRecords: []),
                2,
                0
            )
        ]
    }
}
#endif
