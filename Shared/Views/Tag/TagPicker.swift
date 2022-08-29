//
//  TagPicker.swift
//  PouringDiary
//
//  Created by devisaac on 2022/06/24.
//

import SwiftUI
import FirebaseAnalyticsSwift

/**
 `@Binding var selected: [Tag]`를 통해서 태그들을 선택해주는 컴포넌트입니다.
 */
struct TagPicker: View {
    // Variables /w property wrapper
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest
    private var allTags: FetchedResults<Tag>

    @State var searchQuery: String = ""
    @State var selectedColor: Tag.Color?
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
            sortDescriptors: Tag.sortByColor,
            predicate: Tag.searchPredicate(by: category)
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        selectedColor = nil
                    } label: {
                        Text("tag-picker-select-all")
                            .font(.caption2)
                    }
                    ForEach(Tag.Color.allCases, id: \.rawValue) { color in
                        Button(action: {
                            if selectedColor == color {
                                selectedColor = nil
                            } else {
                                selectedColor = color
                            }
                        }, label: {
                            Rectangle()
                                .fill(color.color.opacity(selectedColor == color ? 0.1 : 1.0))
                                .frame(width: 24, height: 24)
                                .cornerRadius(12)
                        })
                    }
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
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
                    if allTags.isEmpty {
                        publicTagSection
                    }
                    Section {
                        ForEach(
                            notSelected(),
                            id: \.objectID,
                            content: tagToggleButton
                        )
                        .onDelete { indexSet in
                            Task {
                                await deleteItems(indexSet: indexSet)
                            }
                        }
                    } header: {
                        Text("내 태그")
                            .font(.caption)
                    }
                    if !allTags.isEmpty {
                        publicTagSection
                    }
                }
                .searchable(
                    text: $searchQuery,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "태그를 검색해보세요"
                )
                .onChange(of: selectedColor) { color in
                    allTags.nsPredicate = Tag.searchPredicate(by: category, query: searchQuery, color: color)
                }
                .onChange(of: searchQuery) { search in
                    allTags.nsPredicate = Tag.searchPredicate(by: category, query: search, color: selectedColor)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {

                    EditButton()
                    NavigationLink(
                        isActive: $isTagFormShow,
                        destination: {
                            TagForm(with: $isTagFormShow, category: category)
                        },
                        label: {
                            Text("추가")
                        }
                    )
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .analyticsScreen(name: "Tag Picker")
        }
    }
}

// MARK: Views
extension TagPicker {
    @ViewBuilder
    private var publicTagSection: some View {
        Section {
            NavigationLink {
                PublicTagList()
            } label: {
                Text("준비된 태그를 다운로드 해보세요")
                    .font(.callout)
            }
        } header: {
            Text("프리셋")
                .font(.caption)
        } footer: {
            HStack {
                Spacer()
                Text("프리셋 태그와 함께 나만의 태그를 구성해보세요")
                    .font(.caption2)
            }
        }
    }

    // MARK: 태그 터치 시 토글을 수행하는 버튼
    @ViewBuilder
    private func tagToggleButton(tag: Tag) -> some View {
        TagItem(tag: tag.input)
            .onTapGesture {
                toggleItem(tag: tag)
            }
    }
}

// MARK: Actions
extension TagPicker {
    /// 색상별로 정렬된 아직 선택되지 않은 태그들
    private func notSelected() -> [Tag] {
        return allTags
            .filter { !selected.contains($0) }
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
    private func deleteItems(indexSet: IndexSet) async {
        let tags = indexSet.map { notSelected()[$0] }
        await Tag.delete(tags: tags, context: viewContext)
    }
}

struct TagPicker_Previews: PreviewProvider {
    static var previews: some View {
        TagPicker(with: .regular, selected: .constant([]))
            .modifier(AppEnvironment(inMemory: true))
    }
}
