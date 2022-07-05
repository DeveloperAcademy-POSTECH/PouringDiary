//
//  RecipeForm.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/05.
//

import SwiftUI
import CoreData

struct RecipeForm: View {
    // State variables
    @State private var input: Recipe.Input
    @State private var selectedCoffeeBean: CoffeeBean?
    @State private var equipmentTags: [Tag] = []
    @State private var recipeTags: [Tag] = []
    @State private var isTagSelectorShow: Bool = false

    // Internal variables / getters
    private var objectId: NSManagedObjectID?
    private var isEditing: Bool {
        return objectId != nil
    }

    // MARK: Initializers
    init(_ recipe: Recipe? = nil) {
        if let input = recipe?.input {
            self._input = State(initialValue: input)
        } else {
            self._input = State(initialValue: Recipe.Input())
        }
        self.objectId = recipe?.objectID
    }

    init(_ coffeeBean: CoffeeBean) {
        self._input = State(initialValue: Recipe.Input())
        self.objectId = nil
        self.selectedCoffeeBean = coffeeBean
    }

    var body: some View {
        Form {
            Section("레시피 이름") {
                TextField(text: $input.title) {
                    Text("이름을 입력해주세요")
                }
            }
            Section("레시피 설명") {
                TextEditor(text: $input.information)
            }
            Section("원두 선택") {
                coffeeBeanSelectButton
            }
        }
        .task(prepareTags)
        .navigationTitle(isEditing ? "레시피 수정" : "레시피 등록")
    }
}

// MARK: ViewBuilders {
extension RecipeForm {
    @ViewBuilder
    private var coffeeBeanSelectButton: some View {
        Button(action: {

        }, label: {
            if let bean = selectedCoffeeBean {
                Text(bean.name ?? "")
                    .font(.body)
            } else {
                Text("원두를 선택해주세요")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        })
    }

    @ViewBuilder
    private var equipmentSelector: some View {
        Button(action: {

        }, label: {
            if equipmentTags.isEmpty {
                Text("추출 장비를 선택해주세요")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
            }
        })
    }
}

// MARK: Actions
extension RecipeForm {

    @Sendable
    private func prepareTags() async {

    }
}

struct RecipeForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeForm()
        }
        .modifier(AppEnvironment(inMemory: true))
    }
}
