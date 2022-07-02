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
        List(beans, id: \.objectID) { bean in
            NavigationLink(destination: {
                CoffeeBeanForm(bean)
            }, label: {
                Text(bean.name ?? "")
            })
        }
    }
}

struct CoffeeBeanList_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeBeanList()
    }
}
