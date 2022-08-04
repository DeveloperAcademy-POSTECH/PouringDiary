//
//  PouringDiaryApp.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import SwiftUI

@main
struct PouringDiaryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modifier(AppEnvironment())
        }
    }
}
