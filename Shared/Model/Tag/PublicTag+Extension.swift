//
//  PublicTag+Extension.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/23.
//

import Foundation
import CloudKit
import CoreData

extension PublicTag {
    func saveToPrivate() {
        Tag.register(
            input: tagInput,
            context: managedObjectContext!
        )
    }

    var tagInput: Tag.Input {
        return Tag.Input(
            content: content ?? "",
            color: Tag.Color(rawValue: Int(color))!,
            category: Tag.Category(from: category)
        )
    }
}
