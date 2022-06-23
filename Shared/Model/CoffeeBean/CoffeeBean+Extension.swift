//
//  CoffeeBean+Extension.swift
//  PouringDiary
//
//  Created by devisaac on 2022/06/23.
//

import CoreData

extension CoffeeBean {
    struct Input {
        let name: String
        let explanation: String
    }

    static func register(input: Input, context: NSManagedObjectContext) {
        do {
            let newBean = CoffeeBean(context: context)
            newBean.id = UUID()
            newBean.name = input.name
            newBean.explanation = input.explanation
            newBean.created = Date()
            try context.save()
        } catch {

        }
    }

    static func delete(beans: [CoffeeBean], context: NSManagedObjectContext) {
        context.delete(beans)
    }
}
