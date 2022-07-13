//
//  DiaryForm.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/12.
//

import SwiftUI
import CoreData

struct DiaryForm: View {
    // Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    // FetchedRequest
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.created)],
        predicate: NSPredicate(format: "id == %@", UUID().uuidString)
    )
    private var sameSourceDiaries: FetchedResults<Diary>

    // Property
    @State private var input: Diary.Input = Diary.Input(memo: "", flavorRecords: [])

    @State private var selectedCoffeeBean: CoffeeBean?
    @State private var selectedRecipe: Recipe?

    @State private var recipePickerShow: Bool = false
    @State private var coffeeBeanPickerShow: Bool = false
    @State private var memoListShow: Bool = false
    @State private var preventScreenLock: Bool = false

    // Internal
    private var objectId: NSManagedObjectID?

    private var isEditing: Bool {
        return objectId != nil
    }

    // Initializer
    init() {
        self.objectId = nil
    }

    init(recipe: Recipe? = nil, bean: CoffeeBean? = nil) {
        self.objectId = nil
        self._selectedRecipe = State(initialValue: recipe)
        self._selectedCoffeeBean = State(initialValue: bean)
    }

    init(with diaryId: NSManagedObjectID) {
        self.objectId = diaryId
    }

    var body: some View {
        Form {
            settingSection
            coffeeBeanSection
            recipeSection
            memoSection
        }
        .navigationTitle(isEditing ? "일지 수정" : "일지 작성")
        .toolbar(content: toolbar)
        .sheet(isPresented: $coffeeBeanPickerShow) {
            CoffeeBeanPicker(selectedBean: $selectedCoffeeBean)
        }
        .sheet(isPresented: $recipePickerShow) {
            RecipePicker(selectedRecipe: $selectedRecipe)
        }
        .sheet(isPresented: $memoListShow) {
            previousMemo
        }
        .onChange(of: preventScreenLock, perform: { prevent in
            UIApplication.shared.isIdleTimerDisabled = prevent
        })
        .onDisappear {
            preventScreenLock = false
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: selectedCoffeeBean, perform: { _ in updateSameSourcedDiary() })
        .onChange(of: selectedRecipe, perform: { _ in updateSameSourcedDiary() })
        .task(prepare)
    }
}

// Views
extension DiaryForm {
    @ViewBuilder
    private var settingSection: some View {
        Section(content: {
            Toggle(isOn: $preventScreenLock) {
                Text("화면 켠 채로 유지")
                    .font(.caption)
            }
        }, header: {
            Text("화면 설정")
                .font(.caption)
        }, footer: {
            Text("레시피를 조회하면서 화면이 꺼지지 않도록 해줍니다")
                .font(.caption2)
        })
    }
    @ViewBuilder
    private var recipeSection: some View {
        Section(content: {
            if let recipe = selectedRecipe {
                Text(recipe.title ?? "")
                    .font(.headline)
                    .padding(.vertical, 4)
                Text(recipe.steps ?? "")
                    .font(.body)
                    .padding(.vertical, 4)
                VStack(alignment: .leading) {
                    ScrollView(.horizontal) {
                        Text("사용 장비")
                            .font(.caption2)
                        HStack {
                            ForEach(recipe.equipmentArray) { tag in
                                TagItem(tag: tag.input)
                            }
                        }
                    }
                }
            } else {
                Button(action: {
                    recipePickerShow.toggle()
                }, label: {
                    Text("레시피를 선택해주세요")
                        .font(.caption)
                })
            }
        }, header: {
            Text("레시피")
                .font(.caption)
        }, footer: {
            if selectedRecipe != nil {
                HStack {
                    Spacer()
                    Button(action: {
                        recipePickerShow.toggle()
                    }, label: {
                        Label("레시피 변경", systemImage: "pencil")
                            .font(.caption)
                    })
                }
            }
        })
    }

    @ViewBuilder
    private var coffeeBeanSection: some View {
        Section(content: {
            if let bean = selectedCoffeeBean {
                Text(bean.name ?? "")
                    .font(.body)
            } else {
                Button(action: {
                    coffeeBeanPickerShow.toggle()
                }, label: {
                    Text("원두를 선택해주세요")
                        .font(.caption)
                })
            }

        }, header: {
            Text("원두")
                .font(.caption)
        }, footer: {
            if selectedCoffeeBean != nil {
                HStack {
                    Spacer()
                    Button(action: {
                        coffeeBeanPickerShow.toggle()
                    }, label: {
                        Label("원두 변경", systemImage: "pencil")
                            .font(.caption)
                    })
                }
            }
        })
    }

    private var diaries: [Diary] {
        return sameSourceDiaries
            .filter { $0.objectID != objectId }
    }

    @ViewBuilder
    private var memoSection: some View {
        Section(content: {
            TextEditor(text: $input.memo)
        }, header: {
            Text("메모")
                .font(.caption)
        }, footer: {
            if  diaries.isEmpty {
                Text("이번 추출에서 레시피에 변화를 준 부분 등을 적어주세요\n다음에 같은 원두, 같은 레시피로 일지를 만드시면 이 내용이 표시됩니다")
                    .font(.caption2)
            } else {
                HStack {
                    Spacer()
                    Button {
                        memoListShow.toggle()
                    } label: {
                        Text("같은 원두와 레시피로 작성된 메모가 \(diaries.count)개 있습니다.")
                    }
                }
            }
        })
    }

    @ViewBuilder
    private var previousMemo: some View {
        List {
            ForEach(diaries) { diary in
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text(diary.created?.monthAndDate ?? "")
                            .font(.caption2)
                    }
                    Text(diary.memo ?? "")
                        .font(.body)
                }
                .padding()
            }
        }
    }

    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            HStack {
                Button(action: {
                    guard let bean = selectedCoffeeBean, let recipe = selectedRecipe else { return }
                    let relation = Diary.RelationInput(bean: bean, recipe: recipe)
                    if isEditing {
                        Diary.save(
                            objectId: objectId!,
                            input: input,
                            relation: relation,
                            context: viewContext
                        )
                    } else {
                        Diary.register(
                            input: input,
                            relation: relation,
                            context: viewContext
                        )
                    }
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text(isEditing ? "수정" : "등록")
                })
            }
        }
    }
}

extension DiaryForm {
    @Sendable
    private func updateSameSourcedDiary() {
        guard
            let recipe = selectedRecipe,
            let bean = selectedCoffeeBean
        else { return }
        sameSourceDiaries.nsPredicate = NSPredicate(
            format: "recipe == %@ AND coffeeBean == %@",
            recipe,
            bean
        )
    }

    @Sendable
    private func prepare() {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(50))) {
            preventScreenLock = true
            updateSameSourcedDiary()
            guard let id = objectId, let diary = Diary.get(by: id, context: viewContext) else { return }
            selectedRecipe = diary.recipe
            selectedCoffeeBean = diary.coffeeBean
            input = diary.input
        }
    }
}

struct DiaryForm_Previews: PreviewProvider {
    static var previews: some View {
        DiaryForm()
    }
}
