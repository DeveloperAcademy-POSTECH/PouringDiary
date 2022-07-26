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

    @State private var detailViewShow: Bool = false

    var body: some View {
        NavigationView {
            List {
                if diaries.isEmpty {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("아직 작성된 일지가 없습니다.\n원두와 레시피를 등록하신 뒤에\n일지 작성이 가능합니다")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                }
                ForEach(diaries, id: \.id) { diary in
                    DiaryCard(diary: diary)
                }
                .onDelete(perform: deleteDiaries)
            }
            .toolbar(content: toolbar)
            .navigationTitle("일지 목록")
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
                    Image(systemName: "plus")
                })
            }
        }
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
