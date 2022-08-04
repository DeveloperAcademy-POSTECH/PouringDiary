//
//  DiaryForm.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/12.
//

import SwiftUI
import CoreData
import FirebaseAnalyticsSwift

struct DiaryForm: View {
    // Environment
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    // FetchedRequest
    @FetchRequest
    private var sameSourceDiaries: FetchedResults<Diary>

    // Property
    @State private var input: Diary.Input = Diary.Input(memo: "", flavorRecords: [])

    @State private var selectedCoffeeBean: CoffeeBean?
    @State private var selectedRecipe: Recipe?

    @State private var recipePickerShow: Bool = false
    @State private var coffeeBeanPickerShow: Bool = false
    @State private var memoListShow: Bool = false
    @State private var flavorPickerShow: Bool = false
    @State private var preventScreenLock: Bool = false

    // Internal
    private var objectId: NSManagedObjectID?

    private var isEditing: Bool {
        return objectId != nil
    }

    // Initializer
    init() {
        self.objectId = nil
        self._sameSourceDiaries = FetchRequest(fetchRequest: Diary.requestSameSourceDiary())
    }

    init(recipe: Recipe? = nil, bean: CoffeeBean? = nil) {
        self.objectId = nil
        self._selectedRecipe = State(initialValue: recipe)
        self._selectedCoffeeBean = State(initialValue: bean)
        self._sameSourceDiaries = FetchRequest(fetchRequest: Diary.requestSameSourceDiary())
    }

    init(with diaryId: NSManagedObjectID) {
        self.objectId = diaryId
        self._sameSourceDiaries = FetchRequest(fetchRequest: Diary.requestSameSourceDiary())
    }

    var body: some View {
        Form {
            settingSection
            coffeeBeanSection
            recipeSection
            previousDiarySection
            memoSection
            flavorSection
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
        .sheet(isPresented: $flavorPickerShow) {
            FlavorRecordPicker(selectedRecords: $input.flavorRecords)
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
        .analyticsScreen(name: "Diary Form - \(isEditing ? "Edit" : "New")")
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
    private var previousDiarySection: some View {
        if  !diaries.isEmpty {
            Button {
                memoListShow.toggle()
            } label: {
                Text("같은 원두와 레시피로 작성된 메모가 \(diaries.count)개 있습니다.")
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var recipeSection: some View {
        Section(content: {
            if let recipe = selectedRecipe {
                VStack(alignment: .leading) {
                    Text(recipe.title ?? "")
                        .font(.headline)
                        .padding(.vertical, 4)
                    Divider()
                    Text(recipe.steps ?? "")
                        .font(.body)
                        .padding(.vertical, 4)
                        .fixedSize(horizontal: false, vertical: true)
                    Divider()
                    VStack(alignment: .leading) {
                        Text("사용 장비")
                            .font(.subheadline)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(recipe.equipmentArray) { tag in
                                    TagItem(tag: tag.input)
                                }
                            }
                        }
                    }
                }
                .padding(4)
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
            Text("이번 추출에서 레시피에 변화를 준 부분 등을 적어주세요\n다음에 같은 원두, 같은 레시피로 일지를 만드시면 이 내용이 표시됩니다")
                .font(.caption2)
        })
    }

    @ViewBuilder
    private var previousMemo: some View {
        NavigationView {
            List {
                ForEach(diaries) { diary in
                    DiaryMemoCard(diary: diary)
                }
            }
            .navigationTitle("이전 메모")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        memoListShow.toggle()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var flavorSection: some View {
        Section(content: {
            if input.flavorRecords.isEmpty {
                Button(action: {
                    flavorPickerShow.toggle()
                }, label: {
                    Text("diary-form-flavor-section-picker-label")
                        .font(.caption)
                })
            } else {
                VStack(spacing: 12) {
                    FlavorSummary(
                        sum: input.extractionSum,
                        count: input.flavorRecords.count,
                        label: "flavor-record-picker-extraction",
                        minLabel: "flavor-record-picker-extraction-under",
                        maxLabel: "flavor-record-picker-extraction-over"
                    )
                    FlavorSummary(
                        sum: input.strengthSum,
                        count: input.flavorRecords.count,
                        label: "flavor-record-picker-strength",
                        minLabel: "flavor-record-picker-strength-under",
                        maxLabel: "flavor-record-picker-strength-over"
                    )
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(input.flavorRecords, id: \.label) { record in
                            FlavorItem(record: record, selected: false)
                        }
                    }
                }
            }
        }, header: {
            Text("diary-form-flavor-section-header")
                .font(.caption)
        }, footer: {
            if input.flavorRecords.isEmpty {
                Text("diary-form-flavor-section-footer")
                    .font(.caption)
            } else {
                HStack {
                    Spacer()
                    Button(action: {
                        flavorPickerShow.toggle()
                    }, label: {
                        Label("수정하기", systemImage: "pencil")
                    })
                }
            }
        })
    }

    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
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

// MARK: Actions
extension DiaryForm {
    @Sendable
    private func updateSameSourcedDiary() {
        guard
            let recipe = selectedRecipe,
            let bean = selectedCoffeeBean
        else { return }
        let newRequest = Diary.requestSameSourceDiary(recipe: recipe, bean: bean)
        sameSourceDiaries.nsPredicate = newRequest.predicate
        sameSourceDiaries.sortDescriptors = newRequest
            .sortDescriptors?
            .map { SortDescriptor<Diary>($0, comparing: Diary.self)! } ?? []

    }

    @MainActor
    @Sendable
    private func prepare() {
        preventScreenLock = true
        updateSameSourcedDiary()
        guard let id = objectId, let diary = Diary.get(by: id, context: viewContext) else { return }
        selectedRecipe = diary.recipe
        selectedCoffeeBean = diary.coffeeBean
        input = diary.input

        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(50))) {
            if input.memo.last != "\n" {
                input.memo.append(contentsOf: "\n")
            } else {
                input.memo.removeLast()
            }
        }
    }
}

struct DiaryForm_Previews: PreviewProvider {
    static var previews: some View {
        DiaryForm()
    }
}
