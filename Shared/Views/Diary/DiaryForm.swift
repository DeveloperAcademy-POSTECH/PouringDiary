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
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode

    // FetchedRequest
    @FetchRequest
    var sameSourceDiaries: FetchedResults<Diary>

    // Property
    @State var input: Diary.Input = Diary.Input(memo: "", flavorRecords: [])

    @State var selectedCoffeeBean: CoffeeBean?
    @State var selectedRecipe: Recipe?

    @State var recipePickerShow: Bool = false
    @State var coffeeBeanPickerShow: Bool = false
    @State var memoListShow: Bool = false
    @State var flavorPickerShow: Bool = false
    @State var preventScreenLock: Bool = false
    @State var duplicateShow: Bool = false
    @State var shareShow: Bool = false

    // Internal
    var objectId: NSManagedObjectID?

    var isEditing: Bool {
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
            if isEditing {
                Section {
                    Button {
                        duplicateShow.toggle()
                    } label: {
                        Text("복제")
                    }
                    Button {
                        shareShow.toggle()
                    } label: {
                        Text("share-context-menu")
                    }
                } header: {
                    Text("diary-form-section-tools-header")
                } footer: {
                    Text("diary-form-section-tools-footer")
                }
            }
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
        .sheet(isPresented: $duplicateShow) {
            NavigationView {
                DiaryForm(recipe: selectedRecipe, bean: selectedCoffeeBean)
            }
        }
        .sheet(isPresented: $shareShow) {
            SharePostForm(diaryId: objectId!)
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
