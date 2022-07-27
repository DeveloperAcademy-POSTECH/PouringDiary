//
//  CoffeeBean+Extension.swift
//  PouringDiary
//
//  Created by devisaac on 2022/06/23.
//

import CoreData

extension CoffeeBean {
    struct Input {
        var name: String = ""
        var information: String = ""
        var image: Data?
    }

    static func register(input: Input, tags: [Tag], context: NSManagedObjectContext) {
        let newBean = CoffeeBean(context: context)
        newBean.id = UUID()
        newBean.name = input.name
        newBean.information = input.information
        newBean.created = Date()
        newBean.image = input.image
        if !tags.isEmpty {
            newBean.tags = NSSet(array: tags)
        }
        context.saveContext()
    }

    static func save(objectId: NSManagedObjectID, input: Input, tags: [Tag], context: NSManagedObjectContext) {
        guard let current = context.object(with: objectId) as? CoffeeBean else { return }
        current.name = input.name
        current.information = input.information
        current.tags = NSSet(array: tags)
        context.saveContext()
    }

    static func delete(beans: [CoffeeBean], context: NSManagedObjectContext) {
        context.delete(beans)
    }

    static func get(by objectId: NSManagedObjectID, context: NSManagedObjectContext) -> CoffeeBean? {
        return context.get(by: objectId)
    }

    var input: Input {
        return Input(name: name ?? "", information: information ?? "", image: image)
    }

    var tagArray: [Tag] {
        guard let tags = self.tags?.allObjects as? [Tag] else { return [] }
        return tags
    }
}

extension CoffeeBean: UUIDObject { }

#if DEBUG
extension CoffeeBean {
    static var presets: [CoffeeBean.Input] {
        return [
            .init(name: "Flavor Blend", information: "우리동네 맛집 카페 대표 원두", image: nil)
        ]
    }
}
#endif
