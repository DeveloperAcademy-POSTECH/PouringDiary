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
    // Variables /w property wrapper
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var allTags: FetchedResults<Tag>
    @State var searchQuery: String = ""
    @State var isTagFormShow: Bool = false
    @Binding var selected: [Tag]

    // Internal variables & getters
    var category: Tag.Category
    private var navigationTitle: LocalizedStringKey {
        switch category {
        case .regular:
            return "태그 선택"
        case .equipment:
            return "장비 선택"
        case .notSelected:
            return ""
        }
    }

    // Initializers
    init(with category: Tag.Category, selected: Binding<[Tag]>) {
        self.category = category
        self._selected = selected
        self._allTags = FetchRequest(
            sortDescriptors: [SortDescriptor(\.color, order: .reverse)],
            predicate: NSPredicate(format: "category == %i", category.rawValue)
        )
    }

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
            .toolbar(content: toolbar)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: Views
extension TagPicker {
    // MARK: 태그 터치 시 토글을 수행하는 버튼
    @ViewBuilder
    private func tagToggleButton(tag: Tag) -> some View {
        TagItem(tag: tag.input)
            .onTapGesture {
                toggleItem(tag: tag)
            }
    }

    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            HStack {
                EditButton()
                NavigationLink(
                    isActive: $isTagFormShow,
                    destination: {
                        TagForm(with: $isTagFormShow, category: category)
                    },
                    label: {
                        Image(systemName: "plus")
                    }
                )
            }
        }
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
        TagPicker(with: .regular, selected: .constant([]))
            .modifier(AppEnvironment(inMemory: true))
    }
}
