//
//  DiaryForm+Sections.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/08/24.
//

import SwiftUI

// Views
extension DiaryForm {
    @ViewBuilder
    var settingSection: some View {
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
    var previousDiarySection: some View {
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
    var recipeSection: some View {
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
    var coffeeBeanSection: some View {
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

    var diaries: [Diary] {
        return sameSourceDiaries
            .filter { $0.objectID != objectId }
    }

    @ViewBuilder
    var memoSection: some View {
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
    var previousMemo: some View {
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
    var toolSection: some View {
        Section {
            Button {
                duplicateShow.toggle()
            } label: {
                Text("복제")
                    .font(.caption)
            }
            Button {
                shareShow.toggle()
            } label: {
                Text("share-context-menu")
                    .font(.caption)
            }
        } header: {
            Text("diary-form-section-tools-header")
        } footer: {
            Text("diary-form-section-tools-footer")
        }
    }

    @ViewBuilder
    var flavorSection: some View {
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

    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
                Button(action: {
                    Task {
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
                            _ = try? await Diary.register(
                                input: input,
                                relation: relation,
                                context: viewContext
                            )
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text(isEditing ? "수정" : "등록")
                })
            }
        }
    }
}
