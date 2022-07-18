//
//  CoffeeBeanListView.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/01.
//

import SwiftUI

struct CoffeeBeanList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created)])
    private var beans: FetchedResults<CoffeeBean>

    var body: some View {
        NavigationView {
            List {
                if beans.isEmpty {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("아직 등록된 원두가 없습니다")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                }
                ForEach(beans, id: \.objectID) { bean in
                    NavigationLink(destination: {
                        CoffeeBeanForm(bean.objectID)
                    }, label: {
                        VStack(alignment: .leading) {
                            Text(bean.name ?? "")
                                .font(.headline)
                            HStack {
                                ForEach(bean.tagArray) { tag in
                                    TagItem(tag: tag.input)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    })
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("원두 목록")
            .toolbar(content: toolBar)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: Actions
extension CoffeeBeanList {
    private func delete(_ indexSet: IndexSet) {
        let deletions = indexSet.map { beans[$0] }
        CoffeeBean.delete(beans: deletions, context: viewContext)
    }
}

// MARK: Views
extension CoffeeBeanList {
    private func toolBar() -> some ToolbarContent {
        return ToolbarItem(placement: .automatic) {
            HStack {
                EditButton()
                NavigationLink(destination: {
                    CoffeeBeanForm()
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
    }
}

struct CoffeeBeanList_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeBeanList()
    }
}
