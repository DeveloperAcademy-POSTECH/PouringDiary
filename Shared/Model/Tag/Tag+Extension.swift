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
        case tag1
        case tag2
        case tag3
        case tag4
        case tag5
        case tag6
        case tag7

        // https://etsy.me/3ONBGOs 참조하여 컬러셋 구성
        var color: SUColor {
            switch self {
            case .tag1:
                return SUColor(hex: 0xF2D8BE)
            case .tag2:
                return SUColor(hex: 0xD3CABF)
            case .tag3:
                return SUColor(hex: 0xE5CBC2)
            case .tag4:
                return SUColor(hex: 0xD6AA8B)
            case .tag5:
                return SUColor(hex: 0xA97452)
            case .tag6:
                return SUColor(hex: 0x919D95)
            case .tag7:
                return SUColor(hex: 0x46536C)
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
            color: Color(rawValue: Int(self.color)) ?? .tag1,
            category: Category(from: self.category)
        )
    }

    /// `Tag.Input`을 활용해서 새로운 태그를 등록합니다

    static func register(input: Tag.Input, context: NSManagedObjectContext) async throws -> Tag {
        do {
            let newTag = Tag(context: context)
            try await context.perform(schedule: .immediate) {
                newTag.id = UUID()
                newTag.color = Int16(input.color.rawValue)
                newTag.content = input.content
                newTag.created = Date()
                newTag.category = Int16(input.category.rawValue)
                try context.save()
            }
            return newTag
        } catch {
            throw error
        }
    }

    /// Tag 엔티티를 삭제합니다.
    static func delete(tags: [Tag], context: NSManagedObjectContext) async {
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
            return NSPredicate(format: "category == %i && content CONTAINS %@", category.rawValue, queryTrimmed)
        } else {
            if let color = color {
                return NSPredicate(format: "category == %i && color == %i", category.rawValue, color.rawValue)
            }
            return NSPredicate(format: "category == %i", category.rawValue)
        }
    }
    static func searchPredicate(by query: String) -> NSPredicate? {
        let queryTrimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !queryTrimmed.isEmpty {
            return NSPredicate(format: "content CONTAINS %@", queryTrimmed)
        } else {
            return nil
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
        .init(content: "에티오피아", color: .tag1),
        .init(content: "브라질", color: .tag1),
        .init(content: "과테말라", color: .tag1),
        .init(content: "캐냐", color: .tag1),

        .init(content: "Natural", color: .tag2),
        .init(content: "Washed", color: .tag2),

        .init(content: "강배전", color: .tag3),
        .init(content: "중배전", color: .tag3),
        .init(content: "약배전", color: .tag3),

        .init(content: "핫", color: .tag6),
        .init(content: "이이스", color: .tag6),

        .init(content: "코만단테", color: .tag4, category: .equipment),
        .init(content: "바라짜 앤코", color: .tag4, category: .equipment),
        .init(content: "EK43", color: .tag4, category: .equipment),

        .init(content: "하리오 V60", color: .tag5, category: .equipment),
        .init(content: "블루보틀", color: .tag5, category: .equipment)
    ]
}
#endif
