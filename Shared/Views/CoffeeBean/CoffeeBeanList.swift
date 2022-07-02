//
//  CoffeeBeanListView.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/01.
//

import SwiftUI

struct CoffeeBeanList: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created)])
    private var beans: FetchedResults<CoffeeBean>

    var body: some View {
        NavigationView {
            List(beans, id: \.objectID) { bean in
                NavigationLink(destination: {
                    CoffeeBeanForm(bean)
                }, label: {
                    Text(bean.name ?? "")
                })
            }
            .navigationTitle("원두 목록")
            .toolbar(content: toolBar)
            // iPad NavigationView를 위한 Placeholder
            Text("원두 목록에서 원두를 선택하거나\n새로운 원두를 등록해주세요")
        }
    }
}

extension CoffeeBeanList {
    @ViewBuilder fileprivate func toolBar() -> some View {
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

struct CoffeeBeanList_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeBeanList()
    }
}
