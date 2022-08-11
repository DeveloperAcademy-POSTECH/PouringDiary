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

    static func register(input: Input, tags: [Tag], context: NSManagedObjectContext) async throws -> CoffeeBean {
        do {
            let newBean = CoffeeBean(context: context)
            try await context.perform(schedule: .immediate) {
                newBean.id = UUID()
                newBean.name = input.name
                newBean.information = input.information
                newBean.created = Date()
                newBean.image = input.image
                if !tags.isEmpty {
                    newBean.tags = NSSet(array: tags)
                }
                try context.save()
            }
            return newBean
        } catch {
            throw error
        }
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
    // 레시피 / 태그 인덱스로 이루어진 프레셋 생성용 타입
    typealias PresetInput = (CoffeeBean.Input, IndexSet)
    static var presets: [PresetInput] {
        return [
            (
                .init(name: "그 카페 블렌드", information: "우리동네 맛집 카페 대표 원두", image: nil),
                IndexSet([0, 1, 4, 6])
            ),
            (
                .init(name: "이 카페 브라질", information: "우리동네 맛집 카페 대표 원두", image: nil),
                IndexSet([2, 5, 7])
            ),
            (
                .init(name: "저 카페 캐냐", information: "우리동네 맛집 카페 대표 원두", image: nil),
                IndexSet([3, 5, 8])
            ),
        ]
    }
}
#endif
