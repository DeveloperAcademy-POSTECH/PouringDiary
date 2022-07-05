//
//  ContentView.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("레시피")
                .tabItem {
                    Label("레시피", systemImage: "note")
                }
            CoffeeBeanList()
                .tabItem {
                    Label("원두", systemImage: "cup.and.saucer")
                }
            Text("태그")
                .tabItem {
                    Label("태그", systemImage: "tag")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modifier(AppEnvironment(inMemory: true))
    }
}
