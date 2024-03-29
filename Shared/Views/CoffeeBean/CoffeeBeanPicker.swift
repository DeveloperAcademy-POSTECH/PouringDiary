//
//  CoffeeBeanPicker.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/08.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct CoffeeBeanPicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var beans: FetchedResults<CoffeeBean>

    @Binding var selectedBean: CoffeeBean?

    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            List {
                if beans.isEmpty {
                    Button(action: {
                        Task {
                            try? await CoffeeBean.register(
                                input: .init(name: searchText),
                                tags: [],
                                context: viewContext)
                        }
                    }, label: {
                        Text("coffee-bean-instant-add-\(searchText)")
                    })

                } else {
                    ForEach(beans, id: \.objectID) { bean in
                        Button(action: {
                            selectedBean = bean
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text(bean.name ?? "")
                                .font(.body)
                        })
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationTitle("원두 선택")
            .analyticsScreen(name: "Coffee Bean Picker")
        }
        .searchable(
            text: $searchText,
            prompt: Text("coffee-bean-list-prompt")
        )
        .onChange(of: searchText) { text in
            if !text.isEmpty {
                beans.nsPredicate = CoffeeBean.searchByName(query: text)
            } else {
                beans.nsPredicate = nil
            }
        }
    }
}

struct CoffeeBeanPicker_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeBeanPicker(selectedBean: .constant(nil))
    }
}
