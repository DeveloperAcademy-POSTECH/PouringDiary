//
//  AppEnvironment.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/06/15.
//

import Foundation
import SwiftUI
import CoreData

struct AppEnvironment: ViewModifier {
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = inMemory ? PersistenceController.preview.container : PersistenceController.shared.container
    }

    func body(content: Content) -> some View {
        content
            .environment(\.managedObjectContext, container.viewContext)
    }
}
