//
//  TagItem.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/06/24.
//

import SwiftUI

/// 각각의 태그를 표현하기 위한 뷰.
/// 별도의 액션을 담고있지 않습니다.
struct TagItem: View {
    let tag: Tag.Input
    var body: some View {
        Text("#\(tag.content)")
            .padding(6)
            .font(.caption)
            .foregroundColor(Color.white)
            .background(tag.color.color)
            .cornerRadius(8)
    }
}

struct TagItem_Previews: PreviewProvider {
    static var previews: some View {
        return TagItem(tag: Tag.Input(content: "샘플 태그", color: .red))
    }
}
