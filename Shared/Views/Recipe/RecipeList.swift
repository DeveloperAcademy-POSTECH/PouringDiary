//
//  RecipeList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/05.
//

import SwiftUI

struct RecipeList: View {
    var body: some View {
        NavigationView {
            Text("NOT IMPLEMENTED")
                .navigationTitle("레시피 목록")
                .toolbar(content: toolbar)
        }
    }
}

// MARK: ViewBuiders
extension RecipeList {
    private func toolbar() -> some ToolbarContent {
        return ToolbarItem(placement: .automatic) {
            HStack {
                EditButton()
                NavigationLink(destination: {
                    RecipeForm()
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
    }
}

struct RecipeList_Previews: PreviewProvider {
    static var previews: some View {
        RecipeList()
            .modifier(AppEnvironment(inMemory: true))
    }
}
