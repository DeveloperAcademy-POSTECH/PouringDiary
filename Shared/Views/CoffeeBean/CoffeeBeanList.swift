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
                ForEach(beans, id: \.objectID) { bean in
                    NavigationLink(destination: {
                        CoffeeBeanForm(bean)
                    }, label: {
                        Text(bean.name ?? "")
                    })
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("원두 목록")
            .toolbar(content: toolBar)
            // iPad NavigationView를 위한 Placeholder
            Text("원두 목록에서 원두를 선택하거나\n새로운 원두를 등록해주세요")
        }
    }
}

// MARK: Actions
extension CoffeeBeanList {
    private func delete(_ indexSet: IndexSet) {
        let deletions = indexSet.map { beans[$0] }
        CoffeeBean.delete(beans: deletions, context: viewContext)
    }
}

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
