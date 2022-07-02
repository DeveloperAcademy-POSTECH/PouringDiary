//
//  ContentView.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            CoffeeBeanList()
                .navigationTitle("원두 목록")
                .toolbar(content: toolBar)
        }
    }
}

extension ContentView {
    @ViewBuilder fileprivate func toolBar() -> some View {
        HStack {
            EditButton()
            NavigationLink(destination: {
                CoffeeBeanForm()
            }, label: {
                Image(systemName: "plus")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modifier(AppEnvironment(inMemory: true))
    }
}
