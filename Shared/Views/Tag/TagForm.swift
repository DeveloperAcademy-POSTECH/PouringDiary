//
//  TagForm.swift
//  PouringDiary
//
//  Created by devisaac on 2022/06/24.
//

import SwiftUI
import FirebaseAnalyticsSwift

/**
 새로운 태그를 등록하기 위한 뷰입니다
 */
struct TagForm: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var input: Tag.Input
    @Binding var isPresent: Bool

    init(with isPresent: Binding<Bool>, category: Tag.Category) {
        self._isPresent = isPresent
        self._input = State(
            initialValue: Tag.Input(
                content: "",
                color: .tag1,
                category: category
            )
        )
    }

    var body: some View {
        VStack {
            TextField("태그 이름을 입력해주세요", text: $input.content)
            colorPicker(tagColor: $input.color)
            Spacer()
        }
        .padding()
        .toolbar(content: toolbar)
        .navigationTitle("새로운 태그")
        .navigationBarTitleDisplayMode(.large)
        .analyticsScreen(name: "Tag Form")
    }
}

// MARK: Views
extension TagForm {
    private func toolbar() -> some ToolbarContent {
        return ToolbarItem(placement: .automatic) {
            Button("저장하기") {
                Tag.register(input: input, context: viewContext)
                isPresent.toggle()
            }
            .disabled(input.content.isEmpty)
        }
    }
    @ViewBuilder
    private func colorPicker(tagColor: Binding<Tag.Color>) -> some View {
        HStack {
            ForEach(Tag.Color.allCases, id: \.rawValue) { color in
                Button(action: {
                    tagColor.wrappedValue = color
                }, label: {
                    Rectangle()
                        .fill(color.color.opacity(color == input.color ? 1 : 0.3))
                        .frame(width: 24, height: 24)
                        .cornerRadius(12)
                })
            }
            Spacer()
        }
        .padding(.top)
    }
}

struct TagForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TagForm(with: .constant(false), category: .regular)
                .modifier(AppEnvironment(inMemory: true))
        }
    }
}
