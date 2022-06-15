//
//  PouringDiaryApp.swift
//  Shared
//
//  Created by devisaac on 2022/06/15.
//

import SwiftUI

@main
struct PouringDiaryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
