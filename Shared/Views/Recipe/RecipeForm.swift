//
//  RecipeForm.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/05.
//

import SwiftUI
import CoreData
import FirebaseAnalyticsSwift

struct RecipeForm: View {
    // Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    // Structs
    private struct TagSheetOption {
        var isShow: Bool
        var category: Tag.Category
    }

    // State
    @State private var input: Recipe.Input = Recipe.Input()
    @State private var equipmentTags: [Tag] = []
    @State private var recipeTags: [Tag] = []
    @State private var equipmentPickerShow: Bool = false
    @State private var tagPickerShow: Bool = false

    // Internal
    private var recipeId: NSManagedObjectID?
    private var isEditing: Bool {
        return recipeId != nil
    }

    private var formValidated: Bool {
        return !input.steps.isEmpty && !input.title.isEmpty
    }

    // MARK: Initializers
    init(_ recipeId: NSManagedObjectID? = nil) {
        self.recipeId = recipeId
    }

    init(_ coffeeBean: CoffeeBean) {
        self.recipeId = nil
    }

    var body: some View {
        Form {
            titleSection
            stepSection
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
        .analyticsScreen(name: "Recipe Form - \(isEditing ? "Edit" : "New")")
    }
}

// MARK: Views
extension RecipeForm {
    @ViewBuilder
    private var stepSection: some View {
        Section(content: {
            TextEditor(text: $input.steps)
        }, header: {
            Text("레시피 작성")
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
        Section("추가 정보") {
            TextEditor(text: $input.information)
        }
    }

    private func toolbar() -> some ToolbarContent {
        return ToolbarItem(placement: .automatic) {
            Button(
                action: saveOrRegister,
                label: {
                    Text(isEditing ? "수정" : "등록")
                }
            )
            .disabled(!formValidated)
        }
    }
}

// MARK: Actions
extension RecipeForm {
    @MainActor
    @Sendable
    private func prepare() async {
        guard let id = self.recipeId, let recipe = viewContext.get(by: id) as? Recipe else { return }
        input = recipe.input
        recipeTags = recipe.tagArray
        equipmentTags = recipe.equipmentArray

        DispatchQueue.main.async {
            if input.steps.last != "\n" {
                input.steps.append(contentsOf: "\n")
            } else {
                input.steps.removeLast()
            }
        }
    }

    @Sendable
    private func saveOrRegister() {
        Task {
            let relation = Recipe.RelationInput(
                tags: recipeTags,
                equipments: equipmentTags
            )
            if let recipeId = recipeId {
                await Recipe.save(
                    objectId: recipeId,
                    input: input,
                    relation: relation,
                    context: viewContext
                )
            } else {
                _ = try? await Recipe.register(
                    input: input,
                    relation: relation,
                    context: viewContext
                )
            }
        }
        presentationMode.wrappedValue.dismiss()
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
