//
//  Tag+CoreDataProperties.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/06/15.
//
//

import Foundation
import CoreData

extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: UUID
    @NSManaged public var color: Int16
    @NSManaged public var created: Date
    @NSManaged public var content: String?
    @NSManaged public var beans: NSSet?
}

// MARK: Generated accessors for beans
extension Tag {

    @objc(addBeansObject:)
    @NSManaged public func addToBeans(_ value: CoffeeBean)

    @objc(removeBeansObject:)
    @NSManaged public func removeFromBeans(_ value: CoffeeBean)

    @objc(addBeans:)
    @NSManaged public func addToBeans(_ values: NSSet)

    @objc(removeBeans:)
    @NSManaged public func removeFromBeans(_ values: NSSet)

}

extension Tag: Identifiable { }
