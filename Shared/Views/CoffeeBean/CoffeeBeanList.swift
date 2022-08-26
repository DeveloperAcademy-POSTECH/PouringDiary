//
//  CoffeeBeanListView.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/01.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct CoffeeBeanList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var beans: FetchedResults<CoffeeBean>

    var body: some View {
        NavigationView {
            List {
                if beans.isEmpty {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("coffee-bean-list-empty")
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
        .analyticsScreen(name: "Coffee Bean List")
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
                    Text("추가")
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
