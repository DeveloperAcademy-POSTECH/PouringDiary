//
//  Recipe+Extension.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/05.
//

import Foundation
import CoreData

extension Recipe {
    struct Input {
        var title: String = ""
        var information: String = ""
        var steps: String = ""
    }

    struct RelationInput {
        var tags: [Tag]
        var equipments: [Tag]
    }

    static func register(
        input: Input,
        relation: RelationInput,
        context: NSManagedObjectContext
    ) {
        let newRecipe = Recipe(context: context)
        newRecipe.id = UUID()
        newRecipe.created = Date()
        newRecipe.title = input.title
        newRecipe.steps = input.steps
        newRecipe.information = input.information
        newRecipe.equipmentTags = NSSet(array: relation.equipments)
        newRecipe.recipeTags = NSSet(array: relation.tags)
        context.saveContext()
    }

    static func save(
        objectId: NSManagedObjectID,
        input: Input,
        relation: RelationInput,
        context: NSManagedObjectContext
    ) {
        guard let current = context.object(with: objectId) as? Recipe else { return }
        current.title = input.title
        current.information = input.information
        current.steps = input.steps
        current.recipeTags = NSSet(array: relation.tags)
        current.equipmentTags = NSSet(array: relation.equipments)
        context.saveContext()
    }

    static func delete(recipes: [Recipe], context: NSManagedObjectContext) {
        context.delete(recipes)
    }

    static func get(by objectId: NSManagedObjectID, context: NSManagedObjectContext) -> Recipe? {
        return context.get(by: objectId)
    }

    var input: Input {
        return Input(title: title ?? "", information: information ?? "", steps: steps ?? "")
    }

    var tagArray: [Tag] {
        guard let tags = self.recipeTags?.allObjects as? [Tag] else { return [] }
        return tags
    }

    var equipmentArray: [Tag] {
        guard let tags = self.equipmentTags?.allObjects as? [Tag] else { return [] }
        return tags
    }
}

extension Recipe: UUIDObject {  }

#if DEBUG
extension Recipe {
    static var presets: [Recipe.Input] {
        return [
            .init(
                title: "아이스 레시피",
                information: "동네 카페에서 배워온 레시피",
                steps:
"""
도징 16.5g
물 92도

1차 : 30g 1분 뜸들이기
2차 : 125g 빠르게 푸어링
총 2.5~3분으로 추출 종료
"""
            )
        ]
    }
}
#endif
