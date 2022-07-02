//
//  CoffeeBeanForm.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/06/24.
//

import SwiftUI
import CoreData

/**
 원두를 새로 등록하거나 수정하는 뷰입니다.
 */
struct CoffeeBeanForm: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    private let beanId: NSManagedObjectID?
    private var isEditing: Bool { beanId != nil }

    @State var input: CoffeeBean.Input
    @State var isTagListShow: Bool = false
    @State var selectedTags: [Tag] = []

    /// `bean`입력 여부에 따라 새로운 원두인지, 기존 원두인지를 결정합니다
    /// 태그값은 뷰가 그려진 이후에 수령합니다
    init(_ bean: CoffeeBean? = nil) {
        if let editing = bean {
            self.beanId = editing.objectID
            self._input = State(initialValue: editing.input)
        } else {
            self.beanId = bean?.objectID
            self._input = State(initialValue: CoffeeBean.Input())
        }
    }

    /// 초기화에 수령한 ObjectID를 사용해서 태그를 수령합니다
    @Sendable
    private func prepareTags() async {
        guard let objectId = beanId ,
              let editing = CoffeeBean.get(
                by: objectId,
                context: viewContext
              ) else { return }
        self.selectedTags = editing.tagArray
    }

    var body: some View {
        Form {
            nameSection
            explanationSection
            tagSection
        }
        .toolbar { toolbar }
        .sheet(isPresented: $isTagListShow) { TagPicker(selected: $selectedTags) }
        .navigationTitle(isEditing ? "원두 수정" : "원두 등록")
        .task(prepareTags)
    }
}

// MARK: ViewBuilders
extension CoffeeBeanForm {
    /// 원두 이름 입력 Form Section
    @ViewBuilder
    fileprivate var nameSection: some View {
        Section("원두 이름") {
            TextField(text: $input.name) { EmptyView() }
                .font(.body)
                .submitLabel(.return)
        }
    }

    /// 원두 설명 입력 Form Section
    @ViewBuilder
    fileprivate var explanationSection: some View {
        Section("원두 설명") {
            TextEditor(text: $input.explanation)
                .font(.body)
                .submitLabel(.return)
        }
    }

    /// 태그 입력 Form Section
    @ViewBuilder
    fileprivate var tagSection: some View {
        Section {
            if selectedTags.isEmpty {
                Button(action: {
                    self.isTagListShow.toggle()
                }, label: {
                    Text("아직 태그가 추가되지 않았습니다")
                        .font(.caption2)
                        .foregroundColor(Color.gray)
                })
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedTags, id: \.objectID) { tag in
                            TagItem(tag: tag.input)
                        }
                    }
                }
            }
        } header: {
            Text("태그")
        } footer: {
            HStack {
                Spacer()
                Button(action: {
                    self.isTagListShow.toggle()
                }, label: {
                    Label(
                        selectedTags.isEmpty ? "태그 추가하기" : "태그 변경하기",
                        systemImage: selectedTags.isEmpty ? "plus" : "tag"
                    )
                })
            }
        }
    }

    /// 등록 / 수정여부에 따라 적절한 툴바를 표시합니다
    @ViewBuilder
    fileprivate var toolbar: some View {
        Button(action: {
            if isEditing {
                CoffeeBean.save(
                    objectId: beanId!,
                    input: input,
                    tags: selectedTags,
                    context: viewContext
                )
            } else {
                CoffeeBean.register(
                    input: input,
                    tags: selectedTags,
                    context: viewContext
                )
            }
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text(isEditing ? "저장" : "등록")
        })
    }
}

// MARK: Previews
struct CoffeeBeanForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CoffeeBeanForm()
                .modifier(AppEnvironment(inMemory: true))
        }
    }
}