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
        return Tag.Input(content: self.content ?? "", color: Color(rawValue: Int(self.color)) ?? .blue)
    }

    /// `Tag.Input`을 활용해서 새로운 원두를 등록합니다
    static func register(input: Tag.Input, context: NSManagedObjectContext) {
        let newTag = Tag(context: context)
        newTag.id = UUID()
        newTag.color = Int16(input.color.rawValue)
        newTag.content = input.content
        newTag.created = Date()
        context.saveContext()
    }

    /// Tag 엔티티를 삭제합니다.
    static func delete(tags: [Tag], context: NSManagedObjectContext) {
        context.delete(tags, entityName: "Tag")
    }
}

/// 초기 태그 데이터
extension Tag {
    static let presets: [Tag.Input] = [
        Tag.Input(content: "강배전", color: .gray),
        Tag.Input(content: "중배전", color: .gray),
        Tag.Input(content: "약배전", color: .gray),
        Tag.Input(content: "에티오피아", color: .blue),
        Tag.Input(content: "캐냐", color: .blue),
        Tag.Input(content: "브라질", color: .blue),
        Tag.Input(content: "하리오 V60", color: .red),
        Tag.Input(content: "오리가미 세라믹", color: .red)
    ]
}

extension Tag: UUIDObject {}

enum TagError: Error {
    case notExist
    case unexpected(Error)
}
