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
        var title: String
        var information: String
        var steps: String
    }

    static func register(
        input: Input,
        tags: [Tag],
        equipments: [Tag],
        context: NSManagedObjectContext
    ) {
        let newRecipe = Recipe(context: context)
        newRecipe.id = UUID()
        newRecipe.created = Date()
        newRecipe.title = input.title
        newRecipe.information = input.information
        newRecipe.equipmentTags = NSSet(array: equipments)
        newRecipe.recipeTags = NSSet(array: tags)
        context.saveContext()
    }

    static func save(
        objectId: NSManagedObjectID,
        input: Input,
        tags: [Tag],
        equipments: [Tag],
        context: NSManagedObjectContext
    ) {
        guard let current = context.object(with: objectId) as? Recipe else { return }
        current.title = input.title
        current.information = input.information
        current.recipeTags = NSSet(array: tags)
        current.equipmentTags = NSSet(array: equipments)
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
        guard let tags = self.recipeTags?.allObjects as? [Tag] else { return [] }
        return tags
    }
}

extension Recipe: UUIDObject {  }
