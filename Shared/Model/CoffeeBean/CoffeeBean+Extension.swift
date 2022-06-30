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
        var explanation: String = ""
        var image: Data?
    }

    static func register(input: Input, context: NSManagedObjectContext) {
        let newBean = CoffeeBean(context: context)
        newBean.id = UUID()
        newBean.name = input.name
        newBean.explanation = input.explanation
        newBean.created = Date()
        newBean.image = input.image
        context.saveContext()
    }

    static func delete(beans: [CoffeeBean], context: NSManagedObjectContext) {
        context.delete(beans)
    }

    static func addTagsToCoffeeBean(tags: [Tag], bean: CoffeeBean, context: NSManagedObjectContext) {
        for tag in tags {
            tag.addToBeans(bean)
        }
        context.saveContext()
    }

    var input: Input {
        return Input(name: name ?? "", explanation: explanation ?? "", image: image)
    }

    var tagArray: [Tag] {
        guard let tags = self.tags?.allObjects as? [Tag] else { return [] }
        return tags
    }
}
