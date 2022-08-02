//
//  DiaryList.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/12.
//

import SwiftUI

struct DiaryList: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var diaries: FetchedResults<Diary>

    @FetchRequest(sortDescriptors: [SortDescriptor(\.color)])
    private var allTags: FetchedResults<Tag>

    @State private var detailViewShow: Bool = false
    @State private var searchQuery: String = ""
    @State private var searchTag: Tag?

    var body: some View {
        NavigationView {
            List {
                if searchQuery.first == "#" {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(allTags) { tag in
                                Button {
                                    searchTag = tag
                                } label: {
                                    TagItem(tag: tag.input)
                                }
                            }
                        }
                    }
                }
                emptyResultSection
                searchTagSection
                diaryList
            }
            .toolbar(content: toolbar)
            .navigationTitle("일지 목록")
        }
        .searchable(text: $searchQuery)
        .onChange(of: searchQuery) { query in
            if !query.isEmpty {
                if query.first == "#" {
                    let content = query.replacingOccurrences(of: "#", with: "")
                    allTags.nsPredicate = Tag.searchPredicate(by: content)
                } else {
                    diaries.nsPredicate = Diary.searchByText(query: query)
                }
            } else {
                diaries.nsPredicate = Diary.searchByTag(tag: searchTag)
                allTags.nsPredicate = nil
            }
        }
        .onChange(of: searchTag) { tag in
            diaries.nsPredicate = Diary.searchByTag(tag: tag)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: Views
extension DiaryList {
    private struct DiaryCard: View {
        @ObservedObject var diary: Diary

        @State var copiedFormShow: Bool = false

        var body: some View {
            NavigationLink(
                destination: {
                    DiaryForm(with: diary.objectID)
                }, label: {
                    HStack(alignment: .center) {
                        VStack {
                            Text(diary.created?.simpleYear ?? "")
                                .frame(minWidth: 40)
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                            Text(diary.created?.monthAndDate ?? "")
                                .frame(minWidth: 40)
                                .font(.title2)
                            Text(diary.created?.simpleTime ?? "")
                                .frame(minWidth: 40)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6))
                        Divider()
                            .background(Color.accentColor)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("📝 \(diary.recipe?.title ?? "")")
                                .font(.headline)
                            Text("\(diary.coffeeBean?.name ?? "") ☕️")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            NavigationLink(
                                isActive: $copiedFormShow,
                                destination: { DiaryForm(recipe: diary.recipe, bean: diary.coffeeBean) },
                                label: { EmptyView() }
                            )
                            .hidden()
                        }
                        .padding()
                    }
                    .contextMenu {
                        Button {
                            copiedFormShow.toggle()
                        } label: {
                            Label("복제", systemImage: "doc.on.doc")
                        }
                    }
                    .padding(4)
                }
            )
            .listRowSeparatorTint(.accentColor)
        }
    }

    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            HStack {
                EditButton()
                NavigationLink(destination: {
                    DiaryForm()
                }, label: {
                    Text("추가")
                })
            }
        }
    }

    @ViewBuilder
    private var emptyResultSection: some View {
        if diaries.isEmpty {
            if searchTag == nil && searchQuery.isEmpty {
                HStack(alignment: .center) {
                    Spacer()
                    Text("아직 작성된 일지가 없습니다.\n원두와 레시피를 등록하신 뒤에\n일지 작성이 가능합니다")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
            } else {
                HStack(alignment: .center) {
                    Spacer()
                    Text("검색 결과가 없습니다")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private var searchTagSection: some View {
        if let tag = searchTag {
            Section {
                HStack {
                    Button {
                        searchTag = nil
                    } label: {
                        TagItem(tag: tag.input)
                    }
                    Spacer()
                }
            } header: {
                Text("다음 태그를 포함")
                    .font(.caption)
            } footer: {
                HStack {
                    Spacer()
                    Text("태그 검색은 1개의 태그로만 가능합니다.")
                        .font(.caption2)
                }
            }
        }
    }

    @ViewBuilder
    private var diaryList: some View {
        ForEach(diaries, id: \.id) { diary in
            DiaryCard(diary: diary)
        }
        .onDelete(perform: deleteDiaries)
    }
}

// MARK: Actions
extension DiaryList {
    @Sendable
    private func deleteDiaries(indexSet: IndexSet) {
        let deletions = indexSet
            .map { diaries[$0] }
        Diary.delete(diaries: deletions, context: viewContext)
    }
}

struct DiaryList_Previews: PreviewProvider {
    static var previews: some View {
        DiaryList()
    }
}
