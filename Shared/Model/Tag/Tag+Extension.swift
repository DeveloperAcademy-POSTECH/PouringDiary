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

    /// 태그 생성 및 수정에 사용합니다.
    public struct Input {
        var content: String
        var color: Color
        var category: Category = .regular
    }

    public enum Category: Int, CaseIterable {
        case regular
        case equipment
        case notSelected

        init(from int16: Int16) {
            switch int16 {
            case Int16(Category.regular.rawValue):
                self = .regular
            case Int16(Category.equipment.rawValue):
                self = .equipment
            default:
                self = .notSelected
            }
        }
    }

    /// 태그의 색상 리스트를 관리합니다.
    /// Color의 rawValue를 활용해서 CoreData에 저장합니다
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

    /// SwiftUI에서 사용하는 Color를 반환합니다
    public var suColor: SwiftUI.Color {
        guard let color = Tag.Color(rawValue: Int(self.color))?.color else { return .clear }
        return color
    }

    public var input: Tag.Input {
        return Tag.Input(
            content: self.content ?? "",
            color: Color(rawValue: Int(self.color)) ?? .blue,
            category: Category(from: self.category)
        )
    }

    /// `Tag.Input`을 활용해서 새로운 태그를 등록합니다
    static func register(input: Tag.Input, context: NSManagedObjectContext) {
        context.perform {
            let newTag = Tag(context: context)
            newTag.id = UUID()
            newTag.color = Int16(input.color.rawValue)
            newTag.content = input.content
            newTag.created = Date()
            newTag.category = Int16(input.category.rawValue)
            context.saveContext()
        }
    }

    /// Tag 엔티티를 삭제합니다.
    static func delete(tags: [Tag], context: NSManagedObjectContext) {
        context.delete(tags)
    }
}

// MARK: Requests
extension Tag {
    static var sortByColor: [SortDescriptor<Tag>] {
        return [
            SortDescriptor(\.color, order: .reverse)
        ]
    }
    static func searchPredicate(by category: Category, query: String? = nil, color: Color? = nil) -> NSPredicate? {
        if let queryTrimmed = query?.trimmingCharacters(in: .whitespacesAndNewlines), !queryTrimmed.isEmpty {
            // Query가 유효한 경우
            if let color = color {
                return NSPredicate(
                    format: "category == %i && content CONTAINS %@ && color == %i",
                    category.rawValue,
                    queryTrimmed,
                    color.rawValue
                )
            }
            print(queryTrimmed)
            return NSPredicate(format: "category == %i && content CONTAINS %@", category.rawValue, queryTrimmed)
        } else {
            if let color = color {
                return NSPredicate(format: "category == %i && color == %i", category.rawValue, color.rawValue)
            }
            return NSPredicate(format: "category == %i", category.rawValue)
        }
    }
}

extension Tag: UUIDObject {}

enum TagError: Error {
    case notExist
    case unexpected(Error)
}

#if DEBUG
extension Tag {
    static var presets: [Tag.Input] = [
        .init(content: "에티오피아", color: .blue),
        .init(content: "브라질", color: .blue),
        .init(content: "과테말라", color: .blue),
        .init(content: "캐냐", color: .blue),

        .init(content: "Natural", color: .pink),
        .init(content: "Washed", color: .pink),

        .init(content: "강배전", color: .gray),
        .init(content: "중배전", color: .gray),
        .init(content: "약배전", color: .gray),

        .init(content: "코만단테", color: .purple, category: .equipment),
        .init(content: "바라짜 앤코", color: .purple, category: .equipment),
        .init(content: "EK43", color: .purple, category: .equipment),

        .init(content: "하리오 V60", color: .red, category: .equipment),
        .init(content: "블루보틀", color: .red, category: .equipment),
    ]
}
#endif
