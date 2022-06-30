//
//  CoffeeBeanForm.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/06/24.
//

import SwiftUI
import CoreData

/**
 원두를 새로 등록하거나 수정하는 화면 컴포넌트 입니다.
 */
struct CoffeeBeanForm: View {
    /// 수정을 하려는 원두를 초기화시에 전달합니다.
    private var editingCoffeeBean: CoffeeBean?
    /// `editingCoffeeBean`이 전달 되지 않았다면 원두를 새로 등록한다고 가정합니다.
    private var isEditing: Bool { editingCoffeeBean != nil }

    @State var input: CoffeeBean.Input = CoffeeBean.Input()
    @State var isTagListShow: Bool = false
    @State var selectedTags: [Tag] = []

    init(_ bean: CoffeeBean? = nil) {
        guard let editing = bean else { return }
        self.editingCoffeeBean = editing
        self.input = editing.input
        self.selectedTags = editing.tagArray
    }

    var body: some View {
        Form {
            Section("원두 이름") {
                TextField(text: $input.name) {
                    Text("원두의 이름을 입력해주세요")
                        .font(.caption2)
                        .submitLabel(.return)
                }
            }
            Section("원두 설명") {
                TextEditor(text: $input.explanation)
                    .font(.body)
                    .submitLabel(.return)
                    .lineSpacing(4)
                    .frame(minHeight: 60)
            }
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
                        Label("태그 추가하기", systemImage: "plus")
                    })
                }
            }
        }
        .sheet(isPresented: $isTagListShow) {
            TagPicker(selected: $selectedTags)
        }
        .navigationTitle("원두 등록")
    }
}

struct CoffeeBeanForm_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeBeanForm()
            .modifier(AppEnvironment(inMemory: true))
    }
}
