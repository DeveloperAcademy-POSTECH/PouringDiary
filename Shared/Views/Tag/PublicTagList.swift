//
//  PublicTagList.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/26.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct PublicTagList: View {

    @FetchRequest(sortDescriptors: [SortDescriptor(\.color)])
    private var presets: FetchedResults<PublicTag>

    var body: some View {
        VStack {
            Text("마음에 드는 태그를 길게 눌러 저장해주세요")
                .font(.caption)
            List {
                Section("장비") {
                    ForEach(presets.filter { $0.category == Tag.Category.equipment.rawValue }) { tag in
                        TagItem(tag: tag.tagInput)
                            .contextMenu {
                                Button {
                                    tag.saveToPrivate()
                                } label: {
                                    Label("저장", systemImage: "square.and.arrow.down")
                                }
                            }
                    }
                }
                Section("태그") {
                    ForEach(presets.filter { $0.category == Tag.Category.regular.rawValue }) { tag in
                        TagItem(tag: tag.tagInput)
                            .contextMenu {
                                Button {
                                    tag.saveToPrivate()
                                } label: {
                                    Label("저장", systemImage: "square.and.arrow.down")
                                }
                            }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .analyticsScreen(name: "Public Tag List")
    }
}

struct PublicTagList_Previews: PreviewProvider {
    static var previews: some View {
        PublicTagList()
    }
}
