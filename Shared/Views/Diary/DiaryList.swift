//
//  DiaryList.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/12.
//

import SwiftUI
import CoreData
import FirebaseAnalyticsSwift

struct DiaryList: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var diaries: FetchedResults<Diary>

    @FetchRequest(sortDescriptors: [SortDescriptor(\.color)])
    private var allTags: FetchedResults<Tag>

    @State private var detailViewShow: Bool = false
    @State private var searchQuery: String = ""
    @State private var searchTags: [Tag] = []

    @State private var diaryId: NSManagedObjectID?
    @State var shareFormShow: Bool = false

    var body: some View {
        NavigationView {
            List {
                tagSearchSection
                emptyResultSection
                searchedTagsSection
                diaryList
            }
            .onChange(of: diaryId) { _ in
                shareFormShow.toggle()
            }
            .sheet(isPresented: $shareFormShow) {
                SharePostForm(diaryId: diaryId!)
            }
            .toolbar(content: toolbarTrailing)
            .navigationTitle("일지 목록")
        }
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "diary-list-searchbar-placeholder"
        )
        .keyboardType(.twitter)
        .onChange(of: searchQuery) { query in
            if !query.isEmpty {
                if query.first == "#" {
                    let content = query.replacingOccurrences(of: "#", with: "")
                    allTags.nsPredicate = Tag.searchPredicate(by: content)
                } else {
                    diaries.nsPredicate = Diary.searchByText(query: query)
                }
            } else {
                diaries.nsPredicate = Diary.searchByTag(tags: searchTags)
                allTags.nsPredicate = nil
            }
        }
        .onChange(of: searchTags) { tags in
            diaries.nsPredicate = Diary.searchByTag(tags: tags)
        }
        .navigationViewStyle(.stack)
        .navigationBarTitleDisplayMode(.inline)
        .analyticsScreen(name: "Diary List")
    }
}

// MARK: Views
extension DiaryList {
    private struct DiaryCard: View {
        @ObservedObject var diary: Diary

        @State var copiedFormShow: Bool = false
        @Binding var shareFormShow: Bool
        @Binding var diaryId: NSManagedObjectID?

        var body: some View {
            NavigationLink(
                destination: {
                    DiaryForm(with: diary.objectID)
                }, label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Spacer()
                            Text(diary.created?.monthAndDate ?? "")
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6))
                        Text("\(diary.coffeeBean?.name ?? "") ☕️")
                            .font(.headline)
                            .padding(.bottom, 2)

                        Text("\(String.init(localized: "레시피").uppercased()) - \(diary.recipe?.title ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        NavigationLink(
                            isActive: $copiedFormShow,
                            destination: { DiaryForm(recipe: diary.recipe, bean: diary.coffeeBean) },
                            label: { EmptyView() }
                        )
                        .hidden()
                    }
                    .contextMenu {
                        Button {
                            copiedFormShow.toggle()
                        } label: {
                            Label("복제", systemImage: "doc.on.doc")
                        }
                        Button {
                            diaryId = diary.objectID
                        } label: {
                            Label("share-context-menu", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            )
            .listRowSeparatorTint(.accentColor)
        }
    }

    private func toolbarTrailing() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
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
    private var tagSearchSection: some View {
        if searchQuery.starts(with: "#") {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(allTags) { tag in
                        if !searchTags.contains(tag) {
                            Button {
                                searchTags.append(tag)
                            } label: {
                                TagItem(tag: tag.input)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var emptyResultSection: some View {
        if diaries.isEmpty {
            if searchTags.isEmpty && searchQuery.isEmpty {
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
    private var searchedTagsSection: some View {
        if !searchTags.isEmpty {
            Section {
                ViewThatFits {
                    HStack {
                        ForEach(searchTags) { tag in
                            Button {
                                searchTags.remove(at: searchTags.firstIndex(of: tag)!)
                            } label: {
                                TagItem(tag: tag.input)
                            }
                        }
                    }
                }
            } header: {
                Text("다음 태그를 포함")
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var diaryList: some View {
        ForEach(diaries, id: \.id) { diary in
            DiaryCard(
                diary: diary,
                shareFormShow: $shareFormShow,
                diaryId: $diaryId
            )
        }
        .onDelete(perform: deleteDiaries)
    }
}

// MARK: Actions
extension DiaryList {
    private func deleteDiaries(indexSet: IndexSet) {
        let deletions = indexSet
            .map { diaries[$0] }
        Diary.delete(diaries: deletions, context: viewContext)
    }
}

struct DiaryList_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            DiaryList()
        }
        .modifier(AppEnvironment(inMemory: true))
    }
}
