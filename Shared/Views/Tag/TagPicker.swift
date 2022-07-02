//
//  TagPicker.swift
//  PouringDiary
//
//  Created by devisaac on 2022/06/24.
//

import SwiftUI

/**
 `@Binding var selected: [Tag]`를 통해서 태그들을 선택해주는 컴포넌트입니다.
 */
struct TagPicker: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Tag.color, ascending: true)
    ])
    private var allTags: FetchedResults<Tag>

    @State var searchQuery: String = ""
    @State var isTagFormShow: Bool = false
    @Binding var selected: [Tag]

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(
                            selected,
                            id: \.id,
                            content: tagToggleButton
                        )
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                List {
                    ForEach(
                        notSelected(),
                        id: \.objectID,
                        content: tagToggleButton
                    )
                    .onDelete(perform: deleteItems)
                }
                .searchable(
                    text: $searchQuery,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "태그를 검색해보세요"
                )
            }
            .toolbar {
                HStack {
                    EditButton()
                    NavigationLink(
                        isActive: $isTagFormShow,
                        destination: {
                            TagForm(isPresent: $isTagFormShow)
                        },
                        label: {
                            Image(systemName: "plus")
                        }
                    )
                }
            }
            .navigationTitle("태그 선택")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: ViewBuilders
extension TagPicker {
    // MARK: 태그 터치 시 토글을 수행하는 버튼
    @ViewBuilder
    private func tagToggleButton(tag: Tag) -> some View {
        Button(action: {
            toggleItem(tag: tag)
        }, label: {
            TagItem(tag: tag.input)
        })
    }

}

// MARK: Actions
extension TagPicker {
    /// 색상별로 정렬된 아직 선택되지 않은 태그들
    private func notSelected() -> [Tag] {
        return allTags
            .filter { !selected.contains($0) }
            .filter { $0.content?.contains(searchQuery) ?? false || searchQuery.isEmpty }
            .sorted { $0.color > $1.color }
    }

    /// 태그 선택을 위한 토글 액션
    private func toggleItem(tag: Tag) {
        if selected.contains(tag) {
            selected
                .removeAll { $0 == tag }
        } else {
            selected
                .append(tag)
        }
    }

    /// 선택된 인덱스들에 대한 태그 삭제
    private func deleteItems(indexSet: IndexSet) {
        let tags = indexSet.map { notSelected()[$0] }
        Tag.delete(tags: tags, context: viewContext)
    }

}

struct TagPicker_Previews: PreviewProvider {
    static var previews: some View {
        TagPicker(selected: .constant([]))
            .modifier(AppEnvironment(inMemory: true))
    }
}
