//
//  TagManager.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/06/15.
//

import Foundation
import CoreData
import SwiftUI

extension Tag {
    typealias SUColor = SwiftUI.Color

    public struct Input {
        let content: String
        let color: Color
    }

    public enum Color: Int, CaseIterable {
        case red
        case gray
        case green
        case pink
        case blue
        case purple

        var color: SUColor {
            switch self {
            case .red:
                return .red
            case .gray:
                return .gray
            case .green:
                return .green
            case .pink:
                return .pink
            case .blue:
                return .blue
            case .purple:
                return .purple
            }
        }
    }

    public var suColor: SwiftUI.Color {
        guard let color = Tag.Color(rawValue: Int(self.color))?.color else { return .clear }
        return color
    }

    static func register(input: Tag.Input, context: NSManagedObjectContext) {
        let newTag = Tag(context: context)
        newTag.id = UUID()
        newTag.color = Int16(input.color.rawValue)
        newTag.content = input.content
        newTag.created = Date()
        context.saveContext()
    }

    static func delete(tags: [Tag], context: NSManagedObjectContext) {
        context.delete(tags)
    }
}

enum TagError: Error {
    case notExist
    case unexpected(Error)
}
