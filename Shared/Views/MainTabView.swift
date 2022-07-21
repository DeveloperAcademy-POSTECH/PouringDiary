//
//  ContentView.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DiaryList()
                .tabItem {
                    Label("일지", systemImage: "book.closed")
                }
            RecipeList()
                .tabItem {
                    Label("레시피", systemImage: "paperclip")
                }
            CoffeeBeanList()
                .tabItem {
                    Label("원두", systemImage: "cup.and.saucer")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .modifier(AppEnvironment(inMemory: true))
    }
}
