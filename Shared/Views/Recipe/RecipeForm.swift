//
//  RecipeForm.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/05.
//

import SwiftUI
import CoreData

struct RecipeForm: View {
    // Structs
    private struct TagSheetOption {
        var isShow: Bool
        var category: Tag.Category
    }
    // Variables /w property wrapper
    @State private var input: Recipe.Input = Recipe.Input()
    @State private var selectedCoffeeBean: CoffeeBean?
    @State private var equipmentTags: [Tag] = []
    @State private var recipeTags: [Tag] = []
    @State private var equipmentPickerShow: Bool = false
    @State private var tagPickerShow: Bool = false

    @Environment(\.managedObjectContext) private var viewContext

    // Internal variables / getters
    private var objectId: NSManagedObjectID?
    private var isEditing: Bool {
        return objectId != nil
    }

    private var formValidated: Bool {
        return selectedCoffeeBean != nil && !input.steps.isEmpty && !input.title.isEmpty
    }

    // MARK: Initializers
    init(_ recipeId: NSManagedObjectID? = nil) {
        self.objectId = recipeId
        self.selectedCoffeeBean = nil
    }

    init(_ coffeeBean: CoffeeBean) {
        self.objectId = nil
        self.selectedCoffeeBean = coffeeBean
    }

    var body: some View {
        Form {
            titleSection
            stepSection
            coffeeBeanSection
            equipmentSection
            recipeTagSection
            informationSection
        }
        .task(prepare)
        .toolbar(content: toolbar)
        .sheet(isPresented: $tagPickerShow) {
            TagPicker(with: .regular, selected: $recipeTags)
        }
        .sheet(isPresented: $equipmentPickerShow) {
            TagPicker(with: .equipment, selected: $equipmentTags)
        }
        .navigationTitle(isEditing ? "레시피 수정" : "레시피 등록")
    }
}

// MARK: ViewBuilders {
extension RecipeForm {
    @ViewBuilder
    private var stepSection: some View {
        Section(content: {
            TextEditor(text: $input.steps)
        }, header: {
            Text("레시피 작성")
        }, footer: {
            HStack {
                Spacer()
                Text(input.steps.isEmpty ? "추출 과정을 적어보세요" : "")
                    .foregroundColor(.blue)
                    .font(.caption2)
            }
        })

    }

    @ViewBuilder
    private var titleSection: some View {
        Section("레시피 이름") {
            TextField(text: $input.title) {
                Text("이름을 입력해주세요")
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var coffeeBeanSection: some View {
        Section("원두 선택") {
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
    }

    @ViewBuilder
    private func tagList(tags: [Tag]) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tags, id: \.id) { tag in
                    TagItem(tag: tag.input)
                }
            }
        }
    }

    @ViewBuilder
    private var equipmentSection: some View {
        Section(content: {
            Button(action: {
                equipmentPickerShow.toggle()
            }, label: {
                if equipmentTags.isEmpty {
                    Text("추출장비를 선택해주세요")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    tagList(tags: equipmentTags)
                }
            })
        }, header: {
            Text("장비 선택")
                .font(.caption)
        }, footer: {
            if !equipmentTags.isEmpty {
                HStack {
                    Spacer()
                    Button(action: {
                        equipmentPickerShow.toggle()
                    }, label: {
                        Label("장비 변경하기", systemImage: "tag")
                            .font(.caption)
                    })
                }
            }
        })
    }

    @ViewBuilder
    private var recipeTagSection: some View {
        Section(content: {
            Button(action: {
                tagPickerShow.toggle()
            }, label: {
                if recipeTags.isEmpty {
                    Text("태그를 선택해주세요")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    tagList(tags: recipeTags)
                }
            })
        }, header: {
            Text("태그 선택")
                .font(.caption)
        }, footer: {
            if !recipeTags.isEmpty {
                HStack {
                    Spacer()
                    Button(action: {
                        tagPickerShow.toggle()
                    }, label: {
                        Label("태그 변경하기", systemImage: "tag")
                            .font(.caption)
                    })
                }
            }
        })
    }

    @ViewBuilder
    private var informationSection: some View {
        Section("기타 정보") {
            TextField(text: $input.information) {
                Text("그 외 필요한 정보들을 입력해주세요")
                    .font(.caption)
            }
        }
    }

    private func toolbar() -> some ToolbarContent {
        return ToolbarItem(placement: .automatic) {
            Button(action: {
                guard let bean = selectedCoffeeBean else { return }
                Recipe.register(
                    input: input,
                    relation: Recipe.RelationInput(tags: recipeTags, coffeeBean: bean, equipments: equipmentTags),
                    context: viewContext
                )
            }, label: {
                Text(isEditing ? "수정" : "등록")
            })
            .disabled(!formValidated)
        }
    }
}

// MARK: Actions
extension RecipeForm {
    @Sendable
    private func prepare() async {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(50))) {
            guard let id = self.objectId, let recipe = viewContext.get(by: id) as? Recipe else { return }
            input = recipe.input
            selectedCoffeeBean = recipe.coffeeBean
            recipeTags = recipe.tagArray
            equipmentTags = recipe.equipmentArray
        }
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
