//
//  RecipeList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/05.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct RecipeList: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var recipes: FetchedResults<Recipe>

    var body: some View {
        NavigationView {
            List {
                if recipes.isEmpty {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("아직 등록된 레시피가 없습니다")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                }
                ForEach(recipes, id: \.id) { recipe in
                    NavigationLink(destination: {
                        RecipeForm(recipe.objectID)
                    }, label: {
                        VStack(alignment: .leading) {
                            Text(recipe.title ?? "")
                                .font(.headline)
                            Wrap {
                                ForEach(recipe.tagArray) { tag in
                                    TagItem(tag: tag.input)
                                }
                                ForEach(recipe.equipmentArray) { tag in
                                    TagItem(tag: tag.input)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    })
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("레시피 목록")
            .toolbar(content: toolbar)
        }
        .navigationViewStyle(.stack)
        .analyticsScreen(name: "Recipe List")
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
                    Text("추가")
                })
            }
        }
    }
}

// MARK: Actions
extension RecipeList {
    private func delete(_ indexSet: IndexSet) {
        let deletions = indexSet.map { recipes[$0] }
        Recipe.delete(recipes: deletions, context: viewContext)
    }
}

struct RecipeList_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            RecipeList()
        }
        .modifier(AppEnvironment(inMemory: true))
    }
}
