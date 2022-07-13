//
//  RecipePicker.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/12.
//

import SwiftUI

struct RecipePicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created)])
    private var recipes: FetchedResults<Recipe>

    @Binding var selectedRecipe: Recipe?

    var body: some View {
        NavigationView {
            List {
                ForEach(recipes, id: \.objectID) { recipe in
                    Button(action: {
                        selectedRecipe = recipe
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text(recipe.title ?? "")
                            .font(.body)
                    })
                }
            }
            .navigationTitle("원두 선택")
        }
    }
}

struct RecipePicker_Previews: PreviewProvider {
    static var previews: some View {
        RecipePicker(selectedRecipe: .constant(nil))
    }
}
