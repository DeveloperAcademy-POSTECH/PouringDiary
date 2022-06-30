//
//  TagPicker.swift
//  PouringDiary
//
//  Created by devisaac on 2022/06/24.
//

import SwiftUI

struct TagPicker: View {

    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Tag.color, ascending: true)
    ])
    private var allTags: FetchedResults<Tag>

    @State var searchQuery: String = ""
    @State var isTagFormShow: Bool = false
    @Binding var selected: [Tag]

    private func toggleItem(tag: Tag) {
        if selected.contains(tag) {
            selected
                .removeAll { $0 == tag }
        } else {
            selected
                .append(tag)

        }
    }

    @ViewBuilder
    private func tagToggleButton(tag: Tag) -> some View {
        Button(action: {
            toggleItem(tag: tag)
        }, label: {
            TagItem(tag: tag.input)
        })
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(
                            selected,
                            id: \.id,
                            content: tagToggleButton
                        )
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                List(allTags
                    .filter { !selected.contains($0) }
                    .filter { $0.content?.contains(searchQuery) ?? false || searchQuery.isEmpty }
                    .sorted(by: { $0.color > $1.color }),
                     id: \.objectID,
                     rowContent: tagToggleButton
                )
                .searchable(
                    text: $searchQuery,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "태그를 검색해보세요"
                )
            }
            .toolbar {
                NavigationLink(
                    isActive: $isTagFormShow,
                    destination: {
                        TagForm(isPresent: $isTagFormShow)
                    },
                    label: {
                        Image(systemName: "plus")
                    })
            }
            .navigationTitle("태그 선택")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct TagPicker_Previews: PreviewProvider {
    static var previews: some View {
        TagPicker(selected: .constant([]))
            .modifier(AppEnvironment(inMemory: true))
    }
}
