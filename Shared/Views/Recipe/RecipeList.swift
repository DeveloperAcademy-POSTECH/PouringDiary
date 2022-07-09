//
//  RecipeList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/05.
//

import SwiftUI

struct RecipeList: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created)])
    private var recipes: FetchedResults<Recipe>

    var body: some View {
        NavigationView {
            List {
                ForEach(recipes, id: \.id) { recipe in
                    NavigationLink(destination: {
                        RecipeForm(recipe.objectID)
                    }, label: {
                        Text(recipe.title ?? "")
                    })
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("레시피 목록")
            .toolbar(content: toolbar)
            // iPad NavigationView를 위한 Placeholder
            Text("레시피 목록에서 레시피를 선택하거나\n새로운 레시피를 등록해주세요")
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

// MARK: Actions
extension RecipeList {
    @Sendable
    private func delete(_ indexSet: IndexSet) {
        let deletions = indexSet.map { recipes[$0] }
        Recipe.delete(recipes: deletions, context: viewContext)
    }
}

struct RecipeList_Previews: PreviewProvider {
    static var previews: some View {
        RecipeList()
            .modifier(AppEnvironment(inMemory: true))
    }
}
