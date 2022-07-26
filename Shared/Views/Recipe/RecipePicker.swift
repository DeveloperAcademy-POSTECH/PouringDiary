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

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
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
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationTitle("레시피 선택")
        }
    }
}

struct RecipePicker_Previews: PreviewProvider {
    static var previews: some View {
        RecipePicker(selectedRecipe: .constant(nil))
    }
}
