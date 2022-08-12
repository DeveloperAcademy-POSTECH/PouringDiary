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
    private let inMemory: Bool
    private let controller: PersistenceController

    init(inMemory: Bool = false) {
        self.inMemory = inMemory
        controller = PersistenceController(inMemory: inMemory)
    }

    func body(content: Content) -> some View {
        content
            .environment(\.managedObjectContext, controller.container.viewContext)
#if DEBUG
            .task {
                if inMemory {
                    await controller.preparePresets()
                }
            }
#endif
    }
}
