//
//  ImageData+Extension.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/08/04.
//

import Foundation
import CoreData

extension ImageData {
    static func register(data: Data, context: NSManagedObjectContext) async throws -> ImageData {
        let image = ImageData(context: context)
        try await context.perform(schedule: .immediate) {
            image.data = data
            try context.save()
        }
        return image
    }
}
