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
                    Label("main-tab-journal", systemImage: "book.closed")
                }
            RecipeList()
                .tabItem {
                    Label("main-tab-recipe", systemImage: "paperclip")
                }
            CoffeeBeanList()
                .tabItem {
                    Label("main-tab-bean", systemImage: "cup.and.saucer")
                }
            Text("Not Implemented")
                .tabItem {
                    Label("main-tab-post", systemImage: "camera.on.rectangle")
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
