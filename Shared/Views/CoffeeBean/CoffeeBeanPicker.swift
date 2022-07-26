//
//  CoffeeBeanPicker.swift
//  PouringDiary
//
//  Created by devisaac on 2022/07/08.
//

import SwiftUI

struct CoffeeBeanPicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var beans: FetchedResults<CoffeeBean>

    @Binding var selectedBean: CoffeeBean?

    var body: some View {
        NavigationView {
            List {
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
        }
    }
}

struct CoffeeBeanPicker_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeBeanPicker(selectedBean: .constant(nil))
    }
}
